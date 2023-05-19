import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deployer } = await getNamedAccounts();

  const rateProviderAddress = "";

  await deployments.deploy("CrossChainRateReceiver", {
    args: [rateProviderAddress],
    from: deployer,
    log: true,
  });
};

export default deploy;
