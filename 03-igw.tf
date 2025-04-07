# Create a internet gateway for internet connectivity and 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.basename}-igw-main"
  }
}