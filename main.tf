required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  project_name = "core"
  environment  = "prod"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Architecture = "MultiRegion-DevOps"
  }
}


module "region_primary" {
  source          = "./modules/azure_region"
  region_location = "West Europe"
  region_short    = "westeurope"
  project_name    = locals.project_name
  environment     = locals.environment
  hub_cidr        = "10.100.0.0/16"
  spoke_cidr      = "10.101.0.0/16"
  aks_subnet_cidr = "10.101.1.0/24"
  tags            = locals.tags
}


module "region_secondary" {
  source          = "./modules/azure_region"
  region_location = "North Europe"
  region_short    = "northeurope"
  project_name    = locals.project_name
  environment     = locals.environment
  hub_cidr        = "10.200.0.0/16"
  spoke_cidr      = "10.201.0.0/16"
  aks_subnet_cidr = "10.201.1.0/24"
  tags            = locals.tags
}


resource "azurerm_virtual_network_peering" "global_primary_to_secondary" {
  name                         = "peer-global-westeurope-to-northeurope"
  resource_group_name          = module.region_primary.resource_group_name
  virtual_network_name         = module.region_primary.hub_vnet_name
  remote_virtual_network_id    = module.region_secondary.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "global_secondary_to_primary" {
  name                         = "peer-global-northeurope-to-westeurope"
  resource_group_name          = module.region_secondary.resource_group_name
  virtual_network_name         = module.region_secondary.hub_vnet_name
  remote_virtual_network_id    = module.region_primary.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}