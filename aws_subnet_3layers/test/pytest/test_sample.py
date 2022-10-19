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
        {"role_type": "sample", "result": True},
    ]
)
def sample_params(tfstate, request):
    """test_sampleのparamsを生成する
    その他、後始末処理関数の呼び出し

    Args:
        tfstate (class 'Tfstate')
        request (class '_pytest.fixtures.SubRequest')

    Yields:
        dict: test_sample()で利用する引数
    """
    # pre-proc
    role_type = request.param["role_type"]

    params = {
        "kwargs": {
            "aws_iam_role_arn": tfstate.get_attr(f'{TF_TEST_MODULE_PATH}.aws_iam_role.these["{role_type}"]')["arn"],
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

    def _can_create_session(aws_iam_role_arn):
        try:
            session = generate_boto3_session(aws_iam_role_arn)
        except Exception as e:
            return False
        return True

    assert _can_create_session(**params["kwargs"]) == params["result"]
