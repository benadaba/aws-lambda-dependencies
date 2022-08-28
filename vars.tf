variable script_path {
  default = "helloworld.py"
}

# don't put boto3 inside: you have boto3 in Lambda python env
# you have a limit of 5MB package!d
variable pip_dependencies {
  default = [] 
}

variable temp_package_folder {
  default = "python_lambda_package"
}

variable package_filename {
  default = "package.zip"
}
