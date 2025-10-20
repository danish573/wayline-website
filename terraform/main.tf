<<<<<<< HEAD
####### Setup Terraform and AWS Regin #######

=======
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
terraform {
  required_version = ">= 1.5.0"

  required_providers {
<<<<<<< HEAD
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
=======
    aws={
        source = "hashicorp/aws"
        version = "~>5.0"
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
    }
  }
}

provider "aws" {
  region = var.aws_region
}

<<<<<<< HEAD
####### Get Default VPC #######

data "aws_vpc" "default" {
  default = true
}


### S3 Bucket Setup for Security an Privacy data protecction #####

resource "aws_s3_bucket" "static_website" {
  bucket        = var.s3_bucket_name
  force_destroy = true

}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.static_website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}


###### Security Group for EC-2 (jenkis Server) #####
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and Jenkins"
  vpc_id      = data.aws_vpc.default.id
  ingress = [
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Jenkins"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

##### Jenkins Instance #####
resource "aws_instance" "static_webapp" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    name = "Jenkins_server"
  }

}
=======
resource "aws_security_group" "wayline_sg" {
  name        = "wayline-sg"
  description = "Allow inbound and outbound traffic for Wayline DevOps setup"

  # SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Allow Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API (k3s / kube-apiserver)
  ingress {
    description = "Allow Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort range for Kubernetes services
  ingress {
    description = "Allow NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wayline-sg"
  }
}


resource "aws_instance" "wayline_server" {
  ami = var.ami
  instance_type = var.instance_type
  key_name= var.key_pair
  vpc_security_group_ids = [aws_security_group.wayline_sg.id] 
  user_data = file("${path.module}/userdata.sh")

  tags = {
    name= "wayline_server"
  }
}
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
