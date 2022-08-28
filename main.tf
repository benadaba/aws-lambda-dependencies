# Preparing the folder full of dependencies and your script
resource null_resource packaging {
  # trigers only if your script or list of dependencies were changed,,
  triggers = {
    dependencies = join(" ", var.pip_dependencies)
    #script_sha1  = sha1(file(var.script_path))
    script_sha1  = sha1(file(var.script_path))
  }

  # clean the folder
  provisioner local-exec {
    command = "rm -rf /tmp/${var.temp_package_folder}"
  }

  # recreate the folder
  provisioner local-exec {
    command = "mkdir /tmp/${var.temp_package_folder}"
  }

  # install dependencies to the folder
  provisioner local-exec {
    command = "pip3 install ${join(" ", var.pip_dependencies)} --target /tmp/${var.temp_package_folder}"
  }

  # copy your script to the folder
  provisioner local-exec {
    command = "cp ${var.script_path} /tmp/${var.temp_package_folder}/"
  }
}

# this resource we need to turn explicit dependencies (which Terraform couldn't check) to
# implicit dependencies (which Terraform can control and check difference)
# for more information, take a look: https://github.com/hashicorp/terraform-provider-archive/issues/11
data null_data_source packaging_changes {
  inputs = {
    null_id      = null_resource.packaging.id
    package_path = var.package_filename
  }
}

# zipping all the folder!
data archive_file package {
  type        = "zip"
  source_dir  = "/tmp/${var.temp_package_folder}"
  output_path = data.null_data_source.packaging_changes.outputs["package_path"]
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid = "AllowInvokingLambdas"
    effect = "Allow"

    resources = [
      "arn:aws:lambda:*:*:function:*"
    ]

    actions = [
      "lambda:InvokeFunction"
    ]
  }

  statement {
    sid = "AllowCreatingLogGroups"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*"
    ]

    actions = [
      "logs:CreateLogGroup"
    ]
  }

  statement {
    sid = "AllowWritingLogs"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "lambda_iam_policy"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
  role = aws_iam_role.lambda_exec_role.name
}