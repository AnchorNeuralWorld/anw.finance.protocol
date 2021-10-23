// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @dev Interface of ERC20 Burn functionality.
 */

interface IERC20Burnable {

    function burn(address _from ,uint256 _amount) external;

}