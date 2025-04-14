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
    error Raffle__NotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );

    /* Type Declarations */ 
    enum RaffleState {
        OPEN,
        CALCULATING
    }
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
    RaffleState private s_raffleState;
    
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);
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
        s_raffleState = RaffleState.OPEN;
    }
    function enterRaffle() external payable{
        if(msg.value < i_entranceFee){
            revert Raffle_NotEnoughEthSent();
        }   
        if(s_raffleState != RaffleState.OPEN){
            revert Raffle__NotOpen();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);

    }
    /**
     * @dev This is a function that the chainlink Automation Nodes call to 
     * see if it's time to perform an upkeep.
     * The following should be true for this to run:
     * 1. The time intervals should have passed between raffle runs.
     * 2. The raffle is in open State.
     * 3. The contract has ETH(aka players);
     * 4. (Implicit) The subscription is funded with LINK
     */
    function checkUpkeep(
        bytes memory /*checkData*/) 
        public view returns(bool upkeepNeeded, bytes memory /*performData*/
    ){
        // Check to see if enough time has passed.
        bool timeHasPassed = block.timestamp >= (i_interval + s_lastTimeStamp);
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }
    function performUpKeep(bytes calldata /*performData*/) external {
        (bool upkeepNeeded,) = checkUpkeep("");
        if(!upkeepNeeded){
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        
        s_raffleState = RaffleState.CALCULATING;
        /*uint256 requestId =*/ i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

   function fulfillRandomWords(uint256 /*requestId*/, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
         
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
         emit PickedWinner(s_recentWinner);

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
    function getRaffleState() external view returns(RaffleState){
        return s_raffleState;
    }
    function getNumWords() external pure returns(uint256){
        return NUM_WORDS;
    }
 }