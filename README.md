# 🏆 Decentralized Raffle Smart Contract

This project implements a decentralized raffle (lottery) system on the Ethereum blockchain using Solidity, Chainlink VRF v2 for randomness, and Chainlink Automation (Keepers) for autonomous execution.

## 📜 Overview

* **Chainlink VRF** ensures provable randomness in selecting winners.
* **Chainlink Automation** checks when to trigger the winner selection process.
* Players can enter the raffle by paying a fee.
* After a time interval, the raffle picks a random winner and resets.

## 👨‍💼 Author

**Emperor Edetan**
Smart Contract Developer | Solidity | Chainlink | Foundry

---

## 🧰 Tech Stack

* **Solidity `^0.8.18`**
* **Chainlink VRF v2**
* **Chainlink Automation (Keepers)**
* **Foundry** (Forge) for development, deployment, and testing

---

## 🚀 Features

* Secure and fair winner selection using Chainlink VRF
* Automated upkeep using Chainlink Automation
* Customizable entrance fee and interval
* Fully unit-tested using Foundry
* Programmatic subscription creation, funding, and consumer addition

---

## 🛠️ Installation

1. Clone the repo:

```bash
git clone https://github.com/yourusername/raffle-smart-contract.git
cd raffle-smart-contract
```

2. Install dependencies:

```bash
forge install
```

3. Set up `.env` file (if using scripts with private keys, RPCs, etc.)

---

## 🛆 Project Structure

```
.
├── src/
│   └── Raffle.sol              # Main Raffle contract
├── script/
│   ├── DeployRaffle.s.sol      # Deployment script
│   ├── HelperConfig.s.sol
│   └── Interactions.s.sol  # Script to create, fund, and add consumer
├── test/
│   ├── mocks
│   │   └── LinkToken.sol
│   ├── unit
│   │   └──  RaffleTest.t.sol        # Unit tests
├── foundry.toml                # Foundry config
└── README.md
```

---

## 🔐 Environment Variables

Create a `.env` file in the root to securely pass sensitive data:

```
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_key
```

---

## 📜 Deployment

Run the deployment script using Foundry:

```bash
forge script script/DeployRaffle.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

## 🔄 Chainlink Subscription Setup

1. Use `CreateAndFundSub.s.sol` to:

   * Create a Chainlink VRF subscription
   * Fund it with LINK
   * Add the raffle contract as a consumer

---

## ✅ Testing

Run unit tests using:

```bash
forge test
```

Run tests with logs and forked network:

```bash
forge test --fork-url $SEPOLIA_RPC_URL -vvv
```

---

## 🧢 Contract Details

* `enterRaffle()`: Lets users join the raffle by sending ETH.
* `checkUpkeep()`: Chainlink Keeper calls this to check if conditions are met.
* `performUpKeep()`: Requests a random number from Chainlink VRF.
* `fulfillRandomWords()`: Selects a winner and resets the state.

---

## 🔍 Functions Overview

| Function               | Description                    |
| ---------------------- | ------------------------------ |
| `enterRaffle()`        | Allows users to participate    |
| `checkUpkeep()`        | Determines if upkeep is needed |
| `performUpKeep()`      | Triggers Chainlink VRF request |
| `fulfillRandomWords()` | Picks winner and resets raffle |
| `getEntranceFee()`     | Returns fee to enter           |
| `getRecentWinner()`    | Returns last winner            |
| `getPlayers(index)`    | Returns player at index        |
| `getRaffleState()`     | Returns raffle state           |
| `getLengthOfPlayers()` | Number of current participants |

---

## 🌐 Live Network Info (Example)

* **Network**: Sepolia
* **Contract Address**: `0xYourDeployedContractAddress`
* **Chainlink VRF Coordinator**: `0x...`
* **LINK Token**: `0x...`

---

## 🧠 Future Improvements

* Frontend UI integration
* NFT rewards or ERC20 token prizes
* Support multiple raffles at once

---

## 🙌 Acknowledgements

* [Chainlink Documentation](https://docs.chain.link/)
* [Foundry Book](https://book.getfoundry.sh/)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
