// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {
    Raffle raffle;
        uint256 entranceFee; 
        uint256 interval; 
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId; 
        uint32 callbackGasLimit;
        address link;
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    address public PLAYER = makeAddr("Player");
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 STARTING_BALANCE = 10 ether;
    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        HelperConfig helperConfig;
        (raffle, helperConfig) = deployRaffle.run();
           (entranceFee,
            interval,
            vrfCoordinator, 
            gasLane,
            subscriptionId, 
            callbackGasLimit,
            link) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testRaffleStateInitializesInOpenState() external view{
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }
    function testRaffleRevertsWhenYouDontPayEnough() external {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() external {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: SEND_VALUE}();
        address players = raffle.getPlayers(0);
        assertEq(players, PLAYER);
    }

    function testRaffleEnter() external {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: SEND_VALUE}();

    }
    function testCantEnterRaffleWhenRaffleIsCalculating() external {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: SEND_VALUE}();
        vm.warp(block.timestamp + 1 + interval);
        
        raffle.performUpKeep("");
        
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
        raffle.enterRaffle{value: SEND_VALUE}();
    }
    function testCheckUpkeepReturnsFalseIfItHasNoBalance() external{
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upKeepNeeded,) = raffle.checkUpkeep("");

        assert(!upKeepNeeded);
    }

    function testCheckUpkeepReturnsFalseWhenRaffleIsCaluclating() external{
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: SEND_VALUE}();
        raffle.performUpKeep("");

        (bool upKeepNeeded,) = raffle.checkUpkeep("");

        assert(!upKeepNeeded);
    }
    function testCheckUpkeepReturnsFalseWhenTimeIsNotPassed() external{
        vm.prank(PLAYER);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: SEND_VALUE}();

        (bool upKeepNeeded,) = raffle.checkUpkeep("");

        assert(!upKeepNeeded);
    }

                ////////////////////////
                // Perform Upkeep     //
                ////////////////////////

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() external{
        // Arrange
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: SEND_VALUE}();
        // Act/Assert
        raffle.performUpKeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepFails() external{
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0;
        vm.expectRevert(
            abi.encodeWithSelector(
            Raffle.Raffle__UpkeepNotNeeded.selector,
            currentBalance,
            numPlayers,
            raffleState
            )
        );
        raffle.performUpKeep("");
    }
    modifier raffleTimeHasPassed(){
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: SEND_VALUE}();
        _;
    }
    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleTimeHasPassed{

        vm.recordLogs();
        raffle.performUpKeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        Raffle.RaffleState rState = raffle.getRaffleState();

        assert(uint256(requestId) > 0);
        assert(uint256(rState) == 1);
    }

    
                ////////////////////////
                // fulfilRandomWords  //
                ////////////////////////


    function testPerformRandomWordsCanOnlyBeCalledAfterCheckUpkeep(uint256 randomRequestId) public raffleTimeHasPassed{
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }
    function testPerformRandomWordsPicksAWinnerResetsAndSendsMoney() public raffleTimeHasPassed{
        // Arrange
        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;

        for(uint256 i = startingIndex; i < additionalEntrants + startingIndex ; i++){
            address player = address(uint160(i));
            hoax(player, STARTING_BALANCE);
            raffle.enterRaffle{value: SEND_VALUE}();
        }

        uint256 prize = SEND_VALUE * (additionalEntrants + 1);

        vm.recordLogs();
        raffle.performUpKeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        uint256 previousTimeStamp = raffle.getLastTimeStamp();
  
        // pretend to be chainlink vrf
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(raffle)
        );

        assert(uint256(raffle.getRaffleState()) ==0);
        assert(raffle.getRecentWinner() != address(0));
        assert(raffle.getLengthOfPlayers() == 0);
        assert(previousTimeStamp < raffle.getLastTimeStamp());
        console.log(raffle.getRecentWinner().balance);
        console.log(prize + STARTING_BALANCE - SEND_VALUE);
        assert(raffle.getRecentWinner().balance == STARTING_BALANCE + prize - SEND_VALUE);
        



    }
}