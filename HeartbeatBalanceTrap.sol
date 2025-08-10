// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract HeartbeatBalanceTrap is ITrap {
    address public constant target = 0x3B80fEDa59d8dCC17D23c0484767e54739C93103;

    struct CollectOutput {
        uint256 blockNumber;
    }

    function collect() external view override returns (bytes memory) {
        return abi.encode(CollectOutput({
            blockNumber: block.number
        }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        CollectOutput memory current = abi.decode(data[0], (CollectOutput));
        
        if (current.blockNumber % 3 == 0) {
            return (true, "");
        }

        return (false, "");
    }
}
