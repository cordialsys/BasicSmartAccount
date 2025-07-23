# Basic Smart Account

This smart contract uses the SafeLite example: https://github.com/5afe/safe-eip7702/blob/main/safe-eip7702-contracts/contracts/experimental/SafeLite.sol
It was stripped from all unecessary logic to only keep the batch functionality.
It uses no dependencies and relies on some assembly to save on gas usage.

DFNS is also using a modfied [SafeLite example and completed an audit for it](https://github.com/dfns/dfns-smart-account).

It is deployed on the following chains:

| Blockchain          | Contract Address                                                                                                                      |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Arbitrum            | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://arbiscan.io/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)             |
| Base                | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://basescan.org/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)            |
| Berachain           | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://berascan.org/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)            |
| Berachain Bepolia   | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://testnet.berascan.com/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)    |
| Binance Smart Chain | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://bscscan.com/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)             |
| Ethereum Mainnet    | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://etherscan.io/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)            |
| Ethereum Holesky    | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://holesky.etherscan.io/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)    |
| Optimism            | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://optimistic.etherscan.io/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code) |
| Polygon             | [0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f](https://polygonscan.com/address/0x7785a22Facd31dB653bA4928f1D5B81D093f0b2f#code)         |

## EIP 7702

### Overview

EIP7702 allows EOA addresses to be treated as contract addresses. This is introduced as a new EVM transaction type which adds
a new field called "authorization list".

Each authorization in the list makes a temporary delegation to a contract address for some EOA. This authorization must be signed by that EOA.
It is temporary in that the EOA can be delegated to this contract only in transactions containing a proper authorization for it.

Note that the transaction itself does not need to be signed by the EOA's being delegated. So a "fee-payer" address can craft a transaction
containing these authorizations for other EOA's and thus sponsor actions for them.

### EIP 7702 contract

For the authorized EOA, this contract is executed as if EOA is the contract. Meaning the contract can move funds, call other contracts for the EOA.
Thus it's important that the EOA additionally signs the actions done by the contract (stored in the `data` of the transaction). This protects the EOA
from the "fee-payer" address inserting arbitrary actions.

The input to `BasicSmartAccount` is a list of `(to address, value uint256, data bytes)` tuples, all of which are signed by the EOA. The
input is simply verified and executed.

In summary:

- Any EOA can delegate to `BasicSmartAccount` contract by signing an authorization.
- By delegating to `BasicSmartAccount` in a transaction, an EOA is trusting `BasicSmartAccount` to correctly execute any signed `(address, value, data)` tuples included in that same transaction.
- The transaction containing the authorization list and `(address, value, data)` data itself can be signed by a separate address. This address pays the fees.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Anvil

```shell
anvil
```

### Deploy

Deployment is done using deterministic `CREATE2` instruction. Meaning any address can deploy this contract to a chain (for the given `EVM_SALT`),
and it will have the expected contract address. Note that if any part of the contract changes, then the contract address will also be different.

```shell
# keccak256("BasicSmartAccount")
export EVM_SALT=bdfee0231e0903cde9ca6fd75d08a500062dc3d87718f712bc6958ed697617c3
 forge script ./script/DeployBasicSmartAccount.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

Add `--broadcast` when you are ready to transmit for real.

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
