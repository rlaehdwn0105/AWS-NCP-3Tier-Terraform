#############################
# 1. vpc 생성 
#############################

# vpc 생성 
resource "aws_vpc" "dj-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support = true
  enable_dns_hostnames = true 
  
  tags = {
    Name = "dj-vpc"
  }
}
##############################
# 1. IGW(인터넷 게이트웨이) 생성 
# 2. NAT 게이트 웨이 생성&
# 3. 탄력적 IP 
##############################

# IGW(인터넷 게이트웨이) 생성 
resource "aws_internet_gateway" "dj-internetgw" {
  vpc_id = aws_vpc.dj-vpc.id

  tags = {
    Name = "dj-internetgw"
  }
}
# EIP 주소 할당 
resource "aws_eip" "dj-eip" {
  vpc = true
  
  lifecycle {
  create_before_destroy = true
  }
  tags = {
  Name = "dj-eip"
  }
}
resource "aws_nat_gateway" "dj-natgw" {
  allocation_id = aws_eip.dj-eip.id
  subnet_id = aws_subnet.dj-pub1.id
  tags = {
  Name = "dj-natgw"
  }
  depends_on = [aws_internet_gateway.dj-internetgw]
}
#####################################################
# 1. public-subnet x 2 / routing table 생성 & 연결 
# 2. private-subnet x 4 / routing table 생성 & 연결 
#####################################################

# Subnet(public) x2 생성 
resource "aws_subnet" "dj-pub1" {
  vpc_id     = aws_vpc.dj-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "dj-pub1"
  }
}
resource "aws_subnet" "dj-pub2" {
  vpc_id     = aws_vpc.dj-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true 

  tags = {
    Name = "dj-pub2"
  }
}
### Public-Route 생성-연결 ###
resource "aws_route_table" "dj-pub-rt" {
  vpc_id = aws_vpc.dj-vpc.id

  tags = {
    Name = "dj-pub-rt"
  }
}
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.dj-pub-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dj-internetgw.id
}
resource "aws_route_table_association" "dj-pub-rt-ass1" {
  subnet_id      = aws_subnet.dj-pub1.id
  route_table_id = aws_route_table.dj-pub-rt.id
}
resource "aws_route_table_association" "dj-pub-rt-ass2" {
  subnet_id      = aws_subnet.dj-pub2.id
  route_table_id = aws_route_table.dj-pub-rt.id
}
# Subnet(private) x4 생성 
resource "aws_subnet" "dj-pri1" {
  vpc_id     = aws_vpc.dj-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"


  tags = {
    Name = "dj-pri1"
  }
}
resource "aws_subnet" "dj-pri2" {
  vpc_id     = aws_vpc.dj-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"


  tags = {
    Name = "dj-pri2"
  }
}
resource "aws_subnet" "dj-pri3" {
  vpc_id     = aws_vpc.dj-vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2a"


  tags = {
    Name = "dj-pri3"
  }
}
resource "aws_subnet" "dj-pri4" {
  vpc_id     = aws_vpc.dj-vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-northeast-2c"


  tags = {
    Name = "dj-pri4"
  }
}
### Private-Route 생성-연결 ###
resource "aws_route_table" "dj-pri-rt" {
  vpc_id = aws_vpc.dj-vpc.id

  tags = {
    Name = "dj-pri-rt"
  }
}
resource "aws_route" "private_route" {
  route_table_id = aws_route_table.dj-pri-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.dj-natgw.id
}
resource "aws_route_table_association" "dj-pri-rt-ass1" {
  subnet_id      = aws_subnet.dj-pri1.id
  route_table_id = aws_route_table.dj-pri-rt.id
}
resource "aws_route_table_association" "dj-pri-rt-ass2" {
  subnet_id      = aws_subnet.dj-pri2.id
  route_table_id = aws_route_table.dj-pri-rt.id
}

