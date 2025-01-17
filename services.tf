data "aws_region" "this" {}

data "template_file" "container_definitions" {
  template = file("${path.module}/container-definitions.tmpl")
  vars = {
    name               = var.name
    image              = var.image
    cpu                = var.cpu
    memory             = var.memory
    volume_name        = var.name
    volume_path        = "/data/db"
    environment        = jsonencode(var.environment)
    cloudwatch         = var.cloudwatch
    logs_group         = var.name
    logs_stream_prefix = var.name
    logs_region        = data.aws_region.this.name
  }
}

resource "aws_ecs_task_definition" "this" {
  family                = var.name
  container_definitions = data.template_file.container_definitions.rendered
  execution_role_arn    = aws_iam_role.this.arn
  task_role_arn         = aws_iam_role.task_role.arn

  cpu    = var.cpu
  memory = var.memory

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  dynamic "volume" {
    for_each = var.volume_type == "efs" ? [1] : []
    content {
      name = var.name
      efs_volume_configuration {
        file_system_id = aws_efs_file_system.this[0].id
      }
    }
  }

  dynamic "volume" {
    for_each = var.volume_type == "ebs" ? [1] : []
    content {
      name = var.name
    }
  }
}

resource "aws_ecs_service" "this" {
  name             = var.name
  cluster          = var.cluster
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = 1

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.this.id]
    subnets          = var.subnets
  }

  dynamic "load_balancer" {
    for_each = var.create_lb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.name
      container_port   = 27017
    }
  }

  dynamic "service_registries" {
    for_each = var.registry_arn == "" ? [] : [1]
    content {
      registry_arn = var.registry_arn
    }
  }
}
