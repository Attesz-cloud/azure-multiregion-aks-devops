variable "region_location" { type = string }
variable "region_short" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "hub_cidr" { type = string }
variable "spoke_cidr" { type = string }
variable "aks_subnet_cidr" { type = string }
variable "tags" { type = map(string) }