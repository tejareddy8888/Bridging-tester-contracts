## Axelar Gateway Tester Kit for Efficient Bridging tests
 
# Getting Started 
It's recommended that you've gone through the [hardhat getting started documentation](https://hardhat.org/getting-started/) before proceeding here. 

## Quickstart

1. Clone and install dependencies run the following:

```
npm install
```


```
npm install --save-dev @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-network-helpers @nomicfoundation/hardhat-chai-matchers @nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan chai ethers hardhat-gas-reporter solidity-coverage @typechain/hardhat typechain @typechain/ethers-v6 @ethersproject/abi @ethersproject/providers
```

That's also the case if you are using yarn.
```
yarn add --dev @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-network-helpers @nomicfoundation/hardhat-chai-matchers @nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan chai ethers hardhat-gas-reporter solidity-coverage @typechain/hardhat typechain @typechain/ethers-v5 @ethersproject/abi @ethersproject/providers
```

1. You can now do stuff!

```
npx hardhat test
```

or

```
npm run test
```

or

```
yarn test
```

# Usage

If you run `npx hardhat --help` you'll get an output of all the tasks you can run. 

## Deploying Contracts

```
npx hardhat run scripts/deployment
```
