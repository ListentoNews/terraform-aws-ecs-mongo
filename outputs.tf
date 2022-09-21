output "revision" {
  value = aws_ecs_task_definition.this.revision
}

output "execution_role_arn" {
  value = aws_iam_role.this.arn
}

output "task_role" {
  value = {
    arn = aws_iam_role.task_role.arn
    name = aws_iam_role.task_role.name
  }
}
