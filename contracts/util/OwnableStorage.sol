// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract OwnableStorage {

    address public _admin;
    address public _governance;

    constructor() {
        _admin = msg.sender;
        _governance = msg.sender;
    }

    function setAdmin( address account ) public {
        require( isAdmin( msg.sender ), "OWNABLE STORAGE : Only Admin");
        _admin = account;
    }

    function setGovernance( address account ) public {
        require( isAdmin( msg.sender ) || isGovernance( msg.sender ), "OWNABLE STORAGE : Only Admin or Gov");
        _governance = account;
    }

    function isAdmin( address account ) public view returns( bool ) {
        return account == _admin;
    }

    function isGovernance( address account ) public view returns( bool ) {
        return account == _governance;
    }

}