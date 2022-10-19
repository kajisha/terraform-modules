resource "aws_network_acl" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = local.resource_name_prefix
    }
  )
}


locals {
  # preparing local.acl_rules: group by egress
  _acl_rules = {
    for egress in [true, false] :
    egress => [
      for acl_rule in var.acl_rules :
      acl_rule if acl_rule["egress"] == egress
    ]
  }


  # join cidrs / set rule_number
  acl_rules = {
    for egress, acl_rules in local._acl_rules :
    egress => [
      for acl_rule in acl_rules : [
        for cidr_block in acl_rule["cidr_blocks"] :
        merge(
          acl_rule,
          {
            cidr_block = cidr_block
            rule_number = (
              1 # ルール番号は1から始まる
              + sum(concat(
                [0], # 空配列防止
                [
                  for _acl_rule in slice(acl_rules, 0, index(acl_rules, acl_rule)) :
                  ceil((1 + length(_acl_rule["cidr_blocks"])) / var.rule_number_reserved_block_size)
                  * var.rule_number_reserved_block_size
                ]
              )) # ルールごとに予約領域を確保する
              + index(acl_rule["cidr_blocks"], cidr_block)
            )
          }
        )
      ]
    ]
  }
}


resource "aws_network_acl_rule" "these" {
  for_each = { for v in flatten([for _k, _v in local.acl_rules : _v]) :
    join(
      "_",
      [
        v["egress"] ? "egress" : "ingress",
        v["rule_number"],
      ]
    ) => v
  }

  network_acl_id = aws_network_acl.this.id
  egress         = each.value["egress"]
  rule_action    = each.value["rule_action"]
  protocol       = each.value["protocol"]
  cidr_block     = each.value["cidr_block"]
  rule_number    = each.value["rule_number"]
  from_port      = each.value["from_port"]
  to_port        = each.value["to_port"]
}
