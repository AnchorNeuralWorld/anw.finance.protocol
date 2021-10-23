// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface GovernanceRoleInterface {

    function addGovernor(address governor) external;

    function renounceGovernor() external;

    function removeGovernor(address governor) external;

    function isGovernor(address account) external view returns (bool);
    
}