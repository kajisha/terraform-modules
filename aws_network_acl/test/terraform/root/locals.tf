locals {
  system_name          = "tftest"
  tested_module_name   = basename(abspath("../../../"))
  resource_name_prefix = replace("${local.system_name}-${local.tested_module_name}-${random_string.this.result}", "_", "-")
}


resource "random_string" "this" {
  length  = 5
  upper   = false
  special = false
}

