# Halffin-contract

## Prerequisites

Please install or have installed the following:

- [nodejs and npm](https://nodejs.org/en/download/)
- [python](https://www.python.org/downloads/)

## Installation

1. [Install Brownie](https://eth-brownie.readthedocs.io/en/stable/install.html), if you haven't already. Here is a simple way to install brownie.

```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
# restart your terminal
pipx install eth-brownie
```

Or, if that doesn't work, via pip

```bash
pip install eth-brownie
```

2. [Set up and install Chainlink node](https://docs.chain.link/docs/running-a-chainlink-node/)

3. [Set up external adapters](https://github.com/palsp/halffin-adapter)

## Testnet Development

If you want to be able to deploy to testnets, do the following.

Set your `WEB3_INFURA_PROJECT_ID`, `PRIVATE_KEY`, and `CHAINLINK_NODE_ADDRESS` [environment variables](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html).

You can get a `WEB3_INFURA_PROJECT_ID` by getting a free trial of [Infura](https://infura.io/). At the moment, it does need to be infura with brownie. If you get lost, you can [follow this guide](https://ethereumico.io/knowledge-base/infura-api-key-guide/) to getting a project key. You can find your `PRIVATE_KEY` from your ethereum wallet like [metamask](https://metamask.io/).

You'll also need testnet ETH and LINK. You can get LINK and ETH into your wallet by using the [faucets located here](https://docs.chain.link/docs/link-token-contracts). If you're new to this, [watch this video.](https://www.youtube.com/watch?v=P7FX_1PePX0). Look at the `rinkeby` and `kovan` sections for those specific testnet faucets.

You'll need chainlink node and external adapters.

You can add your environment variables to a `.env` file. You can use the [.env.exmple](https://github.com/smartcontractkit/chainlink-mix/blob/master/.env.example) as a template, just fill in the values and rename it to '.env'. Then, uncomment the line `# dotenv: .env` in `brownie-config.yaml`

Here is what your `.env` should look like:

```
export WEB3_INFURA_PROJECT_ID=<PROJECT_ID>
export PRIVATE_KEY=<PRIVATE_KEY>
export CHAINLINK_NODE_ADDRESS=<NODE_ADDRESS>
```

AND THEN RUN `source .env` TO ACTIVATE THE ENV VARIABLES
(You'll need to do this everytime you open a new terminal, or [learn how to set them easier](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html))

![WARNING](https://via.placeholder.com/15/f03c15/000000?text=+) **WARNING** ![WARNING](https://via.placeholder.com/15/f03c15/000000?text=+)

DO NOT SEND YOUR PRIVATE KEY WITH FUNDS IN IT ONTO GITHUB

Otherwise, you can build, test, and deploy on your local environment.

## Local Development

For local testing [install ganache-cli](https://www.npmjs.com/package/ganache-cli)

```bash
npm install -g ganache-cli
```

or

```bash
yarn add global ganache-cli
```

All the scripts are designed to work locally or on a testnet. You can add a ganache-cli or ganache UI chain like so:

```
brownie networks add Ethereum ganache host=http://localhost:8545 chainid=1337
```

And update the brownie config accordingly. There is a `deploy_mocks` script that will launch and deploy mock Oracles, VRFCoordinators, Link Tokens, and Price Feeds on a Local Blockchain.

## Running Scripts and Deployment

> NOTE: We will keep our adapter and chainlink node up and running on kovan network until the end of December 2021. if you are running on kovan and wish to use our oracle, feel free to skip to instruction 3.

1. deploy oracle and allow fulfill permission for our chainlink node

```
brownie run scripts/oracle_node/deploy_oracle.py --network kovan
```

2. copy the deployed oracle address and paste it in the external adapter job description

3. deploy factory contract

```
brownie run scripts/escrow-factory/deploy_factory.py --network kovan
```

4. create sample escrow contract

```
brownie run scripts/escrow-factory/create_product.py --network kovan
```

### Local Development

For local development, you might want to deploy mocks. You can run the script to deploy mocks. Depending on your setup, it might make sense to _not_ deploy mocks if you're looking to fork a mainnet. It all depends on what you're looking to do though. Right now, the scripts automatically deploy a mock so they can run.

## Testing

```
brownie test
```

For more information on effective testing with Chainlink, check out [Testing Smart Contracts](https://blog.chain.link/testing-chainlink-smart-contracts/)

Tests are really robust here! They work for local development and testnets. There are a few key differences between the testnets and the local networks. We utilize mocks so we can work with fake oracles on our testnets.

There is a `test_unnecessary` folder, which is a good exersize for learning some of the nitty-gritty of smart contract development. It's overkill, so pytest will skip them intentionally. It also has a `test_samples` folder, which shows an example Chainlink API call transaction receipt.

### To test development / local

```bash
brownie test
```

### To test mainnet-fork

This will test the same way as local testing, but you will need a connection to a mainnet blockchain (like with the infura environment variable.)

```bash
brownie test --network mainnet-fork
```

### To test a testnet

Kovan and Rinkeby are currently supported

```bash
brownie test --network kovan
```

## Adding additional Chains

If the blockchain is EVM Compatible, adding new chains can be accomplished by something like:

```
brownie networks add Ethereum binance-smart-chain host=https://bsc-dataseed1.binance.org chainid=56
```

or, for a fork:

```
brownie networks add development binance-fork cmd=ganache-cli host=http://127.0.0.1 fork=https://bsc-dataseed1.binance.org accounts=10 mnemonic=brownie port=8545
```

## Linting

```
pip install black
pip install autoflake
autoflake --in-place --remove-unused-variables --remove-all-unused-imports -r .
black .
```

If you're using [vscode](https://code.visualstudio.com/) and the [solidity extension](https://github.com/juanfranblanco/vscode-solidity), you can create a folder called `.vscode` at the root folder of this project, and create a file called `settings.json`, and add the following content:

```json
{
  "solidity.remappings": [
    "@chainlink/=[YOUR_HOME_DIR]/.brownie/packages/smartcontractkit/chainlink-brownie-contracts@0.2.2",
    "@openzeppelin/=[YOUR_HOME_DIR]/.brownie/packages/OpenZeppelin/openzeppelin-contracts@4.3.2"
  ]
}
```

This will quiet the linting errors it gives you.

## Resources

To get started with Brownie:

- [Chainlink Documentation](https://docs.chain.link/docs)
- Check out the [Chainlink documentation](https://docs.chain.link/docs) to get started from any level of smart contract engineering.
- Check out the other [Brownie mixes](https://github.com/brownie-mix/) that can be used as a starting point for your own contracts. They also provide example code to help you get started.
- ["Getting Started with Brownie"](https://medium.com/@iamdefinitelyahuman/getting-started-with-brownie-part-1-9b2181f4cb99) is a good tutorial to help you familiarize yourself with Brownie.
- For more in-depth information, read the [Brownie documentation](https://eth-brownie.readthedocs.io/en/stable/).

Any questions? Join our [Discord](https://discord.gg/2YHSAey)

## License

This project is licensed under the [MIT license](LICENSE).
