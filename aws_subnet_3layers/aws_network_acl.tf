# web
module "aws_network_acls_web" {
  source = "../aws_network_acl"

  resource_name_prefix = local.resource_name_prefix
  resource_name_suffix = "web"

  vpc_id = var.vpc_id
  acl_rules = [
    for acl_rule in local.acl_rules :
    acl_rule if acl_rule["network_acl_name"] == "web"
  ]
}


resource "aws_network_acl_association" "webs" {
  for_each = aws_subnet.webs

  network_acl_id = module.aws_network_acls_web.aws_network_acl.id
  subnet_id      = each.value.id
}


# app
module "aws_network_acls_app" {
  source = "../aws_network_acl"

  resource_name_prefix = local.resource_name_prefix
  resource_name_suffix = "app"

  vpc_id = var.vpc_id
  acl_rules = [
    for acl_rule in local.acl_rules :
    acl_rule if acl_rule["network_acl_name"] == "app"
  ]
}


resource "aws_network_acl_association" "apps" {
  for_each = aws_subnet.apps

  network_acl_id = module.aws_network_acls_app.aws_network_acl.id
  subnet_id      = each.value.id
}


# database
module "aws_network_acls_database" {
  source = "../aws_network_acl"

  resource_name_prefix = local.resource_name_prefix
  resource_name_suffix = "database"

  vpc_id = var.vpc_id
  acl_rules = [
    for acl_rule in local.acl_rules :
    acl_rule if acl_rule["network_acl_name"] == "database"
  ]
}


resource "aws_network_acl_association" "databases" {
  for_each = aws_subnet.databases

  network_acl_id = module.aws_network_acls_database.aws_network_acl.id
  subnet_id      = each.value.id
}


locals {
  # defaultのルール
  default_acl_rules = [
    #==================
    # allow web to web / web from web
    {
      network_acl_name = "web"
      rule_action      = "allow"
      egress           = true
      cidr_blocks      = [for s in aws_subnet.webs : s.cidr_block]
    },
    {
      network_acl_name = "web"
      rule_action      = "allow"
      egress           = false
      cidr_blocks      = [for s in aws_subnet.webs : s.cidr_block]
    },
    #==================
    # allow app to vpc
    {
      network_acl_name = "app"
      rule_action      = "allow"
      egress           = true
      cidr_blocks      = [var.available_cidr_block]
    },
    #==================
    # allow app from app
    {
      network_acl_name = "app"
      rule_action      = "allow"
      egress           = false
      cidr_blocks      = [for s in aws_subnet.apps : s.cidr_block]
    },
    #==================
    # allow database to database / database from database
    {
      network_acl_name = "database"
      rule_action      = "allow"
      egress           = true
      cidr_blocks      = [for s in aws_subnet.databases : s.cidr_block]
    },
    {
      network_acl_name = "database"
      rule_action      = "allow"
      egress           = false
      cidr_blocks      = [for s in aws_subnet.databases : s.cidr_block]
    },
    #==================
    # allow web to app / app from web
    {
      network_acl_name = "web"
      rule_action      = "allow"
      egress           = true
      cidr_blocks      = [for s in aws_subnet.apps : s.cidr_block]
    },
    {
      network_acl_name = "app"
      rule_action      = "allow"
      egress           = false
      cidr_blocks      = [for s in aws_subnet.webs : s.cidr_block]
    },
    #==================
    # allow web from app
    {
      network_acl_name = "web"
      rule_action      = "allow"
      egress           = false
      cidr_blocks      = [for s in aws_subnet.apps : s.cidr_block]
    },
    #==================
    # allow database from app
    {
      network_acl_name = "database"
      rule_action      = "allow"
      egress           = false
      cidr_blocks      = [for s in aws_subnet.apps : s.cidr_block]
    },
    #==================
    # deny database from all
    {
      network_acl_name = "database"
      rule_action      = "deny"
      egress           = false
      cidr_blocks      = ["0.0.0.0/0"]
    },
  ]


  acl_rules = concat(
    local.default_acl_rules,
    var.acl_rules,
  )
}
