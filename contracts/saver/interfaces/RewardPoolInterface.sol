// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface RewardPoolInterface {
    function addForge( address forge ) external;
    function setForge( address forge, uint weight ) external;
    function getWeightRange( address forge ) external view returns( uint, uint );

    function claim( ) external;
    function claim( address to ) external;
    function claim( address forge, address to ) external;
    function staking( address forge, uint amount ) external;
    function unstaking( address forge, uint amount ) external;
    function staking( address forge, uint amount, address from ) external;
    function unstaking( address forge, uint amount, address from ) external;
    
    function getClaim( address to ) external view returns( uint );
    function getClaim( address forge, address to ) external view returns( uint );
    
    function getWeightSum() external view returns( uint );
    function getWeight( address forge ) external view returns( uint );
    function getTotalDistributed( ) external view returns( uint );
    function getDistributed( address forge ) external view returns( uint );
    function getAllocation( ) external view returns( uint );
    function getAllocation( address forge ) external view returns( uint );
    function staked( address forge, address account ) external view returns( uint );
}