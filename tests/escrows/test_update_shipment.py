import pytest
from brownie import network, exceptions
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
from scripts.escrow.deploy_escrow import deploy_escrow, create_order


def test_cant_update_shipment_with_empty_tracking_id():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account()
    escrow = deploy_escrow(seller)
    buyer = get_account(1)
    create_order(buyer)
    with pytest.raises(exceptions.VirtualMachineError):
        escrow.updateShipment("", {"from": seller})


def test_can_update_shipment():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("for development only")
    seller = get_account()
    escrow = deploy_escrow(seller)
    buyer = get_account(1)
    create_order(buyer)
    escrow.updateShipment("qzpb3vgewrgpgkwgl1gs102g", {"from": seller})
