// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script{
    struct NetworkConfig{
        uint256 entranceFee; 
        uint256 interval; 
        address vrfCoordinator; 
        bytes32 gasLane;
        uint64 subscriptionId; 
        uint32 callbackGasLimit;
    }

    NetworkConfig public activeNetworkConfig;

    constructor(){
        if (block.chainid == 111555111){
            activeNetworkConfig = getSepoliaNetworkConfig();
        }
        else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaNetworkConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory getSepolia = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator : 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000
        });
        return getSepolia;
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        if(activeNetworkConfig.vrfCoordinator !=address(0)){
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorV2Mock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000
        });
        return anvilConfig;

    }
}