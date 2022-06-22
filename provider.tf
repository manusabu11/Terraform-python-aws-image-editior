provider "aws" {

  profile = var.profile_non_prod
  region  = var.aws_region
}
provider "local" {

}
provider "archive" {
}
