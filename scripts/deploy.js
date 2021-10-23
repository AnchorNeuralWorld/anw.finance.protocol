const fs = require('fs');
const path = require('path');
const { ethers } = require("hardhat");
const hre = require("hardhat");
const filePath = path.join(__dirname, '.', `config.json`);

async function main() {
    await hre.run('compile');
    const signer = await ethers.getSigner();
    
    let config = require(filePath);
    const network = await ethers.provider.getNetwork();

    /* ANW ERC20 */
    const ANWERC20 = await ethers.getContractFactory("ANWMock");

    const anw = await ANWERC20.deploy();
    await anw.deployed();

    config[network.chainId]  = {};
    config[network.chainId].anw = anw.address;

    /* ACCESS LIBRARIES */
    const MangaerRole = await ethers.getContractFactory("ManagerRole");
    const managers = await MangaerRole.deploy();
    await managers.deployed();
    config[network.chainId].manager_role_lib = managers.address;

    
    const GovernanceRole = await ethers.getContractFactory("GovernanceRole",
        {
            libraries: {
                ManagerRole: managers.address
            }
        }
    );
    const governance = await GovernanceRole. deploy();
    await governance.deployed();
    config[network.chainId].governance_role_lib = governance.address;

    /* TREASURY */
    const Treasury = await ethers.getContractFactory("Treasury",
        {
            libraries: {
                ManagerRole: managers.address,
                GovernanceRole: governance.address
            }
        }
    );
    const treasury = await Treasury.deploy();
    await treasury.deployed();
    config[network.chainId].treasury = treasury.address;

    /* WRAPPED NATIVE TOKEN */
    const WNATIVE = await ethers.getContractFactory("WNATIVE",
        {
            libraries: {
                ManagerRole: managers.address,
                GovernanceRole: governance.address
            }
        }
    );
    const wNATIVE = await WNATIVE.deploy("Wrapped ETH", "WETH");
    await wNATIVE.deployed();
    config[network.chainId].WNATIVE = wNATIVE.address;

    /* PAIR FACTORY */
    const PairFactory = await ethers.getContractFactory("PairFactory",
        {
            libraries: {
                ManagerRole: managers.address,
                GovernanceRole: governance.address
            }
        }
    );
    const pairFactory = await PairFactory.deploy(treasury.address);
    await pairFactory.deployed();
    config[network.chainId].pair_factory = pairFactory.address;

    /* ROUTER */
    const Router = await ethers.getContractFactory("Router");
    const router = await Router.deploy(pairFactory.address, wNATIVE.address);
    await router.deployed();
    config[network.chainId].router = router.address;

    /* POOL FACTORY */
    const PoolFactory = await ethers.getContractFactory("PoolFactory",
        {
            libraries: {
                ManagerRole: managers.address,
                GovernanceRole: governance.address
            }
        }
    );
    const poolFactory = await PoolFactory.deploy(treasury.address, wNATIVE.address);
    await poolFactory.deployed();
    config[network.chainId].pool_factory = poolFactory.address;

    /* PROTOCOL TOKEN */
    const ProtocolToken = await ethers.getContractFactory("ProtocolToken",
        {
            libraries: {
                ManagerRole: managers.address,
                GovernanceRole: governance.address
            }
        }
    );
    const anwfi = await ProtocolToken.deploy(poolFactory.address, "ANW Finance Token", "ANWFI");
    await anwfi.deployed();
    config[network.chainId].anwfi = anwfi.address;

    await new Promise( async (resolve, reject) => {
        fs.writeFile(filePath, JSON.stringify(config, null, 2), function writeJSON(err) {
            if (err) return console.log(err);
            console.log(`writing to 'config.json'`);
            resolve(true);
        });
    });

    return {
        anw: anw,
        managers: managers,
        govenance: governance,
        treasury: treasury,
        WNATIVE: wNATIVE,
        pairFactory: pairFactory,
        router: router,
        poolFactory: poolFactory,
        anwfi: anwfi
    };
    
}

async function deploy() {
    return main()
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = deploy;