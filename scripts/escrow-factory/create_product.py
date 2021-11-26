from scripts.helpful_scripts import get_account, SELLING_PRICE, LOCK_PERIOD
from brownie import EscrowFactory


def create_product(lock_period=LOCK_PERIOD):
    account = get_account()
    escrow_factory = EscrowFactory[-1]
    tx = escrow_factory.createProduct(
        "iphone X", SELLING_PRICE, lock_period, {"from": account})
    print(
        f'escrow contract created for {tx.events["ProductCreated"]["seller"]}')
    print(
        f'escrow contract deployed at {tx.events["ProductCreated"]["product"]}')


def main():
    create_product()
