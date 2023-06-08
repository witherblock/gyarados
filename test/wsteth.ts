import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";

const SRC_CHAIN_ID = 1;

const DST_CHAIN_IDS = [2, 3, 4, 5];

describe("WstEthRateProvider & WstEthRateReceiver", function () {
  async function deployFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const LZEndpointMock = await ethers.getContractFactory("LZEndpointMock");
    const lzEndpointMock = await LZEndpointMock.deploy(SRC_CHAIN_ID);

    const WstEthRateProvider = await ethers.getContractFactory(
      "WstEthRateProvider"
    );
    const rateProvider = await WstEthRateProvider.deploy(
      lzEndpointMock.address
    );

    const WstEthRateReceiver = await ethers.getContractFactory(
      "WstEthRateReceiver"
    );

    let rateReceivers = [];

    for (let i = 0; i < DST_CHAIN_IDS.length; i++) {
      const chainId = DST_CHAIN_IDS[i];

      const mockEndpoint = await LZEndpointMock.deploy(chainId);

      const rateReceiver = await WstEthRateReceiver.deploy(
        SRC_CHAIN_ID,
        rateProvider.address,
        mockEndpoint.address
      );

      await rateProvider.addRateReceiver(chainId, rateReceiver.address);

      await lzEndpointMock.setDestLzEndpoint(
        rateReceiver.address,
        mockEndpoint.address
      );

      rateReceivers.push(rateReceiver);
    }

    return {
      owner,
      otherAccount,
      lzEndpointMock,
      rateProvider,
      rateReceivers,
    };
  }

  describe("Basic Update Test", function () {
    it("Should set the right rate and update it at receivers", async function () {
      const { rateProvider, rateReceivers } = await loadFixture(deployFixture);

      await rateProvider.updateRate({
        value: ethers.utils.parseEther("10"),
      });

      for (let i = 0; i < rateReceivers.length; i++) {
        const rateReceiver = rateReceivers[i];

        const rate = await rateReceiver.getRate();

        expect(rate.toString()).to.be.equal("1124666417311180217");
      }
    });
  });
});
