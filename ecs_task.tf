# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"


resource "aws_launch_configuration" "lunch_config" {
  name          = "lunch_config"
  image_id      = "ami-0a74b180a0c97ecd1"
  instance_type = "t3.large"
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id
  user_data = filebase64("./userdata.sh")
  key_name = aws_key_pair.keyPairForEc2.key_name

  security_groups = [aws_security_group.allow_ssh.id]
}

resource "aws_autoscaling_group" "autoscaling_group" {
  availability_zones = ["eu-west-1c"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  protect_from_scale_in = "true"

  launch_configuration = aws_launch_configuration.lunch_config.name
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "my_capacity_provider6"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}


resource "aws_ecs_task_definition" "service" {
  family                = "service"
  container_definitions = file("./service.json")
}

resource "aws_ecs_cluster" "myCluster" {
  name = "myCluster"
  capacity_providers =[aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
  }
}

resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = aws_ecs_cluster.myCluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
    weight = 1
  }
 #iam_role        = aws_iam_role.foo.arn
 #depends_on      = ["aws_iam_role_policy.foo"]

  #ordered_placement_strategy {
  #  type  = "binpack"
  #  field = "cpu"
  #}

  #load_balancer {
  #  target_group_arn = aws_lb_target_group.foo.arn
  #  container_name   = "mongo"
  #  container_port   = 8080
  #}

  #placement_constraints {
  #  type       = "memberOf"
  #  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #}
}