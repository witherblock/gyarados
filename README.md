# Gyarados

A contract pair to be deployed on separate chains to get rate (uint) from a vault on one chain and send it to the other. Powered via LayerZero.

## Deployed Contracts

RateProvider (On Ethereum Mainnet): [0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d](https://etherscan.io/address/0xaD78CD17D3A4a3dc6afb203ef91C0E54433b3b9d)

RateReceiver (On Polygon zkEVM): [0x00346D2Fd4B2Dc3468fA38B857409BC99f832ef8](https://zkevm.polygonscan.com/address/0x00346D2Fd4B2Dc3468fA38B857409BC99f832ef8)

### Test Transaction

Update Rate tx: https://etherscan.io/tx/0x3a4406dc799d79a2f158821b0ee46796ce8f80370fce7c815be880ab0bc65c01
LayerZero crosschain message: https://layerzeroscan.com/101/address/0xad78cd17d3a4a3dc6afb203ef91c0e54433b3b9d/message/158/address/0x00346d2fd4b2dc3468fa38b857409bc99f832ef8/nonce/1
zkEVM receive tx: https://zkevm.polygonscan.com/tx/0x7b824c70da96d94ea7ca98949ef7ff5043de5eedb46b2ed9b814e9b0b2a50e52

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
