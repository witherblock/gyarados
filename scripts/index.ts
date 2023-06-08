import { ethers } from "hardhat";
import {
  REthRateProvider__factory,
  REthRateReceiver__factory,
} from "../typechain-types";

async function setDataOnRateProvider() {
  const signers = await ethers.getSigners();

  const rateProvider = REthRateProvider__factory.connect(
    "0xB385BBc8Bfc80451cDbB6acfFE4D95671f4C051c",
    signers[0]
  );

  await rateProvider.updateRateReceiver(
    "0x60b39BEC6AF8206d1E6E8DFC63ceA214A506D6c3"
  );
}

async function updateRateOnProvider() {
  const signers = await ethers.getSigners();

  const rateProvider = REthRateProvider__factory.connect(
    "0xB385BBc8Bfc80451cDbB6acfFE4D95671f4C051c",
    signers[0]
  );

  await rateProvider.updateRate({ value: ethers.utils.parseEther("0.01") });
}

async function getRateOnReceiver() {
  const signers = await ethers.getSigners();

  const rateReceiver = REthRateReceiver__factory.connect(
    "0x60b39BEC6AF8206d1E6E8DFC63ceA214A506D6c3",
    signers[0]
  );

  const rate = await rateReceiver.getRate();

  console.log({ rate: rate.toString(), rateInBN: rate });
}

getRateOnReceiver().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
