// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle} from "../../src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

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
}