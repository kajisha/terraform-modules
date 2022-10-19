locals {
  # 命名系
  _module_name = basename(abspath(path.module))
  module_name  = var.module_name_suffix == "" ? local._module_name : "${local._module_name}-${var.module_name_suffix}"

  resource_name_prefix = replace(var.append_module_name_to_resource_name_prefix == true ? "${var.resource_name_prefix}-${local.module_name}" : var.resource_name_prefix, "_", "-")

  # aws情報
  aws_account_id = data.aws_caller_identity.this.account_id
  region         = data.aws_region.this.name
}
