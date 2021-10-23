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

describe("OwnableStorage", function () {
    beforeEach(async function () {
        [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();
        
        deployed = await deploy();
    });

    // context("SetUp", function() {

    //     it('should Revert setAdmin Address Not Admin', async function() {
    //         const ownableStorage = this.contracts.ownableStorage
    //         const gov = this.signers.gov
    //         await expect( ownableStorage.connect(gov).setAdmin(gov.address) ).to.be.reverted
    //     })

    //     it('should Success setAdmin', async function() {
    //         const ownableStorage = this.contracts.ownableStorage
    //         const owner = this.signers.owner
    //         const gov = this.signers.gov
    //         await ownableStorage.connect(owner).setAdmin( gov.address );
    //         await expect( await ownableStorage.isAdmin( gov.address ) ).to.be.eq( true )
    //     })

    //     it('should Revert setAdmin by Governance', async function() {
    //         const ownableStorage = this.contracts.ownableStorage
    //         const owner = this.signers.gov
    //         const gov = this.signers.owner
    //         await expect( ownableStorage.connect(gov).setAdmin(owner.address) ).to.be.reverted
    //     })

    //     it('should Revert setGovernance Address Not Admin', async function() {
    //         const ownableStorage = this.contracts.ownableStorage
    //         const account2 = this.signers.account2
    //         await expect( ownableStorage.connect(account2).setGovernance(account2.address) ).to.be.reverted
    //     })

    //     it('should Success setGovernance by Admin', async function() {
    //         const ownableStorage = this.contracts.ownableStorage
    //         const owner = this.signers.gov
    //         const gov = this.signers.owner
    //         await ownableStorage.connect(owner).setGovernance( gov.address );
    //         await expect( await ownableStorage.isGovernance( gov.address ) ).to.be.eq( true )
    //     })

    //     it('should Revert setGovernance by Gov', async function() {
    //         const ownableStorage = this.contracts.ownableStorage
    //         const owner = this.signers.gov
    //         const gov = this.signers.owner
    //         await ownableStorage.connect(gov).setGovernance( owner.address );
    //         await expect( await ownableStorage.isGovernance( owner.address ) ).to.be.eq( true )
    //     })

    //     after(async function(){
    //         const ownableStorage = this.contracts.ownableStorage
    //         const owner = this.signers.owner
    //         const gov = this.signers.gov
    //         await ownableStorage.connect(gov).setAdmin(owner.address);
    //         await ownableStorage.connect(owner).setGovernance(gov.address);
    //     })
    // })

});