import time

import pytest
from common import Tfstate, exec_cmd

CWD = "../terraform/root"


def pytest_addoption(parser):
    """Add pytest command options."""
    parser.addoption("--no-destroy", action="store_true", default=False, help="not destroy when pytest end")


@pytest.fixture(scope="session", autouse=True)
def tf_init_final(request):
    exec_cmd(["terraform", "init"], cwd=CWD, print_stdout=True, print_stderr=True)

    # object生成の遅延によるエラー防止のため、とりあえずterraform applyする
    exec_cmd(["terraform", "apply", "-lock=false", "-auto-approve"], cwd=CWD, print_stdout=True, print_stderr=True)
    time.sleep(5)
    yield

    if request.config.getoption("--no-destroy"):
        print("resources craeted by terraform will not delete.")
        return
    exec_cmd(
        ["terraform", "apply", "-lock=false", "-destroy", "-auto-approve"],
        cwd=CWD,
        print_stdout=True,
        print_stderr=True,
    )


@pytest.fixture(scope="function", autouse=False)
def reset():
    exec_cmd(["terraform", "apply", "-lock=false", "-auto-approve"], cwd=CWD, print_stdout=True, print_stderr=True)
    return


@pytest.fixture(scope="function", autouse=False)
def tfstate(reset):
    tfstate = Tfstate(CWD)
    return tfstate


@pytest.fixture(scope="function", autouse=False)
def tfstate_no_reset():
    tfstate = Tfstate(CWD)
    return tfstate
