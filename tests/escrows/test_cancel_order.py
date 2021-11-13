from scripts.escrow.deploy_escrow import deploy_escrow, create_order, update_shipment, SELLING_PRICE
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account, move_blocks
from brownie import network, chain, exceptions
import pytest

LOCK_PERIOD = 10


def test_cant_cancel_order_before_lock_period():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    escrow = deploy_escrow(seller)
    buyer = get_account(1)
    create_order(buyer)
    print("expected chain height", chain.height + LOCK_PERIOD)
    with pytest.raises(exceptions.VirtualMachineError):
        escrow.cancelOrder({"from": buyer})


def test_can_cancel_order_after_lock_period():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    escrow = deploy_escrow(seller, LOCK_PERIOD)
    buyer = get_account(1)
    create_order(buyer, SELLING_PRICE)
    move_blocks(LOCK_PERIOD)
    starting_buyer_balance = buyer.balance()
    escrow_balance = escrow.balance()
    escrow.cancelOrder({"from": buyer})
    # stage
    assert escrow.product()[-1] == 0
    #  buyer
    assert escrow.product()[4] == '0x0000000000000000000000000000000000000000'
    assert escrow.balance() == 0
    assert buyer.balance() == starting_buyer_balance + escrow_balance


def test_cant_cancel_order_after_shipping_stage():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    escrow = deploy_escrow(seller, LOCK_PERIOD)
    buyer = get_account(1)
    create_order(buyer, SELLING_PRICE)
    move_blocks(LOCK_PERIOD)
    update_shipment(seller, "1234")
    with pytest.raises(exceptions.VirtualMachineError):
        escrow.cancelOrder({"from": buyer})


def test_cant_cancel_from_non_buyer():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account(0)
    escrow = deploy_escrow(seller, LOCK_PERIOD)
    buyer = get_account(1)
    attacker = get_account(2)
    create_order(buyer, SELLING_PRICE)
    move_blocks(LOCK_PERIOD)
    with pytest.raises(exceptions.VirtualMachineError):
        escrow.cancelOrder({"from": attacker})
