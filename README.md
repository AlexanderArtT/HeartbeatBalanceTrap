# HeartbeatBalanceTrap
🫀 Heartbeat Balance Trap
🎯 Objective
Create a functional Drosera trap that:

⛓ Tracks the blockchain’s block.number every time collect() is called

⏱ Triggers a response every 3 blocks — completely independent of any ETH balance changes

🧩 Sends a signal to an external alert contract on a predictable, timed interval

⚠️ Problem
In certain cases — such as monitoring system health, testing Drosera responsiveness, or triggering regular logic executions — we need traps that do not depend on balance anomalies or wallet activity, but instead execute on a block schedule.

Examples include:

Simulated "heartbeat" triggers

Scheduled smart contract workflows

Infrastructure liveness checks

✅ Solution
Implement a time-based trap that activates on a simple rule:
every third block, regardless of ETH transfers, balances, or external input.

This provides a predictable, blockchain-driven interval for executing Drosera responses.

🧠 Trap Logic
✅ Contract: HeartbeatBalanceTrap.sol
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
📣 Response Contract: FrequentAlertReceiver.sol
solidity
Копировать
Редактировать
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FrequentAlertReceiver {
    event FrequentAlert(string message, uint256 blockNumber);

    function notify() external {
        emit FrequentAlert("🟢 Frequent heartbeat alert triggered", block.number);
    }
}
🚀 Deployment & Setup
📦 Deploy Contracts (via Foundry)
bash
Копировать
Редактировать
forge create src/FrequentAlertReceiver.sol:FrequentAlertReceiver \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0xYOUR_PRIVATE_KEY

forge create src/HeartbeatBalanceTrap.sol:HeartbeatBalanceTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0xYOUR_PRIVATE_KEY
🛠 Update drosera.toml
toml
Копировать
Редактировать
[traps.heartbeat]
path = "out/HeartbeatBalanceTrap.sol/HeartbeatBalanceTrap.json"
response_contract = "0xYOUR_FrequentAlertReceiver_ADDRESS"
response_function = "notify()"
⚙️ Apply Changes
bash
Копировать
Редактировать
DROSERA_PRIVATE_KEY=0xYOUR_PRIVATE_KEY drosera apply
🧪 Testing the Trap
Wait for new blocks on the Ethereum Hoodi testnet

Monitor Drosera logs or events on Etherscan

On blocks divisible by 3 (e.g. #123, #126...), the trap triggers:

shouldRespond = true

FrequentAlert event is emitted

🧩 Extensions & Improvements
🔁 Allow dynamic interval (e.g., trigger every N blocks)

🧠 Include extra logic like balance deltas or gas usage

🔔 Chain this trap with anomaly detectors to combine time-based and logic-based responses

📡 Use notify() to ping webhooks or trigger automation flows (Chainlink, Gelato, etc.)

🧾 Metadata
📅 Created: July 27, 2025

👨‍💻 Author: @Alexander_ArtT

🔗 Telegram: @openagom

💬 Discord: alexanderart
