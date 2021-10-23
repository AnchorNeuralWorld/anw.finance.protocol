require('dotenv').config()
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
 
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
   const accounts = await hre.ethers.getSigners();
 
   for (const account of accounts) {
     console.log(account.address);
   }
 });

 /**
  * @type import('hardhat/config').HardhatUserConfig
  */
  module.exports = {
     defaultNetwork: "hardhat",
     networks: {
         hardhat: {
            //  forking: {
            //      url: "https://mainnet.infura.io/v3/"+process.env.INFURA_KEY
            //  },
            accounts: {
                mnemonic: process.env.MNEMONIC,
                count: 10,
                accountsBalance: "10000000000000000000000"
            },
            // accounts: [
            //     {
            //         privateKey: process.env.DEPLOYER_PRIVATE_KEY,
            //         balance: '10000000000000000000000'
            //     }
            // ],
             gasPrice: 150000000000 //GAS PRICE GWEI
        }
        //  mainnet: {
        //      url: "https://mainnet.infura.io/v3/"+process.env.INFURA_KEY,
        //      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
        //      gasPrice: 140000000000 // GAS PRICE GWEI
        //  }
     },
     solidity: {
         version: "0.8.4",
         settings: {
           optimizer: {
             enabled: true,
             runs: 200
           }
         }
       },
       etherscan: {
         apiKey: process.env.ETHERSCAN_KEY
       },
       mocha: {
        timeout: 120000
      }
 };
