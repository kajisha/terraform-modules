resource "aws_vpc" "this" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = local.resource_name_prefix
  }
}

