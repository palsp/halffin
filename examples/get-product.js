const Web3 = require("web3");

const web3 = new Web3("ws://localhost:8545");
const contractAddress = "YOUR_CONTRACT_ADDRESS";

// replace the following with your abi
const {
  abi,
} = require("./get-products-js/chain-info/contracts/EscrowFactory.json");

const factoryContract = new web3.eth.Contract(abi, contractAddress);

factoryContract.events.ProductCreated({ fromBlock: 0 }, (error, event) => {
  console.log("Product Created", event);
});
