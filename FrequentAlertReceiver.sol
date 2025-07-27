// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FrequentAlertReceiver {
    event FrequentAlert(string message, uint256 blockNumber);

    function notify() external {
        emit FrequentAlert("Frequent heartbeat alert triggered", block.number);
    }
}
