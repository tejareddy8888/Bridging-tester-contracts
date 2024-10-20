// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

interface IERC20Bridgeable is IERC20 {
    function transferRemote(
        string calldata destinationChain,
        address destinationAddress,
        uint256 amount,
        address receiverAddress,
        string calldata destinationMessage
    ) external payable;
}

/**
 * @title CallContract
 * @notice Send a message from chain A to chain B and stores gmp message
 */
contract AxelarERC20 is AxelarExecutable, ERC20, IERC20Bridgeable {
    uint256 public constant MAX_GAS_LIMIT = 2000000;
    string public message;
    string public sourceChain;
    string public sourceAddress;
    IAxelarGasService public immutable gasService;

    event Executed(string _from, string _message);

    /**
     *
     * @param _gateway address of axl gateway on deployed chain
     * @param _gasReceiver address of axl gas service on deployed chain
     */
    constructor(
        address _gateway,
        address _gasReceiver
    ) AxelarExecutable(_gateway) ERC20("SygnumAxelarBridge", "SYGAXE") {
        gasService = IAxelarGasService(_gasReceiver);
    }

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Estimate gas for a cross-chain contract call
     * @param destinationChain name of the dest chain
     * @param destinationAddress address on dest chain this tx is going to
     * @param mintingAddress address on dest chain to mint the tokens
     * @param amountToMint amount to be minted on the dest chain
     * @param mintingMessage message to be printed on the dest chain
     * @return gasEstimate The cross-chain gas estimate
     */
    function estimateGasFee(
        string calldata destinationChain,
        string calldata destinationAddress,
        address mintingAddress,
        uint256 amountToMint,
        string calldata mintingMessage
    ) external view returns (uint256) {
        bytes memory payload = abi.encode(
            mintingAddress,
            amountToMint,
            mintingMessage
        );

        return
            gasService.estimateGasFee(
                destinationChain,
                destinationAddress,
                payload,
                MAX_GAS_LIMIT,
                new bytes(0)
            );
    }

    /**
     * @notice Send message from chain A to chain B
     * @dev message param is passed in as gmp message
     * @param destinationChain name of the dest chain (ex. "Fantom")
     * @param destinationAddress address on dest chain this tx is going to]
     * @param mintingAddress address on dest chain to mint the tokens
     * @param amountToMint amount to be minted on the dest chain
     * @param mintingMessage message to be printed on the dest chain
     */
    function sendMessage(
        string calldata destinationChain,
        string calldata destinationAddress,
        address mintingAddress,
        uint256 amountToMint,
        string calldata mintingMessage
    ) external payable {
        require(msg.value > 0, "Gas payment is required");

        bytes memory payload = abi.encode(
            mintingAddress,
            amountToMint,
            mintingMessage
        );
        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            msg.sender
        );
        //         gasService.payGas{ value: msg.value }(
        //     address(this),
        //     destinationChain,
        //     destinationAddress,
        //     payload,
        //     MAX_GAS_LIMIT,
        //     true,
        //     msg.sender,
        //     new bytes(0)
        // );
        gateway.callContract(destinationChain, destinationAddress, payload);
    }

    function transferRemote(
        string calldata destinationChain,
        address destinationAddress,
        uint256 amount,
        address receiverAddress,
        string calldata destinationMessage
    ) public payable override {
        require(msg.value > 0, "Gas payment is required");
        _burn(msg.sender, amount);

        bytes memory payload = abi.encode(
            receiverAddress,
            amount,
            destinationMessage
        );

        string memory stringAddress = toString(destinationAddress);

        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            stringAddress,
            payload,
            msg.sender
        );
        
        gateway.callContract(destinationChain, stringAddress, payload);
    }

    /**
     * @notice logic to be executed on dest chain
     * @dev this is triggered automatically by relayer
     * @
     * @param _sourceChain blockchain where tx is originating from
     * @param _sourceAddress address on src chain where tx is originating from
     * @param _payload encoded gmp message sent from src chain
     */
    function _execute(
        string calldata _sourceChain,
        string calldata _sourceAddress,
        bytes calldata _payload
    ) internal override{
        (
            address mintingAddress,
            uint256 amountToMint,
            string memory mintingMessage
        ) = abi.decode(_payload, (address, uint256, string));
        sourceChain = _sourceChain;
        sourceAddress = _sourceAddress;

        _mint(mintingAddress, amountToMint);
        emit Executed(sourceAddress, mintingMessage);
    }

    //// PURE FUNCTIONS
    function toString(address address_) internal pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(address_);
        bytes memory characters = "0123456789abcdef";
        bytes memory stringBytes = new bytes(42);

        stringBytes[0] = "0";
        stringBytes[1] = "x";

        for (uint256 i; i < 20; ++i) {
            stringBytes[2 + i * 2] = characters[uint8(addressBytes[i] >> 4)];
            stringBytes[3 + i * 2] = characters[uint8(addressBytes[i] & 0x0f)];
        }

        return string(stringBytes);
    }
}

// /**
//  * @notice logic to be executed on dest chain
//  * @dev this is triggered automatically by relayer
//  * @param payload encoded gmp message sent from src chain
//  * @param tokenSymbol symbol of token sent from src chain
//  * @param amount amount of tokens sent from src chain
//  */
// function _executeWithToken(
//     string calldata,
//     string calldata,
//     bytes calldata payload,
//     string calldata tokenSymbol,
//     uint256 amount
// ) internal override {
//     address[] memory recipients = abi.decode(payload, (address[]));
//     address tokenAddress = gateway.tokenAddresses(tokenSymbol);

//     uint256 sentAmount = amount / recipients.length;
//     for (uint256 i = 0; i < recipients.length; i++) {
//         IERC20(tokenAddress).transfer(recipients[i], sentAmount);
//     }

//     emit Executed();
// }

// /**
//  * @notice trigger interchain tx from src chain
//  * @dev destinationAddresses will be passed in as gmp message in this tx
//  * @param destinationChain name of the dest chain (ex. "Fantom")
//  * @param destinationAddress address on dest chain this tx is going to
//  * @param destinationAddresses recipient addresses receiving sent funds
//  * @param symbol symbol of token being sent
//  * @param amount amount of tokens being sent
//  */
// function sendMessageUsingToken(
//     string memory destinationChain,
//     string memory destinationAddress,
//     address[] calldata destinationAddresses,
//     string memory symbol,
//     uint256 amount
// ) external payable {

//     address tokenAddress = gateway.tokenAddresses(symbol);
//     IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
//     IERC20(tokenAddress).approve(address(gateway), amount);
//     bytes memory payload = abi.encode(destinationAddresses);
//     gasService.payNativeGasForContractCallWithToken(
//         address(this),
//         destinationChain,
//         destinationAddress,
//         payload,
//         symbol,
//         amount,
//         msg.sender
//     );
//     gateway.callContractWithToken(
//         destinationChain,
//         destinationAddress,
//         payload,
//         symbol,
//         amount
//     );
// }
