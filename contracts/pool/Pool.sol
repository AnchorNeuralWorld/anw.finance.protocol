// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../access/manager/interface/ManagerRoleInterface.sol";
import "../access/governance/interface/GovernanceRoleInterface.sol";

import "../token/protocol/extension/mintable/interface/IERC20Mintable.sol";

import "./interface/IPool.sol";

import "../token/wrapped/IWNATIVE.sol";

import '../util/TransferHelper.sol';

// CHANGE LOG:
// DONE: ADD STAKED token map, and ADD POOL checking to prevent duplication
// DONE: ADD POOL FACTORY reference var, set it in constructor
// DONE: CHANGE ALL LP references to STAKE (NOTE: STAKE is generalized for other ERC20 as well, not just LP tokens)
// DONE: CHANGE all SUSHI reference to REWARD, including the var sushi => rewardToken (NOTE: REWARD is no generalized to payout any ERC20 token, but hte primary will be ANWFI)
// DONE: MAKE startBlock, rewardsPerBlock, bonusEndBlock, and BONUS_MULTIPLIER POOL specific, and settable when calling add()
// DONE: ADD PRECISION_FACTOR instead of fixed precision (based on reward token decimls())
// DONE: REMOVE Owner and add MANAGE OR GOVERNACE (set and tracked in factory)
// DONE: MAKE initializable for factory deployment compatability
// DONE: REMOVE SafeMath since we are solc 0.8.2 and greater
// DONE: ADD early withdrawal penatly logic
// DONE: ADD ability for admin to update various pool data
// DONE: REMOVE DEV and ADD TREASURY (for buyback/burn and other tokenomics GOVERNANCE LATER)
// DONE: ADD ability for admin to recoverWrongTokens()
// DONE: GENERALIZE for fixed REWARD POOLS (non-mintable REWARD token support), tracked as stakedToken address 0x0
    //     token supply = rewardAmount
    //     top-up token supply (add to rewardAmount)
    //     adjust logic for pending rewards calculation
    //     adjust payouts to use rewardAmount instead of minting and totalsupply
// DONE: NATIVE token staking (NATIVE STAKE is created as pid 0 during, )
    // safeTransferNative vs safeTranferFrom for NATIVE token transfers instead of ERC20 transfers
    // adjust withdraw, emergencyWithdraw and deposit logic 

contract Pool is Context, IPool {

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of REWARD
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws STAKE tokens to a pool. Here's what happens:
        //   1. The pool's `accRewardPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives any pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        address stakeToken; // Address of STAKED token
        uint256 allocPoint; // How many allocation points assigned to this POOL. REWARD to distribute per block.
        uint256 lastRewardBlock; // Last block number that REWARD distribution occurs.
        uint256 accRewardPerShare; // Accumulated REWARD per share, times PRECISION_FACTOR. See below.
        uint256 bonusEndBlock; // Block number when BONUS REWARD period ends for this POOL
        uint256 startBlock; // The block number when REWARD mining starts for this POOL
        uint256 minStakePeriod; // the minimum number of blocks a participant should stake for (early withdrawal will incure penatly fees)
        uint256 bonusMultiplier; // Bonus muliplier for early REWARD participation for this POOL
        uint256 rewardAmount; // the amount of total rewards to be distributed (only used for !mintable reward tokens)
    }

    bool private _isInitialized;

    address private _factory;

    address public override rewardToken;

    uint256 public override rewardPerBlock; // REWARD tokens allocated per block for the entire POOL

    bool public override mintable;

    address public override treasury;

    address public override nativeToken;

    uint256 public override PRECISION_FACTOR;

    mapping(address => bool) public override staked;

    // Info of each pool. (by pid)
    PoolInfo[] public override poolInfo;

    // Info of each user that stakes tokens for a pool (by pid, by user address)
    mapping(uint256 => mapping(address => UserInfo)) public override userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public override totalAllocPoint = 0;

    modifier onlyManagerOrGovernance() {
        require(
            ManagerRoleInterface(_factory).isManager(_msgSender()) || GovernanceRoleInterface(_factory).isGovernor(_msgSender()),
            "Pool::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    constructor() {
        _factory = _msgSender();
    }

    // NOTE: intialize() will fail for !mintable REWARD pools
    function initialize(
        address _rewardToken,
        uint256 _rewardPerBlock,
        address _treasury,
        address _nativeToken,
        uint256 _nativeAllocPoint,
        uint256 _nativeStartBlock,
        uint256 _nativeBonusMultiplier,
        uint256 _nativeBonusEndBlock,
        uint256 _nativeMinStakePeriod
    ) external override {
        require(_msgSender() == _factory, "Pool::initialize: FORBIDDEN");
        require(!_isInitialized, "Pool::initialize: INITIALIZED");
        
        rewardToken = _rewardToken;
        nativeToken = _nativeToken;
        rewardPerBlock = _rewardPerBlock;
        treasury = _treasury;

        bytes4 mint = bytes4(keccak256(bytes('mint(address,uint256)')));
        (bool success, ) = rewardToken.call(abi.encodeWithSelector(mint, address(this), 0));
        if(success) {
            mintable = true;
        } else {
            mintable = false;
        }

        uint256 decimalsRewardToken = uint256(IERC20Metadata(rewardToken).decimals());
        
        require(decimalsRewardToken < 30, "Pool::constructor: INVALID_REWARD_DECIMAL");
        PRECISION_FACTOR = uint256(10** (uint256(30) - decimalsRewardToken) );
        
        // Make this contract initialized
        _isInitialized = true;

        // pid 0 for every REWARD pool is reserved for Native token staking
        _add(
            nativeToken,
            _nativeAllocPoint,
            _nativeStartBlock,
            _nativeBonusMultiplier,
            _nativeBonusEndBlock,
            _nativeMinStakePeriod,
            0, // if this pool is !mintable, no reward amount initially, must add more REWARD later
            false // first pool no need to update others
        );
    }

    function poolLength() external view override returns (uint256) {
        return poolInfo.length;
    }

    // NOTE: if this Pool is a non-mintable reward, then the pool contract must be given approval for trasfer of tokens before any new add() is called
    // Add a new STAKE token to the pool. Can only be called by the owner.
    function add(
        address _stakeToken,
        uint256 _allocPoint,
        uint256 _startBlock,
        uint256 _bonusMultiplier,
        uint256 _bonusEndBlock,
        uint256 _minStakePeriod,
        uint256 _rewardAmount, // total amount of REWARD available for distribution form this pool, ignored if this rewardToken is mintable
        bool _withUpdate
    ) public override onlyManagerOrGovernance {
        _add(_stakeToken, _allocPoint, _startBlock, _bonusMultiplier, _bonusEndBlock, _minStakePeriod, _rewardAmount, _withUpdate);
    }

    // Update the entire pool's reward per block. Can only be called by admin or governance
    function updateRewardPerBlock(
        uint256 _rewardPerBlock
    ) public override onlyManagerOrGovernance {
        require(
            _isInitialized,
            "Pool::updateRewardPerBlock: POOL_NOT_INITIALIZED"
        );
        rewardPerBlock = _rewardPerBlock;
        massUpdatePools();
        emit RewardPerBlockSet(
            _rewardPerBlock
        );
    }

    // Update the given pool's REWARD allocation points. Can only be called by admin or governance
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public override onlyManagerOrGovernance {
        require(
            _isInitialized,
            "Pool::set: POOL_NOT_INITIALIZED"
        );
        require(
            _pid < poolInfo.length,
            "Pool::set: INVALID_PID"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = (totalAllocPoint - poolInfo[_pid].allocPoint) + _allocPoint;
            poolInfo[_pid].allocPoint = _allocPoint;
        }

        emit AllocationSet(
            _pid,
            _allocPoint
        );
    }

    // Update the given pool's start block. Can only be called by admin or governance
    function updateStart(
        uint256 _pid,
        uint256 _startBlock
    ) public override onlyManagerOrGovernance {
        require(
            _isInitialized,
            "Pool::set: POOL_NOT_INITIALIZED"
        );
        require(
            _pid < poolInfo.length,
            "Pool::updateStart: INVALID_PID"
        );
        require(
            _startBlock > block.number && block.number <= poolInfo[_pid].startBlock,
            "Pool::updateStart: INVALID_START_BLOCK"
        );
        uint256 lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        poolInfo[_pid].lastRewardBlock = lastRewardBlock;
        poolInfo[_pid].startBlock = _startBlock;

        emit StartingBlockSet(
            _pid,
            _startBlock
        );
    }

    // Update the given pool's minimum stake period. Can only be called by admin or governance
    function updateMinStakePeriod(
        uint256 _pid,
        uint256 _minStakePeriod
    ) public override onlyManagerOrGovernance {
        require(
            _isInitialized,
            "Pool::updateMinStakePeriod: POOL_NOT_INITIALIZED"
        );
        require(
            _pid < poolInfo.length,
            "Pool::updateMinStakePeriod: INVALID_PID"
        );
        require(
            poolInfo[_pid].startBlock > block.number,
            "Pool::updateMinStakePeriod: STAKING_STARTED"
        );
        poolInfo[_pid].minStakePeriod = _minStakePeriod;

        emit MinStakePeriodSet(
            _pid,
            _minStakePeriod
        );
    }

    // Update the given pool's bonus data. Can only be called by admin or governance
    function updateBonus(
        uint256 _pid,
        uint256 _bonusEndBlock,
        uint256 _bonusMultiplier
    ) public override onlyManagerOrGovernance {
        require(
            _isInitialized,
            "Pool::updateBonus: POOL_NOT_INITIALIZED"
        );
        require(
            _pid < poolInfo.length,
            "Pool::updateBonus: INVALID_PID"
        );
        require(
            poolInfo[_pid].startBlock > block.number,
            "Pool::updateBonus: STAKING_STARTED"
        );
        require(
            poolInfo[_pid].startBlock <= _bonusEndBlock,
            "Pool::updateBonus: INVALID_BONUS_END_BLOCK"
        );

        poolInfo[_pid].bonusEndBlock = _bonusEndBlock;
        poolInfo[_pid].bonusMultiplier = _bonusMultiplier;

        updatePool(_pid);

        emit BonusDataSet(
            _pid,
            _bonusEndBlock,
            _bonusMultiplier
        );
    }

    // NOTE: need to approve _rewardAmount for transfer for this pool address from the caller before calling
    // Adds _rewardAmount to the rewardAmount for a given pool. Can only be called by admin or governance
    function addRewardAmount(
        uint256 _pid,
        uint256 _rewardAmount
    ) public override onlyManagerOrGovernance {
        require(
            _isInitialized,
            "Pool::addRewardAmount: POOL_NOT_INITIALIZED"
        );
        require(
            _pid < poolInfo.length,
            "Pool::addRewardAmount: INVALID_PID"
        );
        require(
            !mintable,
            "Pool::addRewardAmount: REWARD_MINTABLE"
        );
        uint256 oldAmount = poolInfo[_pid].rewardAmount;
        poolInfo[_pid].rewardAmount = oldAmount + _rewardAmount;
        // transfer added amount of tokens to be used as rewards for the pool at _pid
        TransferHelper.safeTransferFrom(rewardToken, _msgSender(), address(this), _rewardAmount);
 
        emit AddedRewardAmount(
            _pid,
            oldAmount,
            poolInfo[_pid].rewardAmount
        );
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _pid, uint256 _from, uint256 _to)
        public
        view
        override
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        if (_to <= pool.bonusEndBlock) {
            return _to - _from * pool.bonusMultiplier;
        } else if (_from >= pool.bonusEndBlock) {
            return _to - _from;
        } else {
            return ((pool.bonusEndBlock - _from) * pool.bonusMultiplier) + (_to - pool.bonusEndBlock);
        }
    }

    // View function to see pending REWARDs on frontend.
    function pendingSushi(uint256 _pid, address _user)
        external
        view
        override
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 stakeSupply = IERC20(pool.stakeToken).balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && stakeSupply != 0) {
            uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
            uint256 reward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
            accRewardPerShare = accRewardPerShare + ((reward * PRECISION_FACTOR) / stakeSupply);
        }
        uint256 result = ((user.amount * accRewardPerShare) / PRECISION_FACTOR) - user.rewardDebt;
        if(!mintable){
            if(result > pool.rewardAmount) {
                result = pool.rewardAmount;
            }
        }
        return result;
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public override {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public override {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 stakeSupply = IERC20(pool.stakeToken).balanceOf(address(this));
        
        if (stakeSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
        uint256 reward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;

        if(mintable){
            IERC20Mintable(rewardToken).mint(address(this), reward);
            pool.accRewardPerShare = pool.accRewardPerShare + ((reward * PRECISION_FACTOR) / stakeSupply);
        }
        
        if(block.number >= pool.startBlock) {
            pool.lastRewardBlock = block.number;
        }
    }

    // Deposit STAKE tokens to POOL for REWARD allocation.
    function deposit(uint256 _pid, uint256 _amount) public payable override {
        if(_pid > 0) {
            require(
                msg.value == 0,
                "Pool::deposit: INVALID_MSG_VALUE_ZERO"
            );
        } else {
            require(
                msg.value == _amount,
                "Pool::deposit: INVALID_MSG_VALUE_AMOUNT"
            );
        }
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        if (user.amount > 0) { // not the first deposit, so may have some existing REWARD payout pending
            uint256 pending = ((user.amount * pool.accRewardPerShare) / PRECISION_FACTOR) - user.rewardDebt;
            if(pending > 0) {
                if(!mintable){
                    uint256 reward;
                    if(pending <= pool.rewardAmount) {
                        reward = pending;
                        pool.rewardAmount = pool.rewardAmount - reward;
                    } else { // pending reward payout is larger than remaining pool REWARDs
                        reward = pool.rewardAmount;
                        pool.rewardAmount = 0;
                    }
                    _safeRewardTransfer(_msgSender(), reward );
                } else {
                    _safeRewardTransfer(_msgSender(), pending );
                }
            }
        }

        if (_amount > 0) {
            if(msg.value > 0) {
                IWNATIVE(nativeToken).deposit{value: msg.value}(); // this will trasfer the equivalent amount of wrapped tokens to this contract
            } else {
                TransferHelper.safeTransferFrom(
                    pool.stakeToken,
                    _msgSender(),
                    address(this),
                    _amount
                );
            }
            user.amount = user.amount + _amount;
        }

        user.rewardDebt = (user.amount * pool.accRewardPerShare) / PRECISION_FACTOR;
        emit Deposit(_msgSender(), _pid, _amount);
    }

    // Withdraw STAKED tokens from Pool.
    function withdraw(uint256 _pid, uint256 _amount) public override {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.amount >= _amount, "Pool::withdraw: INVALID_AMOUNT");
        updatePool(_pid);
        uint256 pending = ((user.amount * pool.accRewardPerShare) / PRECISION_FACTOR) - user.rewardDebt;
        if(pending > 0) {
            // enforce min block staking penalty for withdrawals (any penalty amount is paid to treasury)
            uint256 rewardPercentage = _calcRewardPercentage(pool.startBlock, pool.minStakePeriod);
            uint256 rewardToUser;
            uint256 rewardToTreasury;
            if(!mintable){
                uint256 reward;
                if(pending <= pool.rewardAmount) {
                    reward = pending;
                    pool.rewardAmount = pool.rewardAmount - reward;
                } else { // pending reward payout is larger than remaining pool REWARDs
                    reward = pool.rewardAmount;
                    pool.rewardAmount = 0;
                }
                rewardToUser = ((reward * rewardPercentage) / 10000);
                rewardToTreasury = reward - rewardToUser;
                _safeRewardTransfer(_msgSender(), rewardToUser);
                _safeRewardTransfer(treasury, rewardToTreasury);
            } else {
                rewardToUser = ((pending * rewardPercentage) / 10000);
                rewardToTreasury = pending - rewardToUser;
                _safeRewardTransfer(_msgSender(), rewardToUser);
                _safeRewardTransfer(treasury, rewardToTreasury);
            }
        }

        if(_amount > 0) {
            user.amount = user.amount - _amount;
            if( _pid > 0){
                 TransferHelper.safeTransfer(pool.stakeToken, _msgSender(), _amount);
            } else {
                IWNATIVE(nativeToken).withdraw(_amount);
                TransferHelper.safeTransferNative(_msgSender(), _amount);
            }
        }

        user.rewardDebt = (user.amount * pool.accRewardPerShare) / PRECISION_FACTOR;
        
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public override {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        if( _pid > 0){
            TransferHelper.safeTransfer(pool.stakeToken, _msgSender(), user.amount);
        } else {
            IWNATIVE(nativeToken).withdraw(user.amount);
            TransferHelper.safeTransferNative(_msgSender(), user.amount);
        }
        user.amount = 0;
        user.rewardDebt = 0;
        emit EmergencyWithdraw(_msgSender(), _pid, user.amount);
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external override onlyManagerOrGovernance {
    
        require(!staked[_tokenAddress], "Pool::recoverWrongTokens: STAKED_TOKEN");
        require(_tokenAddress != rewardToken, "Pool::recoverWrongTokens: REWARD_TOKEN");

        TransferHelper.safeTransfer(_tokenAddress, _msgSender(), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    // Safe reward token transfer function, just in case a rounding error causes the pool to not have enough reward tokens.
    function _safeRewardTransfer(address to, uint256 amount) internal {
        uint256 rewardBal = IERC20(rewardToken).balanceOf(address(this));
        if (amount > rewardBal) {
            TransferHelper.safeTransfer(rewardToken, to, rewardBal);
        } else {
            TransferHelper.safeTransfer(rewardToken, to, amount);
        }
    }

    // for calculating minimum staking period and linear reduction of rewards
    function _calcRewardPercentage(uint256 _startBlock, uint256 _minStakePeriod) internal view returns (uint256) {
        if(block.number >= _startBlock + _minStakePeriod) {
            return 10000; // 100.00%
        } else if (block.number > _startBlock) { // range 1 - 9999, .01% - 99.99%
            uint256 elapsed = block.number - _startBlock;
            return ((elapsed * 10000) / _minStakePeriod);
        } else {
            return 0; // 0%
        }
    }

    // internal add to expose to initialize() and callable
    function _add(
        address _stakeToken,
        uint256 _allocPoint,
        uint256 _startBlock,
        uint256 _bonusMultiplier,
        uint256 _bonusEndBlock,
        uint256 _minStakePeriod,
        uint256 _rewardAmount,
        bool _withUpdate
    ) internal {
        require(
            _isInitialized,
            "Pool::add: POOL_NOT_INITIALIZED"
        );
        require(
            !staked[_stakeToken],
            "Pool::add: STAKE_POOL_ALREADY_EXISTS"
        );
        require(
            _startBlock >= block.number,
            "Pool::add: INVALID_START_BLOCK"
        );

        require(
            _bonusMultiplier >= 1,
            "Pool::add: INVALID_BONUS_MULTIPLIER"
        );

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        
        PoolInfo storage newPool = poolInfo.push();
        newPool.stakeToken = _stakeToken;
        newPool.allocPoint = _allocPoint;
        newPool.lastRewardBlock = lastRewardBlock;
        newPool.accRewardPerShare = 0;
        newPool.bonusEndBlock = _bonusEndBlock;
        newPool.startBlock = _startBlock;
        newPool.minStakePeriod = _minStakePeriod;
        newPool.bonusMultiplier = _bonusMultiplier;

        if(!mintable) {
            if(_rewardAmount > 0){
                // transfer initial amount of tokens to be used as rewards for this pool
                TransferHelper.safeTransferFrom(rewardToken, _msgSender(), address(this), _rewardAmount);
                newPool.rewardAmount = _rewardAmount;
            }
        }

        emit PoolAdded(
            poolInfo.length - 1,
            _stakeToken,
            _allocPoint,
            _startBlock,
            _bonusMultiplier,
            _bonusEndBlock,
            _minStakePeriod
        );
    }
}