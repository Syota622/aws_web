### public&private subet group(1A) ###
resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.pj}-${var.env}-public-subnet-a"
  }
}
resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.pj}-${var.env}-private-subnet-1a"
  }
}
