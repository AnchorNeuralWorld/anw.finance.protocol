const { ethers } = require("hardhat");
const {
    UniswapV2Router02,
    UniswapFactoryV2,
    DAI,
    USDT,
    USDC
} = require('./contracts.js');
let owner;
async function deploy() {

    [owner, gov, daiAcct, acct1, acct2, acct3, ...others] = await ethers.getSigners();

    /* MOCK ANWFI DEPLOYMENT */
    const ANWFIMock = await ethers.getContractFactory("ANWFIMock" );

    const anwfiMock = await ANWFIMock.deploy(owner.address);
    await anwfiMock.deployed();

     /* LIBRARIES */
    const CommitmentWeight = await ethers.getContractFactory("CommitmentWeight")
    const commitmentWeight = await CommitmentWeight.deploy()
    await commitmentWeight.deployed()

    const Score = await ethers.getContractFactory("Score", {
        libraries: {
            CommitmentWeight: commitmentWeight.address
        }
    });
    const score = await Score.deploy()
    await score.deployed();

    /* MOCK SCORE */
    const ScoreMock = await ethers.getContractFactory("ScoreMock", {
        libraries: {
            Score: score.address,
        }
    });
    const scoreMock = await ScoreMock.deploy();
    await scoreMock.deployed();

    /* ERC20 ASSIGNMENT */

    const daiToken = await ethers.getContractAt("IERC20", DAI);
    const usdtToken = await ethers.getContractAt("IERC20", USDT);
    const usdcToken = await ethers.getContractAt("IERC20", USDC);

    /* MODEL DEPLOYMENT */

    const CompoundModel = await ethers.getContractFactory("CompoundModel");
    
    const compoundModelDAI = await CompoundModel.deploy();
    await compoundModelDAI.deployed();

    const compoundModelUSDT = await CompoundModel.deploy();
    await compoundModelUSDT.deployed();

    const compoundModelUSDC = await CompoundModel.deploy();
    await compoundModelUSDC.deployed();

    // const compoundModelETH = await CompoundModel.deploy();
    // await compoundModelETH.deployed();

    const Variables = await ethers.getContractFactory("Variables");
    const variables = await Variables.deploy();
    await variables.deployed();

    /* OWNABLE STORAGE (for FORGE PROXIES and OPERATOR TREASURY) */
    const OwnableStorage = await ethers.getContractFactory("OwnableStorage");
    const ownableStorage = await OwnableStorage.deploy();
    await ownableStorage.deployed();

    /* FORGE DEPLOYMENT */

    const Forge = await ethers.getContractFactory("Forge", {
        libraries: {
            Score: score.address,
        }
    });

    // DAI COMPOUND
    const forge1 = await Forge.deploy();
    await forge1.deployed();

    // USDT COMPOUND
    const forge2 = await Forge.deploy();
    await forge2.deployed();

    // USDC COMPOUND
    const forge3 = await Forge.deploy();
    await forge3.deployed();

    // // ETH COMPOUND
    // const forge4 = await Forge.deploy();
    // await forge4.deployed();

    /* PROXY DEPLOYMENT */
    const ForgeProxy = await ethers.getContractFactory("ForgeProxy");

    const forge1Proxy = await ForgeProxy.deploy();
    await forge1Proxy.deployed();

    const forge2Proxy = await ForgeProxy.deploy();
    await forge2Proxy.deployed();

    const forge3Proxy = await ForgeProxy.deploy();
    await forge3Proxy.deployed();

    // const forge4Proxy = await ForgeProxy.deploy();
    // await forge4Proxy.deployed();

    const Referral = await ethers.getContractFactory("Referral");
    const referral = await Referral.deploy();
    await referral.deployed();

    const Treasury = await ethers.getContractFactory("Treasury");
    const treasury = await Treasury.deploy();
    await treasury.deployed();

    const OperatorTreasury = await ethers.getContractFactory("OperatorTreasury");
    const operatorTreasury = await OperatorTreasury.deploy(ownableStorage.address);
    await operatorTreasury.deployed();

    const Grinder = await ethers.getContractFactory("Grinder");
    const grinder = await Grinder.deploy(anwfiMock.address);
    await grinder.deployed();

    const RewardPool = await ethers.getContractFactory("RewardPool");
    const rewardPool = await RewardPool.deploy();
    await rewardPool.deployed();

    const RewardPoolProxy = await ethers.getContractFactory("RewardPoolProxy");
    const rewardPoolProxy = await RewardPoolProxy.deploy();
    await rewardPoolProxy.deployed();

    const uniswapV2Router = await ethers.getContractAt("IUniswapV2Router", UniswapV2Router02);

    const uniswapV2Factory = await ethers.getContractAt("IUniswapV2Factory", UniswapFactoryV2);

    await uniswapV2Factory.createPair( anwfiMock.address, await uniswapV2Router.WETH() );

    return {
        anwfiMock,
        commitmentWeight,
        score,
        scoreMock,
        daiToken,
        usdtToken,
        usdcToken,
        compoundModelDAI,
        compoundModelUSDT,
        compoundModelUSDC,
        variables,
        ownableStorage,
        forge1,
        forge2,
        forge3,
        forge1Proxy,
        forge2Proxy,
        forge3Proxy,
        referral,
        treasury,
        operatorTreasury,
        grinder,
        rewardPool,
        rewardPoolProxy,
        uniswapV2Router,
        uniswapV2Factory
    };
}

module.exports = deploy;