resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true


  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = element(coalesce(var.azs, data.aws_availability_zones.this.names), count.index)
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(coalesce(var.azs, data.aws_availability_zones.this.names), count.index)
  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "isolated_subnets" {
  count             = length(var.isolated_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = element(coalesce(var.azs, data.aws_availability_zones.this.names), count.index)

  tags = {
    Name = "${var.vpc_name}-isolated-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "this" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}
