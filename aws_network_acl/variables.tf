variable "resource_name_prefix" {
  type = string

  description = <<DESC
リソース名に設定されるprefix。
命名ルールは locals.tf の命名セクションを参照。
DESC
}


variable "resource_name_suffix" {
  type    = string
  default = ""

  description = <<DESC
リソース名に設定されるsuffix。
命名ルールは locals.tf の命名セクションを参照。
DESC
}


variable "vpc_id" {
  type = string
}


variable "tags" {
  type    = map(string)
  default = {}
}


variable "acl_rules" {
  type = list(object({
    rule_action = string
    egress      = bool
    protocol    = optional(string, "-1")
    cidr_blocks = list(string)
    from_port   = optional(number, null)
    to_port     = optional(number, null)
  }))

  validation {
    # rule_action
    condition = alltrue(
      [for acl_rule in var.acl_rules : contains(["allow", "deny"], acl_rule["rule_action"])]
    )
    error_message = "The attribute of list `rule_action` must be \"allow\" or \"deny\"."
  }
  validation {
    # cidr_blocks
    condition = alltrue(flatten([
      for acl_rule in var.acl_rules : [
        for cidr_block in acl_rule["cidr_blocks"] :
        try(regex("[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+", cidr_block), null) != null
      ]
    ]))
    error_message = "The attribute of list `cidr_blocks` is illigal."
  }
}


variable "rule_number_reserved_block_size" {
  type    = number
  default = 100
}
