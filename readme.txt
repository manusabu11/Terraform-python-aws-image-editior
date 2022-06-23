Please enter inputs in file variables.tfvars.
aws access details is via profile.
terraform init
terrafrom plan -var-file="variables.tfvars"
terrafrom apply -var-file="variables.tfvars" -auto-approve

the lambda function is doing the exif metadata removal
