# EC2 configuration for Pokemon Online Game AWS Infrastructure

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "server" {
  for_each      = { for idx, config in var.server_configs : idx => config }
  name_prefix   = "pokemon-game-${each.value.name}-"
  instance_type = each.value.instance_type
  image_id      = each.value.image_id == null ? data.aws_ami.amazon_linux_2.id : each.value.image_id

  vpc_security_group_ids = each.value.security_group_ids

  user_data = base64encode(each.value.user_data)

  tags = {
    Name = "pokemon-game-${each.value.name}-server"
  }
}

resource "aws_autoscaling_group" "server_asg" {
  for_each            = { for idx, config in var.server_configs : idx => config }
  name                = "pokemon-game-${each.value.name}-asg"
  desired_capacity    = each.value.desired_capacity
  max_size            = each.value.max_size
  min_size            = each.value.min_size
  target_group_arns   = each.value.target_group_arns
  vpc_zone_identifier = each.value.subnet_ids

  launch_template {
    id      = aws_launch_template.server[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "pokemon-game-${each.value.name}-asg"
    propagate_at_launch = true
  }
}

# resource "aws_launch_template" "web_server" {
#   name_prefix   = "pokemon-game-web-"
#   instance_type = "t3.micro"
#   image_id      = data.aws_ami.amazon_linux_2.id

#   vpc_security_group_ids = [var.web_security_group_id]

#   user_data = base64encode(<<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y httpd
#               systemctl start httpd
#               systemctl enable httpd
#               echo "<h1>Welcome to Pokemon Online Game</h1>" > /var/www/html/index.html
#               EOF
#   )

#   tags = {
#     Name = "pokemon-game-web-server"
#   }
# }

# resource "aws_autoscaling_group" "web_asg" {
#   desired_capacity    = 2
#   max_size            = 4
#   min_size            = 2
#   target_group_arns   = [var.target_group_arn]
#   vpc_zone_identifier = var.public_subnet_ids

#   launch_template {
#     id      = aws_launch_template.web_server.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "pokemon-game-web-asg"
#     propagate_at_launch = true
#   }
# }
