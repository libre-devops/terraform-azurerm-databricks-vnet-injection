variable "databricks_private_subnet_name" {
  type        = string
  description = "The name of the private subnet to create for the Databricks workspace"
  default     = "private"
}

variable "databricks_public_subnet_name" {
  type        = string
  description = "The name of the public subnet to create for the Databricks workspace"
  default     = "public"
}

variable "databricks_workspace_name" {
  type        = string
  description = "The name of the Databricks workspace"
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
  default     = "uksouth"
}

variable "private_nsg_name" {
  type        = string
  description = "The name of the private subnet NSG to create for the Databricks workspace"
  default     = "private"
}

variable "public_nsg_name" {
  type        = string
  description = "The name of the public subnet NSG to create for the Databricks workspace"
  default     = "public"
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
}

variable "vnet_address_space" {
  description = "The address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vnet_name" {
  description = "The name of the VNet to inject the Databricks workspace into"
  type        = string
}
