#Its for uploading a jpeg image to an s3 bucket then do an extraction of its metadata then re-upload to new s3 bucket.

Please enter inputs in file variables.tfvars.
aws access details is via profile.
terraform init
terrafrom plan -var-file="variables.tfvars"
terrafrom apply -var-file="variables.tfvars" -auto-approve

the lambda function is doing the exif metadata removal
