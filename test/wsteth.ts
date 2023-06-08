import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";

const CHAIN_ID = 1;

describe("WstEthRateProvider & WstEthRateReceiver", function () {
  async function deployFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const LZEndpointMock = await ethers.getContractFactory("LZEndpointMock");
    const lzEndpointMock = await LZEndpointMock.deploy(CHAIN_ID);

    const WstEthRateProvider = await ethers.getContractFactory(
      "WstEthRateProvider"
    );
    const rateProvider = await WstEthRateProvider.deploy(
      lzEndpointMock.address
    );

    const REthRateReceiver = await ethers.getContractFactory(
      "REthRateReceiver"
    );
    const rateReceiver = await REthRateReceiver.deploy(
      CHAIN_ID,
      rateProvider.address,
      lzEndpointMock.address
    );

    return {
      owner,
      otherAccount,
      lzEndpointMock,
      rateProvider,
      rateReceiver,
    };
  }

  describe("RateInfo", function () {
    it("RateInfo getter for rate provider", async function () {
      const { rateProvider } = await loadFixture(deployFixture);

      const rateInfo = await rateProvider.rateInfo();

      expect(rateInfo.baseTokenSymbol).to.be.equal("ETH");
      expect(rateInfo.tokenSymbol).to.be.equal("rETH");
      expect(rateInfo.baseTokenAddress).to.be.equal(
        "0x0000000000000000000000000000000000000000"
      );
      expect(rateInfo.tokenAddress).to.be.equal(
        "0xae78736Cd615f374D3085123A210448E74Fc6393"
      );
    });

    it("RateInfo getter for rate receiver", async function () {
      const { rateReceiver } = await loadFixture(deployFixture);

      const rateInfo = await rateReceiver.rateInfo();

      expect(rateInfo.baseTokenSymbol).to.be.equal("ETH");
      expect(rateInfo.tokenSymbol).to.be.equal("rETH");
    });
  });

  describe("Basic Update Test", function () {
    it("Should set the right rate and update it at receiver", async function () {
      const { lzEndpointMock, rateProvider, rateReceiver } = await loadFixture(
        deployFixture
      );

      await rateProvider.addDstChainId(CHAIN_ID);

      await lzEndpointMock.setDestLzEndpoint(
        rateReceiver.address,
        lzEndpointMock.address
      );

      await rateProvider.updateRateReceiver(rateReceiver.address);

      await rateProvider.updateRate({
        value: ethers.utils.parseEther("1"),
      });

      const rate = await rateReceiver.getRate();

      expect(rate.toString()).to.be.equal("1124666417311180217");
    });
  });
});
