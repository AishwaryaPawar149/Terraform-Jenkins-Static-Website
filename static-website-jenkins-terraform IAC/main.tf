provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id = "subnet-0b7ffdec16dd0024c"  # ap-south-1a   
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 git -y
    systemctl enable apache2
    systemctl start apache2
  EOF

  tags = {
    Name = "TerraformWebServer"
  }
}
