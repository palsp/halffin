from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS, fund_with_link
from scripts.escrow.deploy_escrow import deploy_escrow, create_order, update_shipment, get_contract
from brownie import network
import pytest


def test_request_shipping_detail(lock_period, selling_price):
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for testnet only")
#     seller = get_account()
#     buyer = get_account(1)

#     escrow = deploy_escrow(seller, lock_period)
#     fund_with_link(escrow.address)
#     create_order(buyer, selling_price)
#     update_shipment(seller, "1234")
#     get_contract("oracle")
#     tx_receipt = escrow.requestShippingDetail({"from": seller})
#     request_id = tx_receipt.events["ChainlinkRequested"]["id"]

#     # time.sleep(30)

#     # assert escrow.stage() == 3
#     # assert to_string(escrow.deliveryStatus()) == b'delivered'
