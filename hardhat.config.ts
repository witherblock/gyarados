import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_RPC_URL || "",
        blockNumber: 17291300,
      },
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      accounts: process.env.PVK !== undefined ? [process.env.PVK] : [],
    },
    zkevm: {
      url: process.env.ZKEVM_RPC_URL,
      accounts: process.env.PVK !== undefined ? [process.env.PVK] : [],
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  paths: {
    deploy: "deploy/provider",
  },
};

export default config;
