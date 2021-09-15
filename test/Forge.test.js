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

describe("Forge", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    // context("Initailize", function() {

    //     it('should Success Forge Initialize', async function() {
    //         const forge = this.contracts.forge;
    //         const ownableStorage = this.contracts.ownableStorage;
    //         const variables = this.contracts.variables;
    //         const compoundModel = this.contracts.compoundModel;

    //         await expect(forge.initializeForge(
    //             ownableStorage.address,
    //             variables.address,
    //             "Forge-DAI-0",
    //             "cDAI",
    //             compoundModel.address,
    //             Tokens.Dai,
    //             18
    //         )).emit(forge, "Initialize")
    //     })

    //     it('should Revert Forge Initialize', async function() {
    //         const ownableStorage = this.contracts.ownableStorage;
    //         const variables = this.contracts.variables;
    //         const compoundModel = this.contracts.compoundModel;

    //         await expect(this.contracts.forge.connect(this.signers.owner).initializeForge(
    //             ownableStorage.address,
    //             variables.address,
    //             "Forge-DAI-0",
    //             "cDAI",
    //             compoundModel.address,
    //             Tokens.Dai,
    //             18
    //         )).to.be.reverted
    //     })

    // })

    // context("Saver Behavior", function() {

    //     before(async function(){
    //         const uniswapV2Router = this.contracts.uniswapV2Router
    //         const accountDai = this.signers.accountDai
            
    //         const blockNumber = await ethers.provider.getBlockNumber()
    //         const blockInfo = await ethers.provider.getBlock(blockNumber)

    //         const swapResult = await uniswapV2Router.connect(accountDai).swapExactETHForTokens(
    //             1,
    //             [Tokens.WETH, Tokens.Dai],
    //             accountDai.address,
    //             blockInfo.timestamp + 25*60*60,
    //             {value: ethToWei("10"), gasLimit: '1300000'}
    //         )
    //         await swapResult.wait()
    //     })

    //     it('should Revert due to Allowance', async function() {
    //         const blockNumber = await ethers.provider.getBlockNumber()
    //         const blockInfo = await ethers.provider.getBlock(blockNumber)
    //         const startTimestamp = blockInfo.timestamp + 25 *60 * 60
    //         await expect(this.contracts.forge['craftingSaver(uint256,uint256,uint256,uint256)'](100, startTimestamp, 1, 1)).to.be.reverted
    //     })

    //     it('should Revert due to startTimestamp', async function() {
    //         const blockNumber = await ethers.provider.getBlockNumber()
    //         const blockInfo = await ethers.provider.getBlock(blockNumber)
    //         await expect(this.contracts.forge['craftingSaver(uint256,uint256,uint256,uint256)'](100, blockInfo.timestamp, 1, 1)).to.be.reverted
    //     })

    //     it('should Success craftingSaver', async function () {
    //         const blockNumber = await ethers.provider.getBlockNumber()
    //         const blockInfo = await ethers.provider.getBlock(blockNumber)
    //         const account = this.signers.accountDai
    //         const forgeDai = this.contracts.forge
    //         const daiContract = this.contracts.daiContract;


    //         const startTimestamp = blockInfo.timestamp + 25 *60 * 60
    //         const saverIndex = await forgeDai.connect(account).countByAccount(account.address)
    //         const balance = await daiContract.balanceOf( account.address );

    //         await daiContract.connect(account).approve(forgeDai.address, ethToWei("100000"))
    //         await expect(forgeDai
    //             .connect(account)['craftingSaver(uint256,uint256,uint256,uint256)'](balance.div(3).toString(), startTimestamp, 1, 1))
    //             .to.emit(forgeDai, 'CraftingSaver')
    //             .withArgs(account.address, saverIndex, balance.div(3).toString())

    //     })

    //     it('should Success addDeposit', async function() {
    //         const prevTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length;
    //         await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 1000000)).to.emit(this.contracts.forge, 'AddDeposit').withArgs(this.signers.accountDai.address, 0, 1000000)
    //         let afterTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length
    //         await expect(afterTransactionCount).to.be.eq(prevTransactionCount, "Transaction is not added");

    //         // increase time 86400 secs
    //         await network.provider.send("evm_increaseTime", [86400]);
    //         await network.provider.send("evm_mine")
    //         await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 1000000))
    //             .to.emit(this.contracts.forge, 'AddDeposit')
    //             .withArgs(this.signers.accountDai.address, 0, 1000000)
            
    //             afterTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length
            
    //         await expect(afterTransactionCount).to.be.eq(prevTransactionCount + 1, "Transaction is not added");
    //     })

    //     it('should Revert withdraw Not yet', async function() {
    //         const forge = this.contracts.forge;
    //         const account = this.signers.accountDai
    //         await expect( forge.connect(account).withdraw(1) ).to.be.reverted
    //     })

    //     it('should Success withdraw', async function() {
    //         await network.provider.send("evm_increaseTime", [86400]);
    //         await network.provider.send("evm_mine")

    //         const forge = this.contracts.forge;
    //         const account = this.signers.accountDai
    //         const withdrawable = await forge.connect(account).withdrawable(account.address, 0);
    //         await expect(forge.connect(account).withdraw(0, 100000000000000)).emit(forge, "Withdraw")
    //     })

    //     it('should Success terminateSaver', async function() {
    //         await this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)
    //         await expect(this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)).to.be.reverted
    //         await expect(this.contracts.forge.connect(this.signers.accountDai).withdraw(0, 100)).to.be.reverted
    //         await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 100)).to.be.reverted
    //     })

    // })
});