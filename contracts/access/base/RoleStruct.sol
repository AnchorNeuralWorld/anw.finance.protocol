// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/* STRUCTS */

struct Role {
    mapping (address => bool) bearer;
    uint256 numberOfBearers;
}