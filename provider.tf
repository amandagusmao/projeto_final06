terraform {
  required_version = ">=0.12"

provider "azurerm" {
  features {}
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
}