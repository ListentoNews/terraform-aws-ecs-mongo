output "revision" {
  value = aws_ecs_task_definition.this.revision
}

output "execution_role_name" {
  value = aws_iam_role.this.name
}

output "task_role_name" {
  value = aws_iam_role.task_role.name
}

output "security_group_id" {
  value = aws_security_group.this.id
}
