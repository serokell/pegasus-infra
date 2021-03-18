terraform {
  backend "s3" {
    bucket         = "serokell-pegasus-tfstate"
    dynamodb_table = "serokell-pegasus-tfstate-lock"
    encrypt        = true
    key            = "pegasus/terraform.tfstate"
    region         = "eu-west-2"
  }
  ## Prevent unwanted updates
  required_version = "~> 0.12.29" # Use nix-shell or nix develop
}
