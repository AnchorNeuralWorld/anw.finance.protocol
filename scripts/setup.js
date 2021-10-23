const fs = require('fs');
const path = require('path');
const { ethers } = require("hardhat");
const hre = require("hardhat");
const deploy = require('./deploy');
const filePath = path.join(__dirname, '.', `config.json`);

async function main() {
    await hre.run('compile');
    let config = require(filePath);
    const network = await ethers.provider.getNetwork();
    let contracts = {};
    if ((!config[network.chainId] || !config[network.chainId].anw) || network.chainId == 31337) {
        contracts = await deploy();
    } else {
        const ANWERC20 = await ethers.getContractFactory("ANWMock");
        contracts.anw = await ANWERC20.attach(config[network.chainId].anw);
        const WNATIVE = await ethers.getContractFactory("WNATIVE");
        contracts.WNATIVE = await WNATIVE.attach(config[network.chainId].WNATIVE);
        const ProtocolToken = await ethers.getContractFactory("ProtocolToken");
        contracts.anwfi = await ProtocolToken.attach(config[network.chainId].anwfi);

        const PairFactory = await ethers.getContractFactory("PairFactory");
        contracts.pairFactory = await PairFactory.attach(config[network.chainId].pairFactory);
    }

    await contracts.pairFactory.createPair(contracts.anw.address, contracts.WNATIVE.address);
    // Make ANW-WETH pair
    const ANW_WETH_PAIR = await contracts.pairFactory.getPair(contracts.anw.address, contracts.WNATIVE.address);

    config[network.chainId].pairs = {};
    config[network.chainId].pairs.anw_weth = ANW_WETH_PAIR;
    
    // Make ANWFI-WETH pair
    await contracts.pairFactory.createPair(contracts.anwfi.address, contracts.WNATIVE.address);
    const ANWFI_WETH_PAIR = await contracts.pairFactory.getPair(contracts.anwfi.address, contracts.WNATIVE.address);
    config[network.chainId].pairs.anwfi_weth = ANWFI_WETH_PAIR;
    
    // Make ANWFI-ANW pair
    await contracts.pairFactory.createPair(contracts.anwfi.address, contracts.anw.address);
    const ANWFI_ANW_PAIR = await contracts.pairFactory.getPair(contracts.anwfi.address, contracts.anw.address);
    config[network.chainId].pairs.anwfi_anw = ANWFI_ANW_PAIR;
    // Make ANFI POOL - auto makes ETH STAKE for ANWFI pool
    await contracts.poolFactory.deployPool(
        contracts.anwfi.address,
        ethers.utils.parseEther("100"),
        100,
        (await ethers.provider.getBlockNumber()) + 1,
        1,
        (await ethers.provider.getBlockNumber()) + 1,
        136500
    );
    
    const anwfiPool = await contracts.poolFactory.rewardPools(contracts.anwfi.address);
    config[network.chainId].pools = {};
    config[network.chainId].pools.anwfi = {};
    config[network.chainId].pools.anwfi.address = anwfiPool;

    const Pool = await ethers.getContractFactory("Pool");
    const ANWFIPool = await Pool.attach(anwfiPool);

    const anwfiETHPoolData = await ANWFIPool.poolInfo(0);
    config[network.chainId].pools.anwfi[0] = {};
    config[network.chainId].pools.anwfi[0].stakeToken = anwfiETHPoolData.stakeToken;
    config[network.chainId].pools.anwfi[0].allocPoint = anwfiETHPoolData.allocPoint.toString();
    config[network.chainId].pools.anwfi[0].lastRewardBlock = anwfiETHPoolData.lastRewardBlock.toString();
    config[network.chainId].pools.anwfi[0].accRewardPerShare = anwfiETHPoolData.accRewardPerShare.toString();
    config[network.chainId].pools.anwfi[0].bonusEndBlock = anwfiETHPoolData.bonusEndBlock.toString();
    config[network.chainId].pools.anwfi[0].startBlock = anwfiETHPoolData.startBlock.toString();
    config[network.chainId].pools.anwfi[0].minStakePeriod = anwfiETHPoolData.minStakePeriod.toString();
    config[network.chainId].pools.anwfi[0].bonusMultiplier = anwfiETHPoolData.bonusMultiplier.toString();
    config[network.chainId].pools.anwfi[0].rewardAmount = anwfiETHPoolData.rewardAmount.toString();

    // Make ANW STAKE
    await ANWFIPool.add(
        contracts.anw.address,
        200,
        (await ethers.provider.getBlockNumber()) + 1,
        1,
        (await ethers.provider.getBlockNumber()) + 1,
        136500,
        0,
        true
    );

    const anwfiANWPoolData = await ANWFIPool.poolInfo(1);
    config[network.chainId].pools.anwfi[1] = {};
    config[network.chainId].pools.anwfi[1].stakeToken = anwfiANWPoolData.stakeToken;
    config[network.chainId].pools.anwfi[1].allocPoint = anwfiANWPoolData.allocPoint.toString();
    config[network.chainId].pools.anwfi[1].lastRewardBlock = anwfiANWPoolData.lastRewardBlock.toString();
    config[network.chainId].pools.anwfi[1].accRewardPerShare = anwfiANWPoolData.accRewardPerShare.toString();
    config[network.chainId].pools.anwfi[1].bonusEndBlock = anwfiANWPoolData.bonusEndBlock.toString();
    config[network.chainId].pools.anwfi[1].startBlock = anwfiANWPoolData.startBlock.toString();
    config[network.chainId].pools.anwfi[1].minStakePeriod = anwfiANWPoolData.minStakePeriod.toString();
    config[network.chainId].pools.anwfi[1].bonusMultiplier = anwfiANWPoolData.bonusMultiplier.toString();
    config[network.chainId].pools.anwfi[1].rewardAmount = anwfiANWPoolData.rewardAmount.toString();
    
    // Make ANW-WETH LP STAKE
    await ANWFIPool.add(
        config[network.chainId].pairs.anw_weth,
        50,
        (await ethers.provider.getBlockNumber()) + 1,
        1,
        (await ethers.provider.getBlockNumber()) + 1,
        136500,
        0,
        true
    );

    const anwfiANWWETHLPPoolData = await ANWFIPool.poolInfo(2);
    config[network.chainId].pools.anwfi[2] = {};
    config[network.chainId].pools.anwfi[2].stakeToken = anwfiANWWETHLPPoolData.stakeToken;
    config[network.chainId].pools.anwfi[2].allocPoint = anwfiANWWETHLPPoolData.allocPoint.toString();
    config[network.chainId].pools.anwfi[2].lastRewardBlock = anwfiANWWETHLPPoolData.lastRewardBlock.toString();
    config[network.chainId].pools.anwfi[2].accRewardPerShare = anwfiANWWETHLPPoolData.accRewardPerShare.toString();
    config[network.chainId].pools.anwfi[2].bonusEndBlock = anwfiANWWETHLPPoolData.bonusEndBlock.toString();
    config[network.chainId].pools.anwfi[2].startBlock = anwfiANWWETHLPPoolData.startBlock.toString();
    config[network.chainId].pools.anwfi[2].minStakePeriod = anwfiANWWETHLPPoolData.minStakePeriod.toString();
    config[network.chainId].pools.anwfi[2].bonusMultiplier = anwfiANWWETHLPPoolData.bonusMultiplier.toString();
    config[network.chainId].pools.anwfi[2].rewardAmount = anwfiANWWETHLPPoolData.rewardAmount.toString();

    // ANWFI-WETH LP STAKE
    await ANWFIPool.add(
        config[network.chainId].pairs.anwfi_weth,
        50,
        (await ethers.provider.getBlockNumber()) + 1,
        1,
        (await ethers.provider.getBlockNumber()) + 1,
        136500,
        0,
        true
    );

    const anwfiANWFIWETHLPPoolData = await ANWFIPool.poolInfo(3);
    config[network.chainId].pools.anwfi[3] = {};
    config[network.chainId].pools.anwfi[3].stakeToken = anwfiANWFIWETHLPPoolData.stakeToken;
    config[network.chainId].pools.anwfi[3].allocPoint = anwfiANWFIWETHLPPoolData.allocPoint.toString();
    config[network.chainId].pools.anwfi[3].lastRewardBlock = anwfiANWFIWETHLPPoolData.lastRewardBlock.toString();
    config[network.chainId].pools.anwfi[3].accRewardPerShare = anwfiANWFIWETHLPPoolData.accRewardPerShare.toString();
    config[network.chainId].pools.anwfi[3].bonusEndBlock = anwfiANWFIWETHLPPoolData.bonusEndBlock.toString();
    config[network.chainId].pools.anwfi[3].startBlock = anwfiANWFIWETHLPPoolData.startBlock.toString();
    config[network.chainId].pools.anwfi[3].minStakePeriod = anwfiANWFIWETHLPPoolData.minStakePeriod.toString();
    config[network.chainId].pools.anwfi[3].bonusMultiplier = anwfiANWFIWETHLPPoolData.bonusMultiplier.toString();
    config[network.chainId].pools.anwfi[3].rewardAmount = anwfiANWFIWETHLPPoolData.rewardAmount.toString();

    // ANWFI-ANW LP STAKE
    await ANWFIPool.add(
        config[network.chainId].pairs.anwfi_anw,
        50,
        (await ethers.provider.getBlockNumber()) + 1,
        1,
        (await ethers.provider.getBlockNumber()) + 1,
        136500,
        0,
        true
    );

    const anwfiANWFIANWLPPoolData = await ANWFIPool.poolInfo(4);
    config[network.chainId].pools.anwfi[4] = {};
    config[network.chainId].pools.anwfi[4].stakeToken = anwfiANWFIANWLPPoolData.stakeToken;
    config[network.chainId].pools.anwfi[4].allocPoint = anwfiANWFIANWLPPoolData.allocPoint.toString();
    config[network.chainId].pools.anwfi[4].lastRewardBlock = anwfiANWFIANWLPPoolData.lastRewardBlock.toString();
    config[network.chainId].pools.anwfi[4].accRewardPerShare = anwfiANWFIANWLPPoolData.accRewardPerShare.toString();
    config[network.chainId].pools.anwfi[4].bonusEndBlock = anwfiANWFIANWLPPoolData.bonusEndBlock.toString();
    config[network.chainId].pools.anwfi[4].startBlock = anwfiANWFIANWLPPoolData.startBlock.toString();
    config[network.chainId].pools.anwfi[4].minStakePeriod = anwfiANWFIANWLPPoolData.minStakePeriod.toString();
    config[network.chainId].pools.anwfi[4].bonusMultiplier = anwfiANWFIANWLPPoolData.bonusMultiplier.toString();
    config[network.chainId].pools.anwfi[4].rewardAmount = anwfiANWFIANWLPPoolData.rewardAmount.toString();

    await new Promise( async (resolve, reject) => {
        fs.writeFile(filePath, JSON.stringify(config, null, 2), function writeJSON(err) {
            if (err) return console.log(err);
            console.log(`writing to 'config.json'`);
            resolve(true);
        });
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });