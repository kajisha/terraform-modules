import json
import subprocess
import sys


def exec_cmd(cmd, cwd, print_stdout=False, print_stderr=False):
    print("exec_cmd: {}...".format(" ".join(cmd)))
    proc = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if print_stdout:
        print(proc.stdout.decode("utf8"))
    if print_stderr:
        print(proc.stderr.decode("utf8"))

    proc.check_returncode()
    return proc


class Tfstate:
    def __init__(self, cwd):
        state = json.loads(exec_cmd(["terraform", "show", "-json"], cwd=cwd, print_stderr=True).stdout.decode("utf8"))
        self.root_module = state["values"]["root_module"]

    @classmethod
    def _get_attr(cls, module, target_addr):
        current_addr = module.get("address", "")
        next_rel_addr = ".".join(target_addr.removeprefix(current_addr + ".").split(".")[0:2])

        if next_rel_addr.startswith("module."):
            next_module_abs_addr = (current_addr + "." + next_rel_addr).removeprefix(".")

            for child_module in module["child_modules"]:
                if child_module["address"] == next_module_abs_addr:
                    return cls._get_attr(child_module, target_addr)

        else:
            for resource in module["resources"]:
                if resource["address"] == target_addr:
                    return resource["values"]

        raise Exception("{} is not found".format(target_addr))

    def get_attr(self, target_addr):
        return self._get_attr(self.root_module, target_addr)
