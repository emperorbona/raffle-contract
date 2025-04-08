// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.18;

/**
 * @title A Sample Raffle Contract
 * @author Emperor Edetan
 * @notice This contract is for creating a Sample raffle
 * @dev Implements chainlink VRFv2
 * */ 


 contract Raffle{
    error Raffle_NotEnoughEthSent();

    uint256  private immutable i_entranceFee;
    address payable[] private s_players;
    

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
    }
    function enterRaffle() external payable{
        if(msg.value < i_entranceFee){
            revert Raffle_NotEnoughEthSent();
        }   
        s_players.push(payable(msg.sender));
    }
    function pickWinner() external {
        
    }
    /** Getter functions */ 
    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
    function getPlayers(uint256 index) external view returns(address){
        return s_players[index];
    }
 }