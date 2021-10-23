// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./extension/checkpointable/ERC20Checkpointable.sol";

import "../../access/manager/ManagerRole.sol";
import "../../access/governance/GovernanceRole.sol";

import "../../pool/interface/IPoolFactory.sol";

// ANW Finanace token with Governance.
contract ProtocolToken is IERC20Metadata, ERC20, ERC20Checkpointable {
    using ManagerRole for RoleStore;
    using GovernanceRole for RoleStore;
    
    RoleStore private _s;

    address public poolFactory;

    modifier onlyManagerOrGovernance() {
        require(
            _s.isManager(_msgSender()) || _s.isGovernor(_msgSender()),
            "ProtocolToken::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    constructor (address _poolFactory, string memory _tokenName, string memory _tokenSymbol) ERC20(_tokenName, _tokenSymbol) { 
        poolFactory = _poolFactory;
        _s.initializeManagerRole(_msgSender());
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by a pool with this token as it's reward.
    function mint(address _to, uint256 _amount) public {
        require(
            _msgSender() == IPoolFactory(poolFactory).rewardPools(address(this)),
            "ProtocolToken::mint: FORBIDDEN"
        );
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public {
        _burn(_msgSender(), _amount);
    }

    function setFactory(address _poolFactory) public onlyManagerOrGovernance {
        poolFactory = _poolFactory;
    }

    // record checkpoint data after successful token transfer
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 oldFrom = balanceOf(from);
        uint256 oldTo = balanceOf(to);

        if (from != address(0)){ // no need to checkpoint the 0x0 address during mint
            _writeCheckpoint(from, oldFrom, oldFrom - amount);
        }

        if (to != address(0)) { // no need to checkpoint the 0x0 address during burn
            _writeCheckpoint(to, oldTo, oldTo + amount);
        }

    }

}