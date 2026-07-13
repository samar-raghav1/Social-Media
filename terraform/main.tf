provider "aws" {
    region = "us-east-1"
}
data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_key_pair" "social-key" {
    key_name   = "social-key"
    public_key = file("socialmediakey.pub")
}

resource "aws_vpc" "social-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}


resource "aws_subnet" "social-subnet" {
    vpc_id = aws_vpc.social-vpc.id
    availability_zone = data.aws_availability_zones.available.names[0]
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

}

resource "aws_security_group" "social-sg" {
    name        = "social-sg"
    description = "Allow HTTP and HTTPS traffic"
    vpc_id      = aws_vpc.social-vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 4000
        to_port     = 4000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "social-instance" {
    ami           = "ami-0b6d9d3d33ba97d99" # ubuntu 22.04
    instance_type = "t3.small"
    subnet_id     = aws_subnet.social-subnet.id
    key_name      = aws_key_pair.social-key.key_name
    associate_public_ip_address = true 
    vpc_security_group_ids = [aws_security_group.social-sg.id]
    availability_zone = data.aws_availability_zones.available.names[0]
    root_block_device {
        volume_size = 35
        volume_type = "gp2"
    }

    tags = {
        Name = "social-instance"
    }
}
resource "aws_instance" "social-kube" {
    ami           = "ami-0b6d9d3d33ba97d99" # ubuntu 22.04
    instance_type = "t3.small"
    subnet_id     = aws_subnet.social-subnet.id
    key_name      = aws_key_pair.social-key.key_name
    associate_public_ip_address = true 
    vpc_security_group_ids = [aws_security_group.social-sg.id]
    availability_zone = data.aws_availability_zones.available.names[0]
    root_block_device {
        volume_size = 35
        volume_type = "gp2"
    }

    tags = {
        Name = "social-kube"
    }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "social-eks-cluster"
  cluster_version = "1.29"
  subnet_ids      = aws_subnet.social-subnet[*].id
  vpc_id          = aws_vpc.social-vpc.id

  # IAM roles for cluster
  cluster_endpoint_public_access = true

  # Node group
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }
}
