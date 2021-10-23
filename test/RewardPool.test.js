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

describe("RewardPool", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    // context("Initailize", function() {

    //     it('should Success RewardPool Initialize', async function() {
    //         const ownableStorage = this.contracts.ownableStorage;
    //         const rewardPool = this.contracts.rewardPool;
    //         const anwfiMock = this.contracts.anwfiMock;
    //         const owner = this.signers.owner;

    //         await expect(rewardPool.connect(owner).initializeReward(ownableStorage.address, anwfiMock.address)).emit(rewardPool, "Initialize")
    //     })

    //     it('should Revert Already initialized', async function() {
    //         const ownableStorage = this.contracts.ownableStorage;
    //         const rewardPool = this.contracts.rewardPool;
    //         const anwfiMock = this.contracts.anwfiMock;
    //         const owner = this.signers.owner;
    //         await expect(rewardPool.connect(owner).initializeReward(ownableStorage.address, anwfiMock.address)).to.be.reverted
    //     })

    //     it('should Success Transfer ANWFI For RewardPool', async function() {
    //         const anwfiMock = this.contracts.anwfiMock
    //         const rewardPool = this.contracts.rewardPool
    //         const owner = this.signers.owner
    //         await anwfiMock.connect(owner).transfer( rewardPool.address, ethToWei("10500000") );
    //         await expect( await anwfiMock.balanceOf(rewardPool.address) ).eq(BigNumber.from(ethToWei("10500000")))
    //         await expect( await rewardPool.getTotalReward() ).eq(BigNumber.from(ethToWei("10500000")))
    //     })

    // })

    // context("SetUp", function() {

    //     it('should Revert addForge Not Admin', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const account1 = this.signers.account1
    //         await expect( rewardPool.connect(account1).addForge( forge.address ) ).to.be.reverted
    //     })

    //     it('should Revert addForge address Gov', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const gov = this.signers.gov
    //         await expect( rewardPool.connect(gov).addForge( forge.address ) ).to.be.reverted
    //     })

    //     it('should Revert addForge Not Contract Address', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const owner = this.signers.owner
    //         await expect( rewardPool.connect(owner).addForge( owner.address ) ).to.be.reverted
    //     })

    //     it('should Success addForge 3 Items', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const forge2nd = this.contracts.forge2
    //         const forge3rd = this.contracts.forge3
    //         const owner = this.signers.owner
            
    //         await expect( rewardPool.connect(owner).addForge( forge.address ) ).emit(rewardPool, "AddForge").withArgs(forge.address)
    //         await expect( rewardPool.connect(owner).addForge( forge2nd.address ) ).emit(rewardPool, "AddForge").withArgs(forge2nd.address)
    //         await expect( rewardPool.connect(owner).addForge( forge3rd.address ) ).emit(rewardPool, "AddForge").withArgs(forge3rd.address)

    //         await expect( await rewardPool.checkForge( forge.address ) ).eq(true)
    //         await expect( await rewardPool.checkForge( forge2nd.address ) ).eq(true)
    //         await expect( await rewardPool.checkForge( forge3rd.address ) ).eq(true)
    //     })

    //     it('should Revert addForge Already Exist', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const owner = this.signers.owner
    //         await expect( rewardPool.connect(owner).addForge( forge.address ) ).to.be.reverted
    //     })

    //     it('should Revert setForge Overflow Max Value', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const owner = this.signers.owner
    //         const range:BigNumber[] = await rewardPool.getWeightRange(forge.address)
    //         const weight = range[range.length-1].toNumber() + 1
    //         await expect( rewardPool.connect(owner).setForge( forge.address, weight ) ).be.to.reverted
    //     })

    //     it('should Check weightRange Forge Counts 0', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const range:BigNumber[] = await rewardPool.getWeightRange(forge.address)
    //         // Only 0 : 500
    //         await expect( range[0].toNumber() ).eq( 0 )
    //         await expect( range[1].toNumber() ).eq( 500 )
    //     })

    //     it('should Success setForge', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const owner = this.signers.owner
    //         const weight = 10
    //         await expect( rewardPool.connect(owner).setForge( forge.address, weight ) ).emit(rewardPool, "SetForge").withArgs(forge.address, weight)
    //         await expect( await rewardPool.getWeight(forge.address) ).equal(weight)
    //     })

    //     it('should Check weightRange Forge Counts 1', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge2nd = this.contracts.forge2
    //         const range:BigNumber[] = await rewardPool.getWeightRange(forge2nd.address)
    //         // Only 10 : 10
    //         await expect( range[0].toNumber() ).eq( 10 )
    //         await expect( range[1].toNumber() ).eq( 10 )
    //     })

    //     it('should Success setForge 2nd', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge2nd = this.contracts.forge2
    //         const owner = this.signers.owner
    //         const weight = 10

    //         await expect( rewardPool.connect(owner).setForge( forge2nd.address, weight ) ).emit(rewardPool, "SetForge").withArgs(forge2nd.address, weight)
    //         await expect( await rewardPool.getWeight(forge2nd.address) ).equal(weight)
    //     })

    //     it('should Check weightRange Forge Counts 2', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge3rd = this.contracts.forge3
    //         const range:BigNumber[] = await rewardPool.getWeightRange(forge3rd.address)
    //         // Only 0 : 20
    //         await expect( range[0].toNumber() ).eq( 0 )
    //         await expect( range[1].toNumber() ).eq( 20 )
    //     })

    //     it('should Success setForge 3nd', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge3rd = this.contracts.forge3
    //         const owner = this.signers.owner
    //         const weight = 10
    //         await expect( rewardPool.connect(owner).setForge( forge3rd.address, weight ) ).emit(rewardPool, "SetForge").withArgs(forge3rd.address, weight)
    //         await expect( await rewardPool.getWeight(forge3rd.address) ).equal(weight)
    //     })

    //     it('should Check getWeightSum', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const forge = this.contracts.forge
    //         const forge2nd = this.contracts.forge2
    //         const forge3rd = this.contracts.forge3

    //         const forgeWeight = await rewardPool.getWeight( forge.address )
    //         const forge2ndWeight = await rewardPool.getWeight( forge2nd.address )
    //         const forge3rdWeight = await rewardPool.getWeight( forge3rd.address )

    //         await expect( await rewardPool.getWeightSum() ).eq( Number(forgeWeight) + Number(forge2ndWeight) + Number(forge3rdWeight) )
    //     })

    //     it('should Revert start Not Admin', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const account1 = this.signers.account1
    //         await expect( rewardPool.connect(account1).start()).to.be.reverted
    //     })

    //     it('should Success start', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const owner = this.signers.owner
    //         await expect( rewardPool.connect(owner).start()).emit(rewardPool,"Start")
    //         const blockNumber = await ethers.provider.getBlockNumber()
    //         await expect( (await rewardPool.getStartBlock()).toNumber()).eq(blockNumber)
    //     })

    //     it('should Revert start already started', async function() {
    //         const rewardPool = this.contracts.rewardPool
    //         const owner = this.signers.owner
    //         await expect( rewardPool.connect(owner).start()).to.be.reverted
    //     })

    // })

});