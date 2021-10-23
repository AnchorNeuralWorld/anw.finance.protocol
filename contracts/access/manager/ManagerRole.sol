// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/* DATA STRUCT IMPORTS */

import "../RoleStore.sol";

/* LIBRARY IMPORTS */

import "../base/Roles.sol";
import "../../util/ContextLib.sol";

library ManagerRole {
    /* LIBRARY USAGE */
    
    using Roles for Role;

    /* EVENTS */

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);

    /* MODIFIERS */

    modifier onlyUninitialized(RoleStore storage s) {
        require(!s.initialized, "ManagerRole::onlyUninitialized: ALREADY_INITIALIZED");
        _;
    }

    modifier onlyInitialized(RoleStore storage s) {
        require(s.initialized, "ManagerRole::onlyInitialized: NOT_INITIALIZED");
        _;
    }

    modifier onlyManager(RoleStore storage s) {
        require(s.managers.has(ContextLib._msgSender()), "ManagerRole::onlyManager: NOT_MANAGER");
        _;
    }

    /* INITIALIZE METHODS */
    
    // NOTE: call only in calling contract context initialize function(), do not expose anywhere else
    function initializeManagerRole(
        RoleStore storage s,
        address account
    )
        external
        onlyUninitialized(s)
     {
        _addManager(s, account);
        s.initialized = true;
    }

    /* EXTERNAL STATE CHANGE METHODS */
    
    function addManager(
        RoleStore storage s,
        address account
    )
        external
        onlyManager(s)
        onlyInitialized(s)
    {
        _addManager(s, account);
    }

    function renounceManager(
        RoleStore storage s
    )
        external
        onlyInitialized(s)
    {
        _removeManager(s, ContextLib._msgSender());
    }

    /* EXTERNAL GETTER METHODS */

    function isManager(
        RoleStore storage s,
        address account
    )
        external
        view
        returns (bool)
    {
         return s.managers.has(account);
    }

    /* INTERNAL LOGIC METHODS */

    function _addManager(
        RoleStore storage s,
        address account
    )
        internal
    {
        s.managers.add(account);
        emit ManagerAdded(account);
    }

    function _removeManager(
        RoleStore storage s,
        address account
    )
        internal
    {
        s.managers.safeRemove(account);
        emit ManagerRemoved(account);
    }
}