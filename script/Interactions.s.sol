// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract CreateSubscription is Script{
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        
    }

    function createNewSubscriptionUsingConfig() public returns(uint64){
        
    }

    function fundSubscription(uint64 subscriptionId) internal {
        // Fund the subscription with LINK tokens
        // The amount of LINK tokens to fund the subscription with
    }
}