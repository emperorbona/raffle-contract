// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.18;

/**
 * @title A Sample Raffle Contract
 * @author Emperor Edetan
 * @notice This contract is for creating a Sample raffle
 * @dev Implements chainlink VRFv2
 * */ 

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

 contract Raffle is VRFConsumerBaseV2{

    error Raffle_NotEnoughEthSent();
    error Raffle_TransferFailed();
    uint16 private constant REQUEST_CONFIRMATION = 2;
    uint32 private constant NUM_WORDS = 1;

    uint256  private immutable i_entranceFee;
    address payable[] private s_players;
    // Duration Of the lottery in seconds
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address private s_recentWinner;
    
    event EnteredRaffle(address indexed player);
    constructor(
        uint256 entranceFee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane,
        uint64 subscriptionId, 
        uint32 callbackGasLimit)
        VRFConsumerBaseV2(vrfCoordinator)
    {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }
    function enterRaffle() external payable{
        if(msg.value < i_entranceFee){
            revert Raffle_NotEnoughEthSent();
        }   
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }
    function pickWinner() external {
        if(block.timestamp < (i_interval + s_lastTimeStamp)){
            revert();
        }
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

   function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        (bool callSuccess,) = s_recentWinner.call{value: address(this).balance}("");
        if(!callSuccess){
            revert Raffle_TransferFailed();
        }
        

}

    /** Getter functions */ 
    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
    function getPlayers(uint256 index) external view returns(address){
        return s_players[index];
    }
 }