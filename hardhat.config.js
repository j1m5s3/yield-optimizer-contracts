require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

const walletPrivateKey = process.env.DEPLOYER_WALLET_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [walletPrivateKey]
    }
  }
};
