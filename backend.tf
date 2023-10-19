terraform {
  backend "s3" {
    bucket = "terraform-state-cp-aws"
    key    = "slack-dnd-tf-state/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
