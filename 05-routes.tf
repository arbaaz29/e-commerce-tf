// public routes and route table for public subnet
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.basename}-rt-public"
  }
}
resource "aws_route_table_association" "public" {
  for_each       = var.public_subnet_cidrs
  subnet_id      = aws_subnet.public-subnet[each.key].id
  route_table_id = aws_route_table.rt-public.id
}

//private routes and route table for private subnet of RDS
resource "aws_route_table" "rt-private-rds" {
  vpc_id = aws_vpc.main.id
  for_each = var.public_subnet_cidrs
  tags = {
    Name = "${var.basename}-rt-private-rds-${each.value["idx"]}"
  }
}
resource "aws_route_table_association" "private-rds" {
  for_each       = var.private_subnet_cidrs_rds
  subnet_id      = aws_subnet.private-subnet-rds[each.key].id
  route_table_id = aws_route_table.rt-private-rds["subnet-az${each.value["idx"]}"].id
}

// private route and route table for webserver (private subnet)
resource "aws_route_table" "rt-private" {
  vpc_id   = aws_vpc.main.id
  for_each = var.public_subnet_cidrs
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[each.key].id
  }
  tags = {
    Name = "${var.basename}-rt-private-${each.value["idx"]}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.public_subnet_cidrs
  subnet_id      = aws_subnet.private-subnet[each.key].id
  route_table_id = aws_route_table.rt-private["subnet-az${each.value["idx"]}"].id // route table for each az
}