// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface ManagerRoleInterface {    

    function addManager(address account) external;

    function renounceManager() external;

    function isManager(address account) external view returns (bool);

}