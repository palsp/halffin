const Web3 = require("web3");

let web3 = new Web3("ws://localhost:8545");
const { abi } = require("./chain-info/contracts/EscrowFactory.json");

const factoryContract = new web3.eth.Contract(
  abi,
  "0xaa38f5E212B4D22ffd63b21118F7D5a1a8CC3c55"
);

factoryContract.events.ProductCreated({ fromBlock: 0 }, (error, event) => {
  console.log("Product Created", event);
});
