hello:
	echo "hellow world"

tf_plan:
	cd example
	terraform init
	terraform plan

tf_apply:
	cd example
	terraform init
	terraform apply --auto-approve

tf_destroy:
	cd example
	terraform destroy --auto-approve