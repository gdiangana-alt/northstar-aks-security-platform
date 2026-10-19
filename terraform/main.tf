terraform {
 required_version = ">= 1.6.0"

 required_providers {
 azurerm = {
 source = "hashicorp/azurerm"
 version = "~> 4.0"
 }
 }

 backend "azurerm" {}
}

provider "azurerm" {
 features {}
}

resource "azurerm_resource_group" "platform" {
 name = var.resource_group_name
 location = var.location

 tags = {
 Project = "NorthStar AKS Security Platform"
 ManagedBy = "Terraform"
 Environment = "validation"
 Owner = "Guy Diangana"
 }
}

resource "azurerm_consumption_budget_resource_group" "platform" {
 name = "northstar-aks-security-monthly"
 resource_group_id = azurerm_resource_group.platform.id
 amount = var.monthly_budget_amount
 time_grain = "Monthly"

 time_period {
 start_date = var.budget_start_date
 end_date = "2030-01-01T00:00:00Z"
 }

 notification {
 enabled = true
 operator = "GreaterThan"
 threshold = 80
 threshold_type = "Actual"
 contact_emails = [var.alert_email_address]
 }

 notification {
 enabled = true
 operator = "GreaterThan"
 threshold = 100
 threshold_type = "Forecasted"
 contact_emails = [var.alert_email_address]
 }
}
