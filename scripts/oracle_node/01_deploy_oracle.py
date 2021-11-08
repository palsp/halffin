from brownie import Oracle, config, network
from scripts.helpful_scripts import get_contract, get_account


def deploy_oracle():
    account = get_account()
    # deploy my oracle
    # link oracle with jobID
    link_token = get_contract("link_token").address
    oracle = Oracle.deploy(
        link_token,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify", False),
    )
    return oracle


def set_fulfillment_permission(oracle):
    account = get_account()
    node_address = config["networks"][network.show_active()]["chainlink_node"]
    oracle.setFulfillmentPermission(node_address, True, {"from": account})


def main():
    oracle = deploy_oracle()
    print(f"oracle contract deploy at {oracle.address}")
    set_fulfillment_permission(oracle)
