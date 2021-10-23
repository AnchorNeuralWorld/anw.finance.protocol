// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface IPoolFactory {
    event PoolCreated(address indexed rewardToken, address indexed pool);

    function treasury() external view returns(address);

    function WNATIVE() external view returns(address);

    function rewardPools(address) external view returns(address);

    function isManager(address account) external view returns (bool);
    function isGovernor(address account) external view returns (bool);

    function deployPool(
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _nativeAllocPoint,
        uint256 _nativeStartBlock,
        uint256 _nativeBonusMultiplier,
        uint256 _nativeBonusEndBlock,
        uint256 _nativeMinStakePeriod
    ) external;

    function setTreasury(address newTreasury) external;
    function setNative(address newNative) external;

}