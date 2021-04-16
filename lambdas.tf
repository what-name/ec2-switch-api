## TO DO
# rename lambda_on and lambda_off to turn_on and turn_off. they're lambdas, duh

resource "null_resource" "lambda_on_buildstep" {
  triggers = {
    handler      = base64sha256(file("src/lambda_on/main.py"))
    requirements = base64sha256(file("src/lambda_on/requirements.txt"))
    build        = base64sha256(file("src/lambda_on/build.sh"))
  }

  provisioner "local-exec" {
    command = "${path.module}/src/lambda_on/build.sh"
  }
}

data "archive_file" "lambda_on" {
  source_dir  = "${path.module}/src/lambda_on/"
  output_path = "${path.module}/src/lambda_on.zip"
  type        = "zip"

  depends_on = [null_resource.lambda_on_buildstep]
}

resource "aws_lambda_function" "lambda_on" {
  function_name    = "${var.project-name}-on"
  handler          = var.lambda_handler
  role             = aws_iam_role.lambda.arn
  runtime          = var.lambda_python_runtime
  timeout          = var.lamdba_timeout
  filename         = data.archive_file.lambda_on.output_path
  source_code_hash = data.archive_file.lambda_on.output_base64sha256

  environment {
    variables = {
      INSTANCE_ID = var.instance_id
    }
  }
}

resource "null_resource" "lambda_off_buildstep" {
  triggers = {
    handler      = base64sha256(file("src/lambda_off/main.py"))
    requirements = base64sha256(file("src/lambda_off/requirements.txt"))
    build        = base64sha256(file("src/lambda_off/build.sh"))
  }

  provisioner "local-exec" {
    command = "${path.module}/src/lambda_off/build.sh"
  }
}

data "archive_file" "lambda_off" {
  source_dir  = "${path.module}/src/lambda_off/"
  output_path = "${path.module}/src/lambda_off.zip"
  type        = "zip"

  depends_on = [null_resource.lambda_off_buildstep]
}

resource "aws_lambda_function" "lambda_off" {
  function_name    = "${var.project-name}-off"
  handler          = var.lambda_handler
  role             = aws_iam_role.lambda.arn
  runtime          = var.lambda_python_runtime
  timeout          = var.lamdba_timeout
  filename         = data.archive_file.lambda_off.output_path
  source_code_hash = data.archive_file.lambda_off.output_base64sha256

  environment {
    variables = {
      INSTANCE_ID = var.instance_id
    }
  }
}

# Q: which policy way is better? POLICY vs. jsonencode()
resource "aws_iam_role" "lambda" {
   name = "${var.project-name}-lambda-role"

   assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaRole",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "ec2_allow" {
  name = "CloudGamerRigLambdaAutomation"
  role = aws_iam_role.lambda.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Effect   = "Allow"
        Resource = "*",
        "Condition": {
          "StringLike": {
            "ec2:ResourceTag/Name": "cg-*"
          }
        }
      },
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      }
    ]
  })
}