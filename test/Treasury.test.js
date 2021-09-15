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

describe("Treasury", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    // context("Initailize", function() {
    //     it('should Success Treasury Initialize', async function() {
    //         const treasury = this.contracts.treasury;
    //         const ownableStorage = this.contracts.ownableStorage;
    //         const anwfiMock = this.contracts.anwfiMock;
    //         const grinder = this.contracts.grinder;

    //         await expect(treasury['initialize(address,address,address,address)'](ownableStorage.address, grinder.address, anwfiMock.address, UniswapAddresses.UniswapV2Router02 )).emit(treasury, "Initialize")
    //     })

    //     it('should revert Already initialized Treasury', async function() {
    //         const treasury = this.contracts.treasury;
    //         const ownableStorage = this.contracts.ownableStorage;
    //         const anwfiMock = this.contracts.anwfiMock;
    //         const grinder = this.contracts.grinder;

    //         await expect(treasury['initialize(address,address,address,address)'](ownableStorage.address, grinder.address, anwfiMock.address, UniswapAddresses.UniswapV2Router02 )).to.be.reverted
    //     })

    // })

    // context("SetUp", function() {
    
    //     it('should Revert addAsset Address Not AdminOrGovernance', async function() {
    //         const treasury = this.contracts.treasury
    //         const account1 = this.signers.account1
    //         await expect( treasury.connect(account1).addAsset(Tokens.Dai) ).to.be.reverted
    //     })
        
    //     it('should Success addAsset', async function() {
    //         const treasury = this.contracts.treasury
    //         const owner = this.signers.owner
    //         await expect(treasury.connect(owner).addAsset(Tokens.Dai)).emit(treasury, "AddAsset").withArgs(Tokens.Dai);
    //     })

    //     it('should Revert addAsset Already Registry Token', async function() {
    //         const treasury = this.contracts.treasury
    //         const owner = this.signers.owner
    //         await expect(treasury.connect(owner).addAsset(Tokens.Dai)).to.be.reverted
    //     })
        
    //     it('should Revert addAsset Buyback Test', async function() {
    //         const treasury = this.contracts.treasury
    //         const owner = this.signers.owner
    //         await treasury.connect(owner).buyBack()
    //     })
        
    //     // it('should Revert addAsset Buyback Test', async function() {
    //     //     const treasury = this.contracts.treasury
    //     //     const owner = this.signers.owner
    //     //     const DAI = this.contracts.daiContract
    //     //     const swapResult = await this.contracts.uniswapV2Router.connect(this.signers.owner).swapExactETHForTokens(
    //     //         10000000000,
    //     //         [Tokens.WETH, Tokens.Dai],
    //     //         treasury.address,
    //     //         Math.round(Date.now() / 1000) + 100000000000000,
    //     //         {value: "100000000000000000000", gasLimit: '2300000'}
    //     //     )
    //     //     await swapResult.wait()
    //     //     await treasury.connect(owner).buyBack()
    //     // })

    // })

});