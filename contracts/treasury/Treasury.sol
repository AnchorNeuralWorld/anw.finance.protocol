// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../access/manager/ManagerRole.sol";
import "../access/governance/GovernanceRole.sol";

import "../util/TransferHelper.sol";

contract Treasury is Context {
    using ManagerRole for RoleStore;
    using GovernanceRole for RoleStore;

    RoleStore private _s;

    modifier onlyManagerOrGovernance() {
        require(
            _s.isManager(_msgSender()) || _s.isGovernor(_msgSender()),
            "Treasury::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    // expose manager and governance getters
    function isManager(address account) external view returns (bool) {
        return _s.isManager(account);
    }

    function isGovernor(address account) external view returns (bool) {
        return _s.isGovernor(account);
    }

    constructor() {
        _s.initializeManagerRole(_msgSender());
    }

    function transfer( address token, address to, uint256 amount ) public onlyManagerOrGovernance {
        TransferHelper.safeTransfer(token, to, amount);
    }

    function transferNative( address to, uint256 value ) public onlyManagerOrGovernance {
        TransferHelper.safeTransferNative(to, value);
    }

    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
}