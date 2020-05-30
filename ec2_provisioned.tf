
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "keyPairForEc2" {
  key_name  = "keyPairForEc2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0buJYcM4mz8PLHW6B+AJUob+RWAI+slQBlyIGflyq2YYKw1dMNctYD2M2r3NlysP75mudP7qXjdVBPwhcpXQPI07MTBH1lf2sV9bixM/9lrYr1zE0n2D9sy326cQAjfuZGXE/avbJIAlxbG012rct3QPbI2i7yHVec3lX/r2aK1Is50n4vSnbAe/DMyP0XUYZ49Pp0NB9nsTPNmX9MIY5sW5usASFGPHqyHCRKKFAdly2Wyy+KxWS+JG7ptTuKXTMjeS+4iEJs7t/AUdXlg2MZ7CeAGI32DrO8L2Zk20Y2zN3CGSx2rbGg4W3BbW3qlaapVWx+D+kXGbF38elMIsszj94kZFf8o+7ZUicKeQSJC/Z8iiqEnaMYqNEebKFWHfCtYoQYV6muR432uvsg+dAgz0QRCaF9voeeir01ISAwccIXQLwP5iYGbWkccMc+JZIvk/7Tpf9aqSWw7YWy2YKl0UPik3Bs/HYESwiVSvHPq0uDT748TmJzmEoBPKPk0= larswillrich@gmail.com"
} 

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  key_name = aws_key_pair.keyPairForEc2.key_name

  tags = {
    Name = "provisioned with terraform"
  }
}
