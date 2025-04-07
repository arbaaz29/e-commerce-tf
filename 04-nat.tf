# elastic ip's for NAT gateways
resource "aws_eip" "nat" {
  for_each = var.public_subnet_cidrs
  domain   = "vpc"

  tags = {
    Name = "${var.basename}-eip-${each.key}"
  }
}

#NAT gateway for private instances
resource "aws_nat_gateway" "ngw" {
  for_each      = var.public_subnet_cidrs
  subnet_id     = aws_subnet.public-subnet[each.key].id
  allocation_id = aws_eip.nat[each.key].id

  tags = {
    Name = "${var.basename}-ngw-${each.key}"
  }
}

