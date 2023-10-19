resource "null_resource" "pip_install" {
  triggers = {
    shell_hash = "${sha256(file("${path.module}/src/requirements.txt"))}"
  }

  provisioner "local-exec" {
    command = "python3 -m pip install -r src/requirements.txt -t ${path.module}/layer/python"
  }

}

data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/layer.zip"
  depends_on  = [null_resource.pip_install]
}

resource "aws_lambda_layer_version" "layer" {
  layer_name          = "lambda-layer"
  filename            = data.archive_file.layer.output_path
  source_code_hash    = data.archive_file.layer.output_base64sha256
  compatible_runtimes = ["python3.10", "python3.9", "python3.8"]
}

data "archive_file" "code" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src_code.zip"
}


resource "aws_lambda_function" "lambda" {
  function_name    = "slack-dnd-lambda-function"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  layers           = [aws_lambda_layer_version.layer.arn]
  environment {
    variables = {
      "SLACK_TOKEN_NAME" = "slack_user_token"
    }
  }
}
