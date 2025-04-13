// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle} from "../../src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";

contract RaffleTest is Test {
    Raffle raffle;

    address public PLAYER = makeAddr("Player");
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 STARTING_BALANCE = 10 ether;
    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    // function testRaffleEnter() external {
    //     vm.startPrank(PLAYER);
    //     vm.expectEmit(true, true, true, true);
    //     emit EnteredRaffle(PLAYER);
    //     raffle.enterRaffle{value: SEND_VALUE}();
    //     assertEq(raffle.getPlayer(0), PLAYER);
    //     vm.stopPrank();
    // }
}