// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface IPairFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    // function feeToSetter() external view returns (address); from UniV2 - not used here, we use role based permissioning instead

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    // function setFeeToSetter(address) external; from UniV2 - not used here, we use role based permissioning instead

    // added functions for Router permissioning on Pair contracts
    function setRouter(address) external;
    function router() external view returns (address);

}