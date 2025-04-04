resource "aws_launch_template" "webserver" {
  name_prefix   = "${var.basename}-lt-"
  image_id      = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type_value
  key_name      = "lol"  # Change this to the correct key pair

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.sg_private.id]
    associate_carrier_ip_address = false
    delete_on_termination = true
  }
 depends_on = [ aws_instance.webserver ]
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id =  aws_kms_key.kms_ebs.arn
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.basename}-webserver"
    }
  }

  user_data = base64encode(templatefile("./scripts/run-httpd.sh.tpl", {
    secretname = aws_secretsmanager_secret.database_credentials.name
  })) 
}