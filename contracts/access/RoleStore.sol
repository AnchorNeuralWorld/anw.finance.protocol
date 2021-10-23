// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./base/RoleStruct.sol";

struct RoleStore {
    bool initialized;
    Role managers;
    Role governance;
}