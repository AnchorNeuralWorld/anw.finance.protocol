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

describe("Score", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    //     context("Score model test", function() {
    //         it("Calculate score correctly", async function() {
    //             const createTimestamp = 1622520000 // 2021-06-01 00:00:00
    //             const startTimestamp = 1638334800 // 2021-12-01 00:00:00
    //             const count = 1;
    //             const interval = 1;
    //             const transactions = [
    //                 { 
    //                     timestamp:1622520000,
    //                     amount:100000,
    //                     pos: true,
    //                 },
    //                 { 
    //                     timestamp:1622520000,
    //                     amount:100000, 
    //                     pos: true,
    //                 },
    //                 { 
    //                     timestamp:1622520000,
    //                     amount:100000,
    //                     pos: true,
    //                 } 
    //             ];

    //             const scoreResult = await this.contracts.scoreMock.scoreCalculation(
    //                 createTimestamp,
    //                 startTimestamp,
    //                 transactions,
    //                 count,
    //                 interval,
    //                 8
    //             )
                
    //             await expect(scoreResult).to.be.equal(55659665)
    //         })
    //     })
    // })

});