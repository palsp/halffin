from brownie import Escrow, strings, config, network, Contract, interface
from scripts.helpful_scripts import get_account, get_contract, SELLING_PRICE, LOCK_PERIOD, PRODUCT_NAME
from web3 import Web3


def deploy_escrow(seller, lock_period=LOCK_PERIOD, product_name=PRODUCT_NAME):
    account = get_account()
    strings.deploy({"from": account})
    escrow = Escrow.deploy(
        {"from": account}, publish_source=config["networks"][network.show_active()].get("verify", False))
    escrow.init(
        get_contract("link_token").address,
        get_contract("oracle").address,
        config["networks"][network.show_active()]["post_job_id"],
        product_name,
        seller,
        SELLING_PRICE,
        lock_period,
        {"from": account}
    )

    return escrow


def create_order(buyer_account, fund=SELLING_PRICE):
    escrow = Escrow[-1]
    tx = escrow.order({"from": buyer_account, "value": fund})
    tx.wait(1)


def cancel_order(buyer_account):
    escrow = Escrow[-1]
    tx = escrow.cancelOrder({"from": buyer_account})
    tx.wait(1)


def update_shipment(seller_account, tracking_no):
    escrow = Escrow[-1]
    tx = escrow.updateShipment(tracking_no, {"from": seller_account})
    tx.wait(1)


def mock_delivered(seller_account):
    escrow = Escrow[-1]
    tx = escrow.mockDelivered({"from": seller_account})
    tx.wait(1)


def reclaim_fund(seller_account):
    escrow = Escrow[-1]
    tx = escrow.reclaimFund({"from": seller_account})
    tx.wait(1)


def main():
    account = get_account()
    deploy_escrow(account)
