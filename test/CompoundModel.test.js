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

describe("CompoundModel", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    describe("initialize()", function () {

        it('should revert Already initialized', async function() {
            await  deployed.compoundModelDAI.initialize(
                deployed.forge1.address,
                DAI,
                cDAI,
                COMP,
                Comptroller,
                UniswapV2Router02
            );

            await expect(deployed.compoundModelDAI.initialize(
                deployed.forge1.address,
                DAI,
                cDAI,
                COMP,
                Comptroller,
                UniswapV2Router02
            )).to.be.revertedWith("Initializable: contract is already initialized");
        });

        describe("initialize() success", function () {
            it('should initialize', async function() {
                await expect(deployed.compoundModelDAI.initialize(
                    deployed.forge1.address,
                    DAI,
                    cDAI,
                    COMP,
                    Comptroller,
                    UniswapV2Router02
                )).emit( deployed.compoundModelDAI, "Initialize" )
            });
        });

        // context("SetUp", function() {

        //     it('should Success transfer and invest', async function() {
        //         // const compoundModel = this.contracts.compoundModel
                
        //         // const daiContract = this.contracts.daiContract
        //         // const uniswapV2Router = this.contracts.uniswapV2Router
        //         // const accountDai = this.signers.accountDai
                
        //         // const blockNumber = await ethers.provider.getBlockNumber()
        //         // const blockInfo = await ethers.provider.getBlock(blockNumber)
    
        //         // const swapResult = await uniswapV2Router.connect(accountDai).swapExactETHForTokens(
        //         //     ethToWei("10"),
        //         //     [Tokens.WETH, Tokens.Dai],
        //         //     accountDai.address,
        //         //     blockInfo.timestamp + 25*60*60,
        //         //     {value: ethToWei("10"), gasLimit: '1300000'}
        //         // )
        //         // await swapResult.wait()
                
        //         // console.log( "balanceOf", ( await daiContract.balanceOf( accountDai.address ) ).toString() )
        //         // await expect( compoundModel.withdrawTo( forge.address, 100 ) ).to.be.reverted
                
        //         // const CDAI = await ethers.getContractAt("CTokenInterface", CompoundAddresses.cDai );
        //         // console.log("CDAI", CDAI)
        //     })
    
        //     it('should Revert withdrawTo', async function() {
        //         const compoundModel = this.contracts.compoundModel
        //         const forge = this.contracts.forge
        //         await expect( compoundModel.withdrawTo( forge.address, 100 ) ).to.be.reverted
        //     })
    
        //     it('should Revert withdrawToForge', async function() {
        //         const compoundModel = this.contracts.compoundModel
        //         await expect( compoundModel.withdrawToForge( 100 ) ).to.be.reverted
        //     })
    
        //     it('should Revert withdrawAllToForge', async function() {
        //         const compoundModel = this.contracts.compoundModel
        //         await expect( compoundModel.withdrawAllToForge() ).to.be.reverted
        //     })
    
        // })

    });
});
