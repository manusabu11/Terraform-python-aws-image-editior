Please enter inputs in file variables.tfvars.
aws access details is via profile.
terraform init
terrafrom plan -var-file="variables.tfvar"
terrafrom apply -var-file="variables.tfvar" -auto-approve

the lambda function is doing the exif metadata removal
