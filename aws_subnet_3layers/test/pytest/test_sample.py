import boto3
import pytest
from common import Tfstate

########################
# 本ファイル名（suffix除く）と、test用リソースの定義を含むterraform module名は一致する必要がある
TF_TEST_MODULE_PATH = "module.{}".format(__name__.removeprefix("__").removesuffix("__"))


########################
# sample
@pytest.fixture(
    params=[
        {"source": "webs", "destination": "webs", "result": True},
        {"source": "webs", "destination": "apps", "result": True},
        {"source": "webs", "destination": "databases", "result": False},
        {"source": "apps", "destination": "webs", "result": True},
        {"source": "apps", "destination": "apps", "result": True},
        {"source": "apps", "destination": "webs", "result": True},
        {"source": "databases", "destination": "webs", "result": False},
        {"source": "databases", "destination": "apps", "result": False},
        {"source": "databases", "destination": "databases", "result": True},
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

    source = request.param["source"]
    destination = request.param["destination"]

    params = {
        "kwargs": {
            "aws_ec2_network_insights_analysis_id": _tfstate.get_attr(
                f'{TF_TEST_MODULE_PATH}.aws_ec2_network_insights_analysis.these["{source}_{destination}"]'
            )["id"],
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

    def _can_reachable(aws_ec2_network_insights_analysis_id):
        client = boto3.client("ec2")
        response = client.describe_network_insights_analyses(
            NetworkInsightsAnalysisIds=[aws_ec2_network_insights_analysis_id],
        )

        for info in response["NetworkInsightsAnalyses"][0]["ForwardPathComponents"]:
            component_id = info["Component"]["Id"]

            if component_id.startswith("sg-"):
                if not "SecurityGroupRule" in info:
                    return False

            elif component_id.startswith("acl-"):
                if not "AclRule" in info:
                    return False

            elif component_id.startswith("rtb-"):
                if not "RouteTableRoute" in info:
                    return False

        return True

    assert _can_reachable(**params["kwargs"]) == params["result"]
