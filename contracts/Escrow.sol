// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./strings.sol";

contract Escrow is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;
    using strings for string;
    using strings for bytes32;

    uint256 private oracleFee;
    address private oracle;
    bytes32 private jobId;

    address factory;
    uint256 public lockPeriod;
    uint256 public currentBlock;

    struct Product {
        uint256 id;
        string name;
        uint256 price;
        address owner;
        address buyer;
        // IERC20 currency;
        bool purchased;
        string trackingId;
        string deliveryStatus;
        Stage stage;
    }

    Product public product;

    // address public buyer;
    // address public seller;
    // uint256 public price;

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
    event OrderCompleted(string trackingNo);

    modifier validStage(Stage _stage, string memory message) {
        require(product.stage == _stage, message);
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == product.buyer, "Only Buyer");
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    function init(
        address _link,
        address _oracle,
        string memory _jobId,
        uint256 _id,
        string memory _name,
        address _seller,
        // address _currency,
        uint256 _price,
        uint256 _lockPeriod,
        uint256 _oracleFee
    ) external {
        require(msg.sender == factory, "FORBIDDEN");
        // setPublicChainlinkToken();
        setChainlinkToken(_link);
        transferOwnership(_seller);
        oracle = _oracle;
        jobId = _jobId.stringToBytes32();
        lockPeriod = _lockPeriod;
        oracleFee = _oracleFee;

        product.id = _id;
        product.name = _name;
        product.stage = Stage.Initiate;
        product.owner = _seller;
        // currency = IERC20(_currency);
        product.price = _price;
    }

    function order()
        external
        payable
        validStage(Stage.Initiate, "Already have a buyer")
    {
        require(msg.sender != owner(), "You can not buy from yourself");
        require(msg.value >= product.price, "Not enough fund");
        product.stage = Stage.WaitForShipping;
        product.buyer = msg.sender;
        currentBlock = block.number;
        // currency.transferFrom(msg.sender, address(this), price);
        emit OrderInitiate(product.buyer);
    }

    function cancelOrder()
        external
        onlyBuyer
        validStage(Stage.WaitForShipping, "shipping in progress")
    {
        require(
            block.number >= currentBlock + lockPeriod,
            "Not allowed to cancel order"
        );
        product.buyer = address(0);
        product.stage = Stage.Initiate;
        // currency.transfer(msg.sender, price);
        payable(msg.sender).transfer(address(this).balance);
        emit OrderCancel(msg.sender);
    }

    function updateShipment(string memory _trackingId)
        external
        onlyOwner
        validStage(Stage.WaitForShipping, "Invalid Stage")
    {
        product.stage = Stage.Shipping;
        product.trackingId = _trackingId;
        emit ShipmentInprogress(product.trackingId);
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

        req.add("trackingId", product.trackingId);
        bytes32 requestId = sendChainlinkRequestTo(oracle, req, oracleFee);
        emit ChainlinkRequested(requestId);
    }

    function fulfillShippingDetail(bytes32 _requestId, bytes32 _deliveryStatus)
        public
        recordChainlinkFulfillment(_requestId)
    {
        product.deliveryStatus = _deliveryStatus.bytes32ToString();
        if (product.deliveryStatus.compareStrings("Delivered")) {
            product.stage = Stage.Delivered;
        }

        emit ShipmentUpdated(_deliveryStatus);
    }

    function reclaimFund()
        external
        onlyOwner
        validStage(Stage.Delivered, "Invalid Stage")
    {
        // currency.transfer(msg.sender, address(this).balance);
        product.stage = Stage.End;
        payable(msg.sender).transfer(address(this).balance);
    }
}
