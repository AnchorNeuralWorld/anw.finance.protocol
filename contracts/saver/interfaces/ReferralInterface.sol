// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface ReferralInterface{
    function validate( bytes12 code ) external view returns( address );
    function referralCode( address account ) external view returns( bytes12 );
}