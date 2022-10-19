locals {
  # 3layer
  layers = ["web", "app", "database"]

  # cidr_blocksの生成
  _available_subnet_mask = tonumber(regex("[\\d.]+/(\\d+)", var.available_cidr_block)[0])
  _cidr_blocks = cidrsubnets(
    var.available_cidr_block,
    [
      for s in var.subnets_structure :
      s.subnet_mask - local._available_subnet_mask
    ]...
  )

  # subnets_structure と _cidr_blocks とのjoin
  __subnets = [
    for k, v in zipmap(local._cidr_blocks, var.subnets_structure) :
    {
      layer       = v["layer"]
      subnet_mask = v["subnet_mask"]
      cidr_block  = k
    }
  ]

  # 順序を維持しながら、layerでgroup by
  subnets = {
    for layer in local.layers :
    layer => [for v in local.__subnets : v if v["layer"] == layer]
  }
}


resource "aws_subnet" "webs" {
  for_each = {
    for v in local.subnets["web"] :
    index(local.subnets["web"], v) => v
  }

  vpc_id            = var.vpc_id
  cidr_block        = each.value["cidr_block"]
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true

  tags = {
    Name  = "${local.resource_name_prefix}-${each.value["layer"]}-${var.availability_zone}-${each.key}"
    layer = each.value["layer"]
    az    = var.availability_zone
    index = each.key
  }
}


resource "aws_subnet" "apps" {
  for_each = {
    for v in local.subnets["app"] :
    index(local.subnets["app"], v) => v
  }

  vpc_id            = var.vpc_id
  cidr_block        = each.value["cidr_block"]
  availability_zone = var.availability_zone

  map_public_ip_on_launch = false

  tags = {
    Name  = "${local.resource_name_prefix}-${each.value["layer"]}-${var.availability_zone}-${each.key}"
    layer = each.value["layer"]
    az    = var.availability_zone
    index = each.key
  }
}


resource "aws_subnet" "databases" {
  for_each = {
    for v in local.subnets["database"] :
    index(local.subnets["database"], v) => v
  }

  vpc_id            = var.vpc_id
  cidr_block        = each.value["cidr_block"]
  availability_zone = var.availability_zone

  map_public_ip_on_launch = false

  tags = {
    Name  = "${local.resource_name_prefix}-${each.value["layer"]}-${var.availability_zone}-${each.key}"
    layer = each.value["layer"]
    az    = var.availability_zone
    index = each.key
  }
}
