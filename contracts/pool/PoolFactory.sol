// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../access/manager/ManagerRole.sol";
import "../access/governance/GovernanceRole.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "./interface/IPoolFactory.sol";

import "./Pool.sol";

contract PoolFactory is Context, IPoolFactory {

    using ManagerRole for RoleStore;
    using GovernanceRole for RoleStore;

    RoleStore private _s;

    address public override treasury;

    address public override WNATIVE;

    // map of created pools - by reward token
    mapping(address => address) public override rewardPools;

    modifier onlyManagerOrGovernance() {
        require(
            _s.isManager(_msgSender()) || _s.isGovernor(_msgSender()),
            "PoolFactory::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    constructor ( address _treasury, address _nativeToken ) { 
        treasury = _treasury;
        WNATIVE = _nativeToken; // @dev _nativeToken must be a wrapped native token or all subsequent pool logic will fail
        _s.initializeManagerRole(_msgSender());
    }

    // expose manager and governance getters
    function isManager(address account) external view override returns (bool) {
        return _s.isManager(account);
    }

    function isGovernor(address account) external view override returns (bool) {
        return _s.isGovernor(account);
    }

    /*
     * @notice Deploy a reward pool
     * @param _rewardToken: reward token address for POOL rewards
     * @param _rewardPerBlock: the amountof tokens to reward per block for the entire POOL
     * remaining parmas define the condition variables for the first NATIVE token staking pool for this REWARD
     */
    function deployPool(
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _nativeAllocPoint,
        uint256 _nativeStartBlock,
        uint256 _nativeBonusMultiplier,
        uint256 _nativeBonusEndBlock,
        uint256 _nativeMinStakePeriod
    ) external override onlyManagerOrGovernance {
        require(
            rewardPools[_rewardToken] == address(0),
            "PoolFactory::deployPool: REWARD_POOL_ALREADY_DEPLOYED"
        );

        bytes memory bytecode = type(Pool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_rewardToken, _rewardPerBlock, treasury, _nativeAllocPoint, _nativeStartBlock, _nativeBonusMultiplier, _nativeBonusEndBlock, _nativeMinStakePeriod));
        address poolAddress;

        assembly {
            poolAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        
        rewardPools[_rewardToken] = poolAddress;
        
        IPool(poolAddress).initialize(
            _rewardToken,
            _rewardPerBlock,
            treasury,
            WNATIVE,
            _nativeAllocPoint,
            _nativeStartBlock,
            _nativeBonusMultiplier,
            _nativeBonusEndBlock,
            _nativeMinStakePeriod
        );

        emit PoolCreated(_rewardToken, poolAddress);
    }

    // Update Treasury. NOTE: better for treasury to be upgradable so no need to use this.
    function setTreasury(address newTreasury) external override onlyManagerOrGovernance {
        treasury = newTreasury;
    }

    // Update Wrapped Native implementation, @dev this must be a wrapped native token or all subsequent pool logic can fail
    // NOTE: better for WNATIVE to be upgradable so no need to use this.
    function setNative(address newNative) external override onlyManagerOrGovernance {
        WNATIVE = newNative;
    }
}