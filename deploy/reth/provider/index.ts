import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deployer } = await getNamedAccounts();

  await deployments.deploy("REthRateProvider", {
    args: [158, "0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675"],
    from: deployer,
    log: true,
  });
};

export default deploy;
