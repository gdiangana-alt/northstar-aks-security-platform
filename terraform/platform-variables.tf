variable "aks_name" {
  description = "AKS cluster name."
  type        = string
  default     = "northstar-aks-security"
}

variable "system_node_vm_size" {
  description = "Small validation node size for the AKS system pool."
  type        = string
  default     = "Standard_D2ps_v6"
}
