// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./SaverStructs.sol";
import "./Variables.sol";

contract ForgeStorage{

    Variables internal _variables;
    address internal _model;
    address internal _token;
    uint internal _tokenUnit;

    string internal __name;
    string internal __symbol;
    uint8 internal __decimals;
    
    
    mapping( address => uint ) internal _tokensBalances;

    mapping( address => SaverStructs.Saver [] ) _savers;
    mapping( address => mapping( uint => SaverStructs.Transaction [] ) ) _transactions;

    // set to address
    uint internal _count;
    uint internal _totalScore;

    uint256[50] private ______gap;
}