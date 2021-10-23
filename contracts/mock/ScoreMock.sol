// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../saver/libs/Score.sol";
import "../saver/SaverStructs.sol";

contract ScoreMock {
    constructor() {

    }

    function scoreCalculation(
         uint createTimestamp, 
         uint startTimestamp, 
         SaverStructs.Transaction [] calldata transactions, 
         uint count, 
         uint interval, 
         uint decimals 
    ) external pure returns (uint score) {
        score = Score.calculate(createTimestamp, startTimestamp, transactions, count, interval, decimals);
    }
}