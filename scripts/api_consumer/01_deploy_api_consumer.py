from scripts.helpful_scripts import get_account, fund_with_link
from brownie import APIConsumer, Oracle, config, network


def deploy_api_consumer():
    account = get_account()
    post_job_id = config["networks"][network.show_active()]["post_job_id"]
    oracle = Oracle[-1]
    api_consumer = APIConsumer.deploy(
        oracle.address, post_job_id, {"from": account})
    fund_with_link(api_consumer.address)
    return api_consumer


def main():
    # api_consumer = deploy_api_consumer()
    # print(api_consumer.games())
    # tx = api_consumer.requestGames("90026531")
    # tx.wait(1)

    api_consumer = APIConsumer[-1]
    print(api_consumer.games())
