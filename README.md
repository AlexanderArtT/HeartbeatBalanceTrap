# HeartbeatBalanceTrap

## Objective
Create a functional Drosera trap that:
- Tracks the blockchain’s `block.number` every time `collect()` is called.
- Triggers a response every 3 blocks — independent of ETH balance changes.
- Sends a signal to an external alert contract on a predictable, timed interval.

## Problem
In some cases (monitoring system health, testing Drosera responsiveness, scheduled workflows), traps should trigger on a block schedule rather than balance changes.

## Solution
Implement a time-based trap that activates every 3rd block regardless of ETH transfers or external input.

## Trap Logic

**Contract: HeartbeatBalanceTrap.sol**

```solidity
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
```

## Response Contract

**Contract: FrequentAlertReceiver.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FrequentAlertReceiver {
    event FrequentAlert(string message, uint256 blockNumber);

    function notify() external {
        emit FrequentAlert("Frequent heartbeat alert triggered", block.number);
    }
}
```


## Deployment & Setup

Deploy contracts with Foundry:

bash

```solidity
forge create src/FrequentAlertReceiver.sol:FrequentAlertReceiver \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0xYOUR_PRIVATE_KEY
```

```solidity
forge create src/HeartbeatBalanceTrap.sol:HeartbeatBalanceTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0xYOUR_PRIVATE_KEY
```

Update `drosera.toml`:

[traps.heartbeat]

path = "out/HeartbeatBalanceTrap.sol/HeartbeatBalanceTrap.json"

response_contract = "0xYOUR_FrequentAlertReceiver_ADDRESS"

response_function = "notify()"

Apply changes:

bash

```solidity
DROSERA_PRIVATE_KEY=0xYOUR_PRIVATE_KEY drosera apply
```

## Testing the Trap
- Wait for new blocks on the Ethereum Hoodi testnet.
- On blocks divisible by 3, trap triggers with `shouldRespond = true`.
- `FrequentAlert` event is emitted.

## Extensions & Improvements
- Allow dynamic interval setting.
- Add balance delta or gas usage checks.
- Chain this trap with anomaly detectors.
- Use `notify()` to ping webhooks or trigger automation flows.

## Metadata
- Created: July 27, 2025
- Author: @Alexander_ArtT
- Telegram: @openagom
- Discord: alexanderart
