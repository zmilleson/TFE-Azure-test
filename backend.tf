# Secrets and backend config are stored in a .tfvars file which is ignored by git.
# Run the following to utilize the .tfvars file as a config for the backend:
# terraform init -backend-config="secrets.tfvars"

terraform {
   backend "azurerm" {}
}