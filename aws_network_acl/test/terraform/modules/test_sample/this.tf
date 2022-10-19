module "this" {
  source = "../../../../"

  resource_name_prefix = local.resource_name_prefix

  vpc_id    = aws_vpc.this.id
  acl_rules = local.acl_rules
}


locals {
  acl_rules = [
    {
      rule_action = "allow"
      egress      = true
      cidr_blocks = ["10.1.0.0/32", "10.1.0.1/32"]
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    },
    {
      rule_action = "deny"
      egress      = true
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      rule_action = "allow"
      egress      = false
      cidr_blocks = ["10.1.0.0/32", "10.1.0.1/32"]
    },
    {
      rule_action = "deny"
      egress      = false
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}
