// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ANWMock is IERC20Metadata, ERC20 {
    constructor() ERC20("Anchor Neural World Token", "ANW") {
        _mint(msg.sender, 1000000000 ether);
    }
}