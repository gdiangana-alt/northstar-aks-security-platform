variable "location" {
  description = "Azure region for the platform."
  type        = string
  default     = "canadacentral"
}

variable "resource_group_name" {
  description = "Dedicated resource group for this implementation."
  type        = string
  default     = "northstar-aks-security-rg"
}

variable "alert_email_address" {
  description = "Email address for cost-budget alerts."
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly project budget in the subscription billing currency."
  type        = number
  default     = 35
}

variable "budget_start_date" {
  description = "First day of the current billing month in UTC."
  type        = string
  default     = "2026-10-01T00:00:00Z"
}
