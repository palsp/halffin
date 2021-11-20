from brownie import EscrowFactory, strings, config, network
from scripts.helpful_scripts import fund_with_link, get_account, get_contract, SELLING_PRICE, LOCK_PERIOD
from web3 import Web3


def deploy_factory(lock_period=LOCK_PERIOD):
    account = get_account()
    strings.deploy({"from": account})
    jobId = config["networks"][network.show_active()]["post_job_id"]
    escrow_factory = EscrowFactory.deploy(
        bytes(jobId, 'utf-8'),
        get_contract("link_token").address,
        get_contract("oracle").address,
        lock_period,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify", False)
    )
    fund_with_link(escrow_factory, amount=Web3.toWei(100, "ether"))
    # escrow_factory = EscrowFactory[-1]
    # EscrowFactory.publish_source(escrow_factory)
    return escrow_factory


def main():
    deploy_factory()
