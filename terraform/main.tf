provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "social-key" {
    key_name   = "social-key"
    public_key = file("socialmediakey.pub")
}

resource "aws_vpc" "social-vpc" {
    cidr_block = "10.0.0.0/16"
  
}

resource "aws_subnet" "social-subnet" {
    vpc_id = aws_vpc.social-vpc.id
    cidr_block = "10.0.1.0/24"

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

resource "aws_instance" "socialMediaInstance" {
    ami           = "ami-0b6d9d3d33ba97d99" # ubuntu 22.04
    instance_type = "t3.small"
    subnet_id     = aws_subnet.social-subnet.id
    key_name      = aws_key_pair.social-key.key_name
    vpc_security_group_ids = [aws_security_group.social-sg.id]
    root_block_device {
        volume_size = 35
        volume_type = "gp2"
    }

    tags = {
        Name = "SocialMediaInstance"
    }
}


output "instance_public_ip" {
    value = aws_instance.socialMediaInstance.public_ip
}
output "instance_public_dns" {
    value = aws_instance.socialMediaInstance.public_dns
}
