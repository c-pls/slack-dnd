# IAM for lambda fucntion
resource "aws_iam_role" "lambda_role" {
  name = "lambda_functions_iam_role_for_slack_dnd"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_read_only" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}


# IAM for EventBridge Scheduler
resource "aws_iam_role" "eventbridge_execution_role" {
  name = "Amazon_EventBridge_Scheduler_LAMBDA_dawc"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "scheduler.amazonaws.com"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "StringEquals" : {
              "aws:SourceAccount" : "434545458459"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_policy" "eventbridge_scheduler_execution" {
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "lambda:InvokeFunction"
          ],
          "Resource" : [
            aws_lambda_function.lambda.arn
          ]

        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "exec_lambda_function" {
  role       = aws_iam_role.eventbridge_execution_role.name
  policy_arn = aws_iam_policy.eventbridge_scheduler_execution.arn
}
