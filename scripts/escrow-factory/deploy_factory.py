from brownie import EscrowFactory, strings, config, network
from scripts.helpful_scripts import get_account, get_contract, SELLING_PRICE, LOCK_PERIOD


def deploy_factory(lock_period=LOCK_PERIOD):
    account = get_account()
    strings.deploy({"from": account})
    escrow_factory = EscrowFactory.deploy(
        get_contract("link_token").address,
        get_contract("oracle").address,
        config["networks"][network.show_active()]["post_job_id"],
        lock_period,
        {"from": account}
    )
    return escrow_factory


def main():
    deploy_factory()
