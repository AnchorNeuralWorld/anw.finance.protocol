const { expect } = require("chai");
const { ethers } = require("hardhat");

const {
    ZERO_ADDRESS,
    BYTES_ZERO,
    MAX_UINT256,
    MAX_INT256,
    MIN_INT256,
    TEN_POW_18
  } = require('./setup/constants');
const {
    DAI,
    USDT,
    USDC,
    WETH,
    COMP,
    Comptroller,
    cDAI,
    cUSDT,
    cUSDC,
    cETH,
    UniswapV2Router02,
    UniswapFactoryV2
} = require('./setup/contracts');

const deploy = require('./setup/deployment');

let deployed;

let owner;
let acct1;
let acct2;

describe("Referral", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    // context("SetUp", function() {

    //     it('should Success Issue ReferralCode & Revert Already Issue', async function() {
    //         const referral = this.contracts.referral
    //         const account1 = this.signers.account1
    //         await referral.issue(account1.address);
    //         await expect( referral.issue(account1.address) ).to.be.reverted
    //     })

    //     it('should Check & Validate', async function() {
    //         const referral = this.contracts.referral
    //         const account1 = this.signers.account1
    //         const address = await referral.referralCode( account1.address );
    //         await expect( await referral.validate( address ) ).to.be.eq( account1.address )
    //     })

    // })

});