terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "webapp-vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "subnet-1a" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.1.0/24"
  tags = {
    Name = "Subnet-1a-webapp"
  }
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
}

resource "aws_subnet" "subnet-1b" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.2.0/24"
  tags = {
    Name = "Subnet-1b-webapp"
  }
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"
}

resource "aws_subnet" "subnet-1c" {
  vpc_id     = aws_vpc.webapp-vpc.id
  cidr_block = "10.10.3.0/24"
  tags = {
    Name = "Subnet-1c-webapp"
  }
  availability_zone = "ap-south-1c"
}

resource "aws_instance" "webapp-1a" {
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  tags = {
    Name ="webapp-1a"
  }
  subnet_id = aws_subnet.subnet-1a.id
  vpc_security_group_ids = [aws_security_group.allow_port80.id]
  key_name = "key-for-tera"
}

resource "aws_instance" "webapp-1b" {
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  tags = {
    Name ="webapp-1b"
  }
  subnet_id = aws_subnet.subnet-1b.id
  vpc_security_group_ids = [aws_security_group.allow_port80.id]
  key_name = "key-for-tera"
}

resource "aws_security_group" "allow_port80" {
  name = "allow_port_80"
  description = "Allow web inbound traffic"
  vpc_id = aws_vpc.webapp-vpc.id

  ingress {
    description = "allow inbound web traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =["::/0"]
  }

  ingress {
    description = "allow ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =["::/0"]
  }
  
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_internet_gateway" "webapp-IG" {
  vpc_id = aws_vpc.webapp-vpc.id

  tags = {
    Name = "webapp-IG"
  }
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.webapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-IG.id
  }


  tags = {
    Name = "Public_RT"
  }
}

resource "aws_route_table_association" "RT-asso-1a" {
  subnet_id = aws_subnet.subnet-1a.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "RT-asso-1b" {
  subnet_id = aws_subnet.subnet-1b.id
  route_table_id = aws_route_table.Public_RT.id
}
