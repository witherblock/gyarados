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

  describe("Unit Tests", function () {
    it("Should remove the right rate receiver", async function () {
      const { rateProvider } = await loadFixture<{}>(deployFixture);

      await rateProvider.removeRateReceiver(0);

      let _rateReceivers = await rateProvider.getRateReceivers();

      expect(_rateReceivers[0]._chainId).to.be.equal(5);
      expect(_rateReceivers[0]._contract).to.be.equal(
        "0x4ea0Be853219be8C9cE27200Bdeee36881612FF2"
      );

      await rateProvider.removeRateReceiver(2);

      _rateReceivers = await rateProvider.getRateReceivers();

      expect(_rateReceivers[0]._chainId).to.be.equal(5);
      expect(_rateReceivers[0]._contract).to.be.equal(
        "0x4ea0Be853219be8C9cE27200Bdeee36881612FF2"
      );

      expect(_rateReceivers[1]._chainId).to.be.equal(3);
      expect(_rateReceivers[1]._contract).to.be.equal(
        "0x021DBfF4A864Aa25c51F0ad2Cd73266Fde66199d"
      );
    });

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

    it("Should correctly estimate fees", async function () {
      const { rateProvider } = await loadFixture(deployFixture);

      const estimatedFee = await rateProvider.estimateFees(DST_CHAIN_IDS[0]);

      expect(estimatedFee.toString()).to.be.equal("13201452000000000");

      const totalFee = await rateProvider.estimateTotalFee();

      expect(totalFee.toString()).to.be.equal("52805808000000000");
    });

    it("Should correctly update the endpoint", async function () {
      const { rateProvider } = await loadFixture(deployFixture);

      await rateProvider.updateLayerZeroEndpoint(
        "0x0000000000000000000000000000000000000000"
      );

      const endpoint = await rateProvider.layerZeroEndpoint();

      expect(endpoint).to.be.equal(
        "0x0000000000000000000000000000000000000000"
      );
    });
  });
});
