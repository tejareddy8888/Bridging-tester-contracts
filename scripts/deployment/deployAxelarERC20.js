const { ethers, network, run } = require("hardhat")
const {
    networkConfig,
    developmentChains,
} = require("../../helper-hardhat-config")

async function deployAxelarERC20(chainId) {
    const axelarGateway = networkConfig[chainId]["axelarGateway"]
    const axelarGasService = networkConfig[chainId]["axelarGasService"]

    const axelarERC20Factory = await ethers.getContractFactory("AxelarERC20")
    console.log("Deploying AxelarERC20...")

    const axelarERC20 = await axelarERC20Factory.deploy(axelarGateway, axelarGasService, {
        maxFeePerGas:         ethers.parseUnits('4', 'gwei'),
        maxPriorityFeePerGas: ethers.parseUnits('1',   'gwei'),
        baseFeePerGas : ethers.parseUnits('2',   'gwei'),
    })

    await axelarERC20.waitForDeployment()

    console.log(`Axelar ERC20 deployed to ${axelarERC20.target} on ${network.name}`)

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await run("verify:verify", {
            address: axelarERC20.target,
            constructorArguments: [axelarGateway, axelarGasService],
        })
    }
}

module.exports = {
    deployAxelarERC20,
}
