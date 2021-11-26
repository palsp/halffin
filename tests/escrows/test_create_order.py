
import pytest
from brownie import network, exceptions
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
from scripts.escrow.deploy_escrow import deploy_escrow, create_order


def test_cant_buy_own_product():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    deploy_escrow(seller)
    with pytest.raises(exceptions.VirtualMachineError):
        create_order(seller)


def test_cant_create_order_if_buyer_exist():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    deploy_escrow(seller)
    buyer_1 = get_account(1)
    buyer_2 = get_account(2)
    create_order(buyer_1)
    with pytest.raises(exceptions.VirtualMachineError):
        create_order(buyer_2)


def test_cant_create_order_if_not_enough_fund():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    deploy_escrow(seller)
    buyer = get_account(1)
    with pytest.raises(exceptions.VirtualMachineError):
        create_order(buyer, 0)


def test_can_create_order():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    escrow = deploy_escrow(seller)
    buyer = get_account(1)
    starting_buyer_balance = buyer.balance()
    assert escrow.product()["stage"] == 0
    create_order(buyer)
    # buyer
    assert escrow.product()["buyer"] == buyer
    assert escrow.product()["stage"] == 1
    assert buyer.balance() == starting_buyer_balance - escrow.balance()
