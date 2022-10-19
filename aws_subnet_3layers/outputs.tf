output "aws_subnets" {
  value = {
    webs      = [for k, v in aws_subnet.webs : v]
    apps      = [for k, v in aws_subnet.apps : v]
    databases = [for k, v in aws_subnet.databases : v]
  }
}
