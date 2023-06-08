import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deployer } = await getNamedAccounts();

  await deployments.deploy("REthRateReceiver", {
    args: [
      101,
      "0xB385BBc8Bfc80451cDbB6acfFE4D95671f4C051c",
      "0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4",
    ],
    from: deployer,
    log: true,
  });
};

export default deploy;
