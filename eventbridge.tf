resource "aws_scheduler_schedule" "scheduler" {
  name        = "slack-dnd-scheduler"
  group_name  = "default"
  description = "Managed by Terraform"

  flexible_time_window {
    mode = "OFF"
  }


  schedule_expression_timezone = "Asia/Saigon"
  schedule_expression          = "cron(45 11 ? * MON-FRI *)"


  target {
    arn      = aws_lambda_function.lambda.arn
    role_arn = aws_iam_role.eventbridge_execution_role.arn
    retry_policy {
      maximum_retry_attempts = 5
    }
  }



}
