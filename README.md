HeartbeatBalanceTrap
Objective
Create a functional Drosera trap that:

Tracks the blockchain’s block.number every time collect() is called

Triggers a response every 3 blocks, regardless of ETH balance changes

Sends a signal to an external alert contract on a predictable, timed interval

Problem
In some scenarios, it's necessary to trigger smart contract logic not based on external wallet activity or balance changes, but on timed intervals driven by block production.

Examples include:

Simulated heartbeat signals for uptime/liveness monitoring

Scheduled on-chain workflows

Infrastructure testing or monitoring Drosera responsiveness

Solution
This trap activates every 3rd block, using block.number % 3 == 0 as a simple and deterministic trigger.
It allows predictable execution windows on the blockchain, with minimal complexity and no dependency on transfers or other data.

Trap Logic
Contract: HeartbeatBalanceTrap.sol
solidity
Копировать
Редактировать
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract HeartbeatBalanceTrap is ITrap {
    address public constant target = 0x3B80fEDa59d8dCC17D23c0484767e54739C93103;

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.number, target.balance);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        (uint256 currentBlock, ) = abi.decode(data[0], (uint256, uint256));
        if (currentBlock % 3 == 0) {
            return (true, "");
        }
        return (false, "");
    }
}
Response Contract
Contract: FrequentAlertReceiver.sol
solidity
Копировать
Редактировать
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FrequentAlertReceiver {
    event FrequentAlert(string message, uint256 blockNumber);

    function notify() external {
        emit FrequentAlert("Frequent heartbeat alert triggered", block.number);
    }
}
Deployment & Setup
1. Deploy Contracts
Use Foundry CLI to deploy both contracts:

bash
Копировать
Редактировать
forge create src/FrequentAlertReceiver.sol:FrequentAlertReceiver \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0xYOUR_PRIVATE_KEY

forge create src/HeartbeatBalanceTrap.sol:HeartbeatBalanceTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0xYOUR_PRIVATE_KEY
2. Configure drosera.toml
Update your drosera.toml file to register the trap:

toml
Копировать
Редактировать
[traps.heartbeat]
path = "out/HeartbeatBalanceTrap.sol/HeartbeatBalanceTrap.json"
response_contract = "0xYOUR_FrequentAlertReceiver_ADDRESS"
response_function = "notify()"
Replace 0xYOUR_FrequentAlertReceiver_ADDRESS with the address from deployment.

3. Apply Configuration
bash
Копировать
Редактировать
DROSERA_PRIVATE_KEY=0xYOUR_PRIVATE_KEY drosera apply
This registers your trap with the Drosera operator.

Testing
Wait for new blocks on the Ethereum Hoodi testnet

On blocks divisible by 3 (e.g., block 123, 126, 129), the trap will trigger

You should observe:

shouldRespond = true

A FrequentAlert event emitted in the response contract logs

Optional Improvements
Make the block interval configurable via a constructor or setter

Combine with balance or gas logic for more intelligent triggers

Integrate with automation frameworks like Chainlink, Gelato, or webhooks

Use to monitor uptime or regular behavior across multiple chains

Metadata
Field	Value
Created	July 27, 2025
Author	Alexander ArtT
Telegram	@openagom
Discord	alexanderart
