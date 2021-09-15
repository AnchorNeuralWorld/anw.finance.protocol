// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ANWFIMock is ERC20{
    constructor( address minter ) ERC20("ANW Finance", "ANWFI"){
        _mint(minter, 1000000000 ether);
    }
}