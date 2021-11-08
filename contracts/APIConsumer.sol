// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;
    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;
    address private oracle;
    bytes32 private jobId;
    uint256 public games;

    event RequestGamesFulfilled(
        bytes32 indexed requestId,
        uint256 indexed games
    );

    constructor(address _oracle, string memory _jobId)
        ConfirmedOwner(msg.sender)
    {
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
    }

    function requestGames(string memory _playerId) external {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillGames.selector
        );
        req.add("playerId", _playerId);
        sendChainlinkRequestTo(oracle, req, ORACLE_PAYMENT);
    }

    function fulfillGames(bytes32 _requestId, uint256 _games)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestGamesFulfilled(_requestId, _games);
        games = _games;
    }

    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
