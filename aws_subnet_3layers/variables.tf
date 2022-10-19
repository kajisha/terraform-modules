variable "resource_name_prefix" {
  type = string

  description = <<DESC
リソース名に設定されるprefixの元となる文字列。
module内のリソースの命名に利用する変数は local.resource_name_prefix であることに注意する。
DESC
}


variable "append_module_name_to_resource_name_prefix" {
  type    = bool
  default = true

  description = <<DESC
true の場合、 local.resource_name_prefix の末尾に local.module_name を追加する。
local.module_name の説明は、 var.module_name_suffix のdescriptionを参照。
DESC
}


variable "module_name_suffix" {
  type    = string
  default = ""

  description = <<DESC
本引数に "" を指定した場合、 local.module_name は "{module名のディレクトリ名}" となる。
本引数に "" 以外を指定した場合、 local.module_name は "{module名のディレクトリ名}-{var.module_name_suffix}" となる。

同一moduleを複数作成したい場合に利用する。
DESC
}
