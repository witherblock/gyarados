# Gyarados

A contract pair to be deployed on separate chains to get rate (uint) from a vault on one chain and send it to the other. Powered via LayerZero.

## Deployed Contracts

### wstETH

**Contracts**

**RateProvider (On Ethereum Mainnet):** [0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d](https://etherscan.io/address/0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d)

**RateReceiver (On Polygon zkEVM):** [0x00346D2Fd4B2Dc3468fA38B857409BC99f832ef8](https://zkevm.polygonscan.com/address/0x00346D2Fd4B2Dc3468fA38B857409BC99f832ef8)

**Test Transaction**

- [Update Rate Tx](https://etherscan.io/tx/0x3a4406dc799d79a2f158821b0ee46796ce8f80370fce7c815be880ab0bc65c01)
- [LayerZero crosschain message](https://layerzeroscan.com/101/address/0xad78cd17d3a4a3dc6afb203ef91c0e54433b3b9d/message/158/address/0x00346d2fd4b2dc3468fa38b857409bc99f832ef8/nonce/1)
- [zkEVM receive Tx](https://zkevm.polygonscan.com/tx/0x7b824c70da96d94ea7ca98949ef7ff5043de5eedb46b2ed9b814e9b0b2a50e52)

### rETH

**Contracts**

**REthRateProvider (On Ethereum Mainnet):** [0xB385BBc8Bfc80451cDbB6acfFE4D95671f4C051c](https://etherscan.io/address/0xB385BBc8Bfc80451cDbB6acfFE4D95671f4C051c)

**REthRateReceiver (On Polygon zkEVM):** [0x60b39BEC6AF8206d1E6E8DFC63ceA214A506D6c3](https://zkevm.polygonscan.com/address/0x60b39BEC6AF8206d1E6E8DFC63ceA214A506D6c3)

**Test Transaction**

- [Update Rate Tx](https://etherscan.io/tx/0x1ebfe82ea7f3b5356dd68dbd8c826717e7af373f968504e21f8010329621c373)
- [LayerZero crosschain message](https://layerzeroscan.com/101/address/0xb385bbc8bfc80451cdbb6acffe4d95671f4c051c/message/158/address/0x60b39bec6af8206d1e6e8dfc63cea214a506d6c3/nonce/1)
- [zkEVM receive Tx](https://zkevm.polygonscan.com/tx/0x8fbc06be49cf942ffd42337c7aba70f420d3bd394d87f8b5259237bc8e430fcd)

## Getting started

### Pre-requisites

Please have these installed on your machine:

- [node.js 18+](https://nodejs.org/)
- [pnpm](https://pnpm.io/)

### Install dependencies:

```
pnpm i
```

### Commands available

- Compile

```
pnpm compile
```

- Test

```
pnpm test
```
