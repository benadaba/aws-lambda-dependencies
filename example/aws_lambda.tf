module lambda_python_w_deps {
  source           = "../."
  #script_path      = "${path.module}/helloworld.py"
  script_path      = "helloworld.py"
  pip_dependencies = ["requests==2.28.1"]
}


resource aws_lambda_function hello_world {
  filename         = module.lambda_python_w_deps.package_path
  function_name    = "hello_world_dependencies"
  role             = module.lambda_python_w_deps.aws_role_arn
  description      = "Lambda for testing dependencies"
  handler          = "${module.lambda_python_w_deps.handler_file_name}.handler"
  source_code_hash = module.lambda_python_w_deps.package_sha
  runtime          = "python3.8"
  timeout          = 120
  publish          = true
}
