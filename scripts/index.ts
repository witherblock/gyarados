import { ethers } from "hardhat";
import {
  CrossChainRateProvider__factory,
  CrossChainRateReceiver__factory,
} from "../typechain-types";

async function setDataOnRateProvider() {
  const signers = await ethers.getSigners();

  const rateProvider = CrossChainRateProvider__factory.connect(
    "0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d",
    signers[0]
  );

  await rateProvider.updateDstChainId(158);

  await rateProvider.updateLayerZeroEndpoint(
    "0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675"
  );

  await rateProvider.updateRateReceiver(
    "0x52023278321775FB29bc71c6F947CC44f2b2D011"
  );
}

async function setDataOnRateReceiver() {
  const signers = await ethers.getSigners();

  const rateReceiver = CrossChainRateReceiver__factory.connect(
    "0x52023278321775FB29bc71c6F947CC44f2b2D011",
    signers[0]
  );

  await rateReceiver.updateSrcChainId(101);

  await rateReceiver.updateRateProvider(
    "0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d"
  );
}

async function updateRateOnProvider() {
  const signers = await ethers.getSigners();

  const rateProvider = CrossChainRateProvider__factory.connect(
    "0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d",
    signers[0]
  );

  await rateProvider.updateRate({ value: ethers.utils.parseEther("0.01") });
}

async function getRateOnReceiver() {
  const signers = await ethers.getSigners();

  const rateReceiver = CrossChainRateReceiver__factory.connect(
    "0x52023278321775FB29bc71c6F947CC44f2b2D011",
    signers[0]
  );

  const rate = await rateReceiver.getRate();

  console.log({ rate: rate.toString(), rateInBN: rate });
}

getRateOnReceiver().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
