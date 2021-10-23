// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../../access/manager/ManagerRole.sol";

import "../../access/governance/GovernanceRole.sol";

import "./IWNATIVE.sol";

// Wrapped ETH/KLAY - simple wrapper around ERC20 functionality, plus deposit to mint and withdrawal to burn
contract WNATIVE is Context, IWNATIVE, ERC20 {
    using ManagerRole for RoleStore;
    using GovernanceRole for RoleStore;

    RoleStore private _s;

    event  Deposit(address indexed account, uint256 amount);

    event  Withdrawal(address indexed account, uint amount);

    modifier onlyManagerOrGovernance() {
        require(
            _s.isManager(_msgSender()) || _s.isGovernor(_msgSender()),
            "WNATIVE::onlyManagerOrGovernance: NOT_MANAGER_NOR_GOVERNANCE_ACCOUNT"
        );
        _;
    }

    constructor (string memory wrappedName, string memory wrappedSymbol) ERC20(wrappedName, wrappedSymbol) {
        _s.initializeManagerRole(_msgSender());
    }
    receive() external payable {
        deposit();
    }

    function deposit() public payable override {
        _mint(_msgSender(), msg.value);
        emit Deposit(_msgSender(), msg.value);
    }

    function transfer(address to, uint value) public override(ERC20, IWNATIVE) returns (bool) {
        return super.transfer(to, value);
    }
    
    function withdraw(uint256 amount) public override {
        _withdraw(payable(_msgSender()), amount);
    }

    function withdrawFor(address account, uint256 amount) public override {
        require(allowance(account, _msgSender()) >= amount);
        _withdraw(payable(_msgSender()), amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public override(ERC20, IWNATIVE) returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override(ERC20, IWNATIVE) returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) public override onlyManagerOrGovernance {
        IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
    }

    function _withdraw(address payable account, uint256 amount) internal {
        require(balanceOf(account) >= amount);
        _burn(account, amount);
        account.transfer(amount);
        emit Withdrawal(account, amount);
    }
}