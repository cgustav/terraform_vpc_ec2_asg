# EC2 configuration for Pokemon Online Game AWS Infrastructure
# Official Ubuntu AMI Locator:
# https://cloud-images.ubuntu.com/locator/ec2/

# Selected AMI: Ubuntu Server 24.04 LTS (HVM), SSD Volume Type:
# Selected AID: ami-04a81a99f5ec58529
# To get more information execute:
# aws ec2 describe-images --image-ids=ami-04a81a99f5ec58529
# 
data "aws_ami" "ubuntu_noble_server" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-04a81a99f5ec58529"]
  }
}


# Crear la política de permisos
resource "aws_iam_policy" "ec2_ssm_policy" {
  name        = "ec2_ssm_policy"
  description = "A policy that allows EC2 instances to access SSM parameters"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Crear el rol IAM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Adjuntar la política al rol
resource "aws_iam_role_policy_attachment" "ec2_ssm_role_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ec2_ssm_policy.arn
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_launch_template" "server" {
  for_each      = { for idx, config in var.server_configs : idx => config }
  name_prefix   = "meme-gallery-${each.value.name}-"
  instance_type = each.value.instance_type
  image_id      = each.value.image_id == null ? data.aws_ami.ubuntu_noble_server.id : each.value.image_id

  vpc_security_group_ids = each.value.security_group_ids

  user_data = base64encode(each.value.user_data)

  tags = {
    Name = "meme-gallery-${each.value.name}-server"
  }


  # Agregar el IAM Instance Profile aquí
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
}

resource "aws_autoscaling_group" "server_asg" {
  for_each            = { for idx, config in var.server_configs : idx => config }
  name                = "meme-gallery-${each.value.name}-asg"
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
    value               = "meme-gallery-${each.value.name}-asg"
    propagate_at_launch = true
  }
}

# resource "aws_eip" "lb" {
#   instance = aws_launch_template.web.id
#   domain   = "vpc"
# }
