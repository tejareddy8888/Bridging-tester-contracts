const networkConfig = {
    default: {
        name: "hardhat",
    },
    31337: {
        name: "localhost",
        axelarGateway: "0xe432150cce91c13a887f7D836923d5597adD8E31",
        axelarGasService: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6"
    },
    1: {
        name: "mainnet",
        linkToken: "0x514910771af9ca656af840dff83e8264ecf986ca",
        fundAmount: "0",
        automationUpdateInterval: "30",
    },
    11155111: {
        name: "sepolia",
        axelarGateway: "0xe432150cce91c13a887f7D836923d5597adD8E31",
        axelarGasService: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6"
    },
    137: {
        name: "polygon",
    },
    80002: {
        name: "amoy",
        axelarGateway: "0xe432150cce91c13a887f7D836923d5597adD8E31",
        axelarGasService: "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6"
    },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
