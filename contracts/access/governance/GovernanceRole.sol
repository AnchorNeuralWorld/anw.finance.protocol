// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/* DATA STRUCT IMPORTS */

import "../RoleStore.sol";

/* LIBRARY IMPORTS */

import "../base/Roles.sol";
import "../manager/ManagerRole.sol";
import "../../util/ContextLib.sol";

library GovernanceRole {

    /* LIBRARY USAGE */
    
    using Roles for Role;
    using ManagerRole for RoleStore;

    /* EVENTS */

    event GovernanceAccountAdded(address indexed account, address indexed governor);
    event GovernanceAccountRemoved(address indexed account, address indexed governor);

    /* MODIFIERS */

    modifier onlyManagerOrGovernance(RoleStore storage s, address account) {
        require(
            s.isManager(account) || _isGovernor(s, account), 
            "GovernanceRole::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    /* EXTERNAL STATE CHANGE METHODS */

    /* a manager or existing governance account can add new governance accounts */
    function addGovernor(
        RoleStore storage s,
        address governor
    )
        external
        onlyManagerOrGovernance(s, ContextLib._msgSender())
    {
        _addGovernor(s, governor);
    }

    /* an Governance account can renounce thier own governor status */
    function renounceGovernance(
        RoleStore storage s
    )
        external
    {
        _removeGovernor(s, ContextLib._msgSender());
    }

    /* manger accounts can remove governance accounts */
    function removeGovernor(
        RoleStore storage s,
        address governor
    )
        external
    {
        require(s.isManager(ContextLib._msgSender()), "GovernanceRole::removeGovernance: NOT_MANAGER_ACCOUNT");
        _removeGovernor(s, governor);
    }

    /* EXTERNAL GETTER METHODS */

    function isGovernor(
        RoleStore storage s,
        address account
    )
        external
        view
        returns (bool)
    {
        return _isGovernor(s, account);
    }

    /* INTERNAL LOGIC METHODS */

    function _isGovernor(
        RoleStore storage s,
        address account
    )
        internal
        view
        returns (bool)
    {
        return s.governance.has(account);
    }

    function _addGovernor(
        RoleStore storage s,
        address governor
    )
        internal
    {
        require(
            governor != address(0), 
            "GovernanceRole::_addGovernor: INVALID_GOVERNOR_ZERO_ADDRESS"
        );
        
        s.governance.add(governor);

        emit GovernanceAccountAdded(ContextLib._msgSender(), governor);
    }

    function _removeGovernor(
        RoleStore storage s,
        address governor
    )
        internal
    {
        require(
            governor != address(0),
            "GovernanceRole::_removeGovernor: INVALID_GOVERNOR_ZERO_ADDRESS"
        );

        s.governance.remove(governor);

        emit GovernanceAccountRemoved(ContextLib._msgSender(), governor);
    }
}