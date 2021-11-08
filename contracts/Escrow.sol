// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Escrow is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY;
    address private oracle;
    bytes32 private jobId;

    Stage public stage;
    address public buyer;
    address public seller;
    uint256 public price;
    IERC20 public currency;

    uint256 public lockPeriod;
    uint256 public currentBlock;
    string trackingNo;
    string public deliveryStatus;

    enum Stage {
        Initiate,
        WaitForShipping,
        Shipping,
        Delivered,
        End
    }

    event OrderInitiate(address indexed _buyer);
    event OrderCancel(address indexed _buyer);

    event ShipmentInprogress(string trackingNo);
    event ShipmentUpdated(bytes32 status);
    event ShipmentDelivered(bytes32 status);
    event OrderCompleted(string trackingNo);

    modifier validStage(Stage _stage, string memory message) {
        require(_stage == stage, message);
        _;
    }

    constructor(
        address _link,
        address _oracle,
        string memory _jobId,
        address _seller,
        // address _currency,
        uint256 _price,
        uint256 _lockPeriod
    ) {
        // setPublicChainlinkToken();
        setChainlinkToken(_link);
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        stage = Stage.Initiate;
        seller = _seller;
        // currency = IERC20(_currency);
        price = _price;
        lockPeriod = _lockPeriod;
    }

    function order()
        external
        payable
        validStage(Stage.Initiate, "Already have a buyer")
    {
        require(msg.sender != seller, "You can not buy from yourself");
        require(msg.value >= price, "Not enough fund");
        stage = Stage.WaitForShipping;
        buyer = msg.sender;
        currentBlock = block.number;
        // currency.transferFrom(msg.sender, address(this), price);
        emit OrderInitiate(buyer);
    }

    function cancelOrder()
        external
        validStage(Stage.WaitForShipping, "shipping in progress")
    {
        require(msg.sender == buyer, "Only buyer");

        require(
            block.number >= currentBlock + lockPeriod,
            "Not allowed to cancel order"
        );
        buyer = address(0);
        stage = Stage.Initiate;
        // currency.transfer(msg.sender, price);
        payable(msg.sender).transfer(address(this).balance);
        emit OrderCancel(msg.sender);
    }

    function updateShipment(string memory _trackingNO)
        external
        validStage(Stage.WaitForShipping, "Invalid Stage")
    {
        require(msg.sender == seller, "Only Seller");

        stage = Stage.Shipping;
        trackingNo = _trackingNO;
        emit ShipmentInprogress(trackingNo);
    }

    function requestShippingDetail()
        external
        validStage(Stage.Shipping, "Need shipment")
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillShippingDetail.selector
        );

        req.add("trackingNo", trackingNo);
        bytes32 requestId = sendChainlinkRequestTo(oracle, req, ORACLE_PAYMENT);
        emit ChainlinkRequested(requestId);
    }

    function fulfillShippingDetail(bytes32 _requestId, bytes32 _deliveryStatus)
        public
        recordChainlinkFulfillment(_requestId)
    {
        deliveryStatus = bytes32ToString(_deliveryStatus);
        if (compareStrings(deliveryStatus, "delivered")) {
            stage = Stage.Delivered;
            emit ShipmentDelivered(_deliveryStatus);
        } else {
            emit ShipmentUpdated(_deliveryStatus);
        }
    }

    function test(bytes32 _status) public {
        deliveryStatus = bytes32ToString(_status);
        // require(compareStrings(deliveryStatus, "delivered"));
    }

    function reclaimFund()
        external
        validStage(Stage.Delivered, "Invalid Stage")
    {
        require(msg.sender == seller, "Only Seller");

        // currency.transfer(msg.sender, address(this).balance);
        stage = Stage.End;
        payable(msg.sender).transfer(address(this).balance);
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

    function bytes32ToString(bytes32 _bytes32)
        public
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function compareStrings(string memory a, string memory b)
        private
        view
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
