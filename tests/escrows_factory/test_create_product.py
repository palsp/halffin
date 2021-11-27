from brownie import network, Contract, Escrow
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, fund_with_link, get_account, LOCK_PERIOD, SELLING_PRICE, PRODUCT_NAME, PRODUCT_URI
from scripts.escrow_factory.deploy_factory import deploy_factory
from scripts.escrow_factory.create_product import create_product

import pytest


def test_can_create_product():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    account = get_account()
    escrow_factory = deploy_factory(LOCK_PERIOD)
    fund_with_link(escrow_factory)
    tx = escrow_factory.createProduct(
        PRODUCT_NAME, SELLING_PRICE, PRODUCT_URI, LOCK_PERIOD + 10, {"from": account})
    product_address = tx.events["ProductCreated"]["product"]
    escrow = Contract.from_abi(
        Escrow._name, product_address, Escrow.abi
    )

    assert escrow.product()["lockPeriod"] == LOCK_PERIOD
