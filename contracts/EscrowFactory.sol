// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Escrow.sol";

contract EscrowFactory {
    address linkToken;
    address oracle;
    string jobId;
    uint256 public maxLockPeriod;

    constructor(
        address _linkToken,
        address _oracle,
        string memory _jobId,
        uint256 _maxLockPeriod
    ) {
        linkToken = _linkToken;
        oracle = _oracle;
        jobId = _jobId;
        maxLockPeriod = _maxLockPeriod;
    }

    event ProductCreated(address indexed seller, address product);

    function createProduct(uint256 _price, uint256 _lockPeriod)
        external
        returns (address addr)
    {
        uint256 lockPeriod = _lockPeriod;
        if (lockPeriod > maxLockPeriod) {
            lockPeriod = maxLockPeriod;
        }
        bytes memory bytecode = type(Escrow).creationCode;
        bytes32 salt = keccak256(
            abi.encodePacked(
                linkToken,
                oracle,
                jobId,
                msg.sender,
                _price,
                lockPeriod
            )
        );

        assembly {
            addr := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        Escrow(addr).init(
            linkToken,
            oracle,
            jobId,
            msg.sender,
            _price,
            lockPeriod
        );

        emit ProductCreated(msg.sender, addr);
        return addr;
    }
}
