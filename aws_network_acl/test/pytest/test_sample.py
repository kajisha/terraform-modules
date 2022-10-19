import json

import pytest
from aws import generate_boto3_session
from common import Tfstate

########################
# 本ファイル名（suffix除く）と、test用リソースの定義を含むterraform module名は一致する必要がある
TF_TEST_MODULE_PATH = "module.{}".format(__name__.removeprefix("__").removesuffix("__"))


########################
# sample
@pytest.fixture(
    params=[
        {
            "egress": "egress",
            "rule_number": 1,
            "result": {
                "egress": True,
                "rule_number": 1,
                "rule_action": "allow",
                "cidr_block": "10.1.0.0/32",
                "from_port": 443,
                "to_port": 443,
                "protocol": "6",  # tcp
            },
        },
        {
            "egress": "egress",
            "rule_number": 2,
            "result": {
                "egress": True,
                "rule_number": 2,
                "rule_action": "allow",
                "cidr_block": "10.1.0.1/32",
                "from_port": 443,
                "to_port": 443,
                "protocol": "6",  # tcp
            },
        },
        {
            "egress": "egress",
            "rule_number": 101,
            "result": {
                "egress": True,
                "rule_number": 101,
                "rule_action": "deny",
                "cidr_block": "0.0.0.0/0",
                "from_port": None,
                "to_port": None,
                "protocol": "-1",
            },
        },
        {
            "egress": "ingress",
            "rule_number": 1,
            "result": {
                "egress": False,
                "rule_number": 1,
                "rule_action": "allow",
                "cidr_block": "10.1.0.0/32",
                "from_port": None,
                "to_port": None,
                "protocol": "-1",
            },
        },
        {
            "egress": "ingress",
            "rule_number": 2,
            "result": {
                "egress": False,
                "rule_number": 2,
                "rule_action": "allow",
                "cidr_block": "10.1.0.1/32",
                "from_port": None,
                "to_port": None,
                "protocol": "-1",
            },
        },
        {
            "egress": "ingress",
            "rule_number": 101,
            "result": {
                "egress": False,
                "rule_number": 101,
                "rule_action": "deny",
                "cidr_block": "0.0.0.0/0",
                "from_port": None,
                "to_port": None,
                "protocol": "-1",
            },
        },
    ]
)
def sample_params(tfstate_no_reset, request):
    """test_sampleのparamsを生成する
    その他、後始末処理関数の呼び出し

    Args:
        tfstate (class 'Tfstate')
        request (class '_pytest.fixtures.SubRequest')

    Yields:
        dict: test_sample()で利用する引数
    """
    _tfstate = tfstate_no_reset
    egress = request.param["egress"]
    rule_number = request.param["rule_number"]

    params = {
        "kwargs": {
            "aws_network_acl_rule": _tfstate.get_attr(
                f'{TF_TEST_MODULE_PATH}.module.this.aws_network_acl_rule.these["{egress}_{rule_number}"]'
            ),
        },
        "result": request.param["result"],
    }

    yield params
    post_proc_for_test_sample(**params["kwargs"])


def post_proc_for_test_sample(**kwargs):
    """test_sampleの後始末
    不要な場合はpassを書く

    Args:
        **kwargs
    """
    pass


def test_sample(sample_params):
    params = sample_params

    for key in params["result"].keys():
        assert params["kwargs"]["aws_network_acl_rule"][key] == params["result"][key]
