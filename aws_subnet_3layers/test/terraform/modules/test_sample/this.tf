module "this" {
  source = "../../../../"

  resource_name_prefix = var.resource_name_prefix

  vpc_id            = aws_vpc.this.id
  availability_zone = "ap-northeast-1a"

  available_cidr_block = "10.0.0.0/16"

  subnets_structure = [
    {
      layer       = "web"
      subnet_mask = 24
    },
    {
      layer       = "app"
      subnet_mask = 24
    },
    {
      layer       = "database"
      subnet_mask = 24
    },
  ]
}

