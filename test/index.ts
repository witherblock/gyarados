import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";

const CHAIN_ID = 1;

describe("CrossChainRateProvider & CrossChainRateReceiver", function () {
  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const LZEndpointMock = await ethers.getContractFactory("LZEndpointMock");
    const lzEndpointMock = await LZEndpointMock.deploy(CHAIN_ID);

    const CrossChainRateProvider = await ethers.getContractFactory(
      "CrossChainRateProvider"
    );
    const rateProvider = await CrossChainRateProvider.deploy();

    const CrossChainRateReceiver = await ethers.getContractFactory(
      "CrossChainRateReceiver"
    );
    const rateReceiver = await CrossChainRateReceiver.deploy();

    return {
      owner,
      otherAccount,
      lzEndpointMock,
      rateProvider,
      rateReceiver,
    };
  }

  describe("Basic Test", function () {
    it("Should set the right rate and update it at receiver", async function () {
      const { lzEndpointMock, rateProvider, rateReceiver } = await loadFixture(
        deployOneYearLockFixture
      );

      await lzEndpointMock.setDestLzEndpoint(
        rateReceiver.address,
        lzEndpointMock.address
      );

      await rateProvider.updateLayerZeroEndpoint(lzEndpointMock.address);

      await rateProvider.updateRateReceiver(rateReceiver.address);

      await rateProvider.updateDstChainId(CHAIN_ID);

      await rateReceiver.updateRateProvider(rateProvider.address);

      await rateReceiver.updateSrcChainId(CHAIN_ID);

      await rateProvider.updateRate({
        value: ethers.utils.parseEther("1"),
      });

      const rate = await rateReceiver.getRate();

      expect(rate.toString()).to.be.equal("1124666417311180217");
    });
  });
});
