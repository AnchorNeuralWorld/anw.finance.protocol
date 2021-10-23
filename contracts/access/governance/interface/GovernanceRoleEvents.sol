// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface GovernanceRoleEvents {

    event GovernanceAccountAdded(address indexed origin, address indexed governor);
    
    event GovernanceAccountRemoved(address indexed origin, address indexed governor);
    
}