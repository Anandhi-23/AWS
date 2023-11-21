#creating vpc
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

#creating two subnets in different availability zones
resource "aws_subnet" "mysubnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "mysubnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
}

#creating interget gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}

#creating route table
resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

#route table association with subnets
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myrt.id
}

#creating security group to allow http traffic
resource "aws_security_group" "allow_http_ssh" {
  name   = "web-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Traffic"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_http_ssh"
  }
}

#creating two EC2 instances with apache2 webserver installed
resource "aws_instance" "myinstance1" {
  ami                    = "ami-0e83be366243f524a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  subnet_id              = aws_subnet.mysubnet1.id
  key_name               = "terraform_key"
  user_data              = base64encode(file("userdata_1.sh"))

  tags = {
    Name = "MyFirstInstance"
  }
}

resource "aws_instance" "myinstance2" {
  ami                    = "ami-0e83be366243f524a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  subnet_id              = aws_subnet.mysubnet2.id
  key_name               = "terraform_key"
  user_data              = base64encode(file("userdata_2.sh"))

  tags = {
    Name = "MySecondInstance"
  }
}

#creating application load balancer
resource "aws_lb" "my_lb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]

  tags = {
    Name = "my_lb"
  }
}

#creating target groups
resource "aws_lb_target_group" "my_tg" {
  name     = "mytg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#adding instances to target group
resource "aws_lb_target_group_attachment" "target_attach_1" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.myinstance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target_attach_2" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.myinstance2.id
  port             = 80
}

#attaching target group to the load balancer
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_tg.arn
    type             = "forward"
  }
}

#getting load balancer DNS name to access the webpage
output "lb_dns" {
  value = aws_lb.my_lb.dns_name

}