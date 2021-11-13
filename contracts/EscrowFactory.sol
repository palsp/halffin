// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Escrow.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EscrowFactory is Ownable {
    address linkToken;
    address oracle;
    string jobId;
    uint256 public maxLockPeriod;
    uint256 productCount;
    mapping(uint256 => address) products;

    constructor(
        address _linkToken,
        address _oracle,
        string memory _jobId,
        uint256 _maxLockPeriod
    ) {
        require(_maxLockPeriod >= 0, "lock period must be greater than 0");
        linkToken = _linkToken;
        oracle = _oracle;
        jobId = _jobId;
        productCount = 0;
        maxLockPeriod = _maxLockPeriod;
    }

    event ProductCreated(address indexed seller, address product);

    function createProduct(uint256 _price, uint256 _lockPeriod) external {
        uint256 lockPeriod = _lockPeriod;
        if (lockPeriod > maxLockPeriod) {
            lockPeriod = maxLockPeriod;
        }
        bytes32 salt = keccak256(
            abi.encodePacked(
                linkToken,
                oracle,
                jobId,
                msg.sender,
                _price,
                lockPeriod,
                productCount
            )
        );

        address product = address(new Escrow{salt: salt}());

        Escrow(product).init(
            linkToken,
            oracle,
            jobId,
            msg.sender,
            _price,
            lockPeriod
        );

        productCount++;
        products[productCount] = product;

        emit ProductCreated(msg.sender, product);
    }

    function setMaxLockPeriod(uint256 _maxLockPeriod) external onlyOwner {
        require(_maxLockPeriod >= 0, "lock period must be greater than 0");
        maxLockPeriod = _maxLockPeriod;
    }
}
