resource "aws_network_interface" "sources" {
  for_each = toset(["webs", "apps", "databases"])

  subnet_id       = module.this.aws_subnets[each.value]["0"].id
  security_groups = [aws_security_group.allow_all.id]
}


resource "aws_network_interface" "destinations" {
  for_each = toset(["webs", "apps", "databases"])

  subnet_id       = module.this.aws_subnets[each.value]["0"].id
  security_groups = [aws_security_group.allow_all.id]
}


resource "aws_security_group" "allow_all" {
  name = local.resource_name_prefix

  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.resource_name_prefix
  }
}


resource "aws_ec2_network_insights_path" "these" {
  for_each = merge(flatten([
    for source in ["webs", "apps", "databases"] : [
      for destination in ["webs", "apps", "databases"] : {
        "${source}_${destination}" = {
          source      = source
          destination = destination
        }
      }
    ]
  ])...)

  source      = aws_network_interface.sources[each.value["source"]].id
  destination = aws_network_interface.destinations[each.value["destination"]].id
  protocol    = "tcp"
  tags = {
    Name = "${local.resource_name_prefix}-${each.value["source"]}-${each.value["destination"]}"
  }
}


resource "aws_ec2_network_insights_analysis" "these" {
  for_each                 = aws_ec2_network_insights_path.these
  network_insights_path_id = each.value.id
}
