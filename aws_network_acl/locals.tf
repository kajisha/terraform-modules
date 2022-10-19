locals {
  #======================
  # 命名
  #----------------------
  # フラグ
  /* append_module_name_to_resource_name_prefix
  true の場合、 local.resource_name_prefix は "${var.resource_name_prefix}-${moduleのディレクトリ名}[-${var.resource_name_suffix}]" となる
  false の場合、 local.resource_name_prefix は "${var.resource_name_prefix}[-${var.resource_name_suffix}]" となる
  */
  append_module_name_to_resource_name_prefix = false

  #----------------------
  # 変数
  _module_name = basename(abspath(path.module))

  resource_name_prefix = replace(
    join(
      "-",
      compact([
        var.resource_name_prefix,
        local.append_module_name_to_resource_name_prefix ? local._module_name : "",
        var.resource_name_suffix,
      ])
    ), "_", "-"
  )

  #======================
  # aws情報
  aws_account_id = data.aws_caller_identity.this.account_id
  region         = data.aws_region.this.name
}
