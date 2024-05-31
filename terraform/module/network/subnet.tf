### public&private subet group(1A) ###
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.pj}-${var.env}-public-subnet-a"
  }
}
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.pj}-${var.env}-private-subnet-1a"
  }
}

### public&private subet group(1C) ###
resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.pj}-${var.env}-public-subnet-c"
  }
}
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.pj}-${var.env}-private-subnet-1c"
  }
}

### public&private subet group(1D) ###
resource "aws_subnet" "public_d" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.pj}-${var.env}-public-subnet-d"
  }
}
resource "aws_subnet" "private_d" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.pj}-${var.env}-private-subnet-1d"
  }
}
