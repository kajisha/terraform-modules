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


variable "availability_zone" {
  type = string
}


variable "available_cidr_block" {
  type = string
}


variable "subnets_structure" {
  type = list(object({
    layer       = string
    subnet_mask = number
  }))

  validation {
    # rule_action
    condition = alltrue(
      [for subnet in var.subnets_structure : contains(["web", "app", "database"], subnet["layer"])]
    )
    error_message = "The attribute of list `subnets_structure` must be \"web\", \"app\" or \"database\"."
  }
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
  default = []

  description = <<DESC
defaultのルールに追加されるルール。
DESC
}
