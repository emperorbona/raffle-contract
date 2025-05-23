// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";
contract DeployRaffle is Script{

    function run() external returns(Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        ( 
        uint256 entranceFee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane,
        uint64 subscriptionId, 
        uint32 callbackGasLimit,
        address link) = helperConfig.activeNetworkConfig();

        if(subscriptionId == 0){
            // We are going to create a subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator);

            // Fund the subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator,
                subscriptionId,
                link
            );

        }
        vm.startBroadcast();
        // Deploying the Raffle contract
        // The constructor of the Raffle contract takes in the following parameters:
        // entranceFee, interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit
        Raffle raffle ;
        
        raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator, 
            gasLane,
            subscriptionId, 
            callbackGasLimit
        );
        vm.stopBroadcast();
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
          address(raffle),
          vrfCoordinator,
          subscriptionId  
        );
        return (raffle, helperConfig);
    }
}