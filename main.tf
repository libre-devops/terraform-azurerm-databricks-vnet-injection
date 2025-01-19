module "rg" {
  source = "libre-devops/rg/azurerm"

  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}


module "subnet_calculator" {
  source = "libre-devops/subnet-calculator/null"

  base_cidr = var.vnet_address_space[0]
  subnets = {
    var.databricks_public_subnet_name = {
      mask_size = 27
      netnum    = 0
    },
    var.databricks_private_subnet_name = {
      mask_size = 27
      netnum    = 1
    }
  }
}

module "network" {
  source = "libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = var.vnet_name
  vnet_location      = module.rg.rg_location
  vnet_address_space = var.vnet_name

  subnets = { for i, name in module.subnet_calculator.subnet_names :
    name => {
      address_prefixes = toset([module.subnet_calculator.subnet_ranges[i]])
      delegation       = [
        {
          type = "Microsoft.Databricks/workspaces"
        }
      ]
    }
  }
}

module "private_nsg" {
  source = "libre-devops/nsg/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  nsg_name              = var.private_nsg_name
  associate_with_subnet = true
  apply_standard_rules  = false
  subnet_id             = module.network.subnets_ids["private"]
  custom_nsg_rules      = {}
}


module "public_nsg" {
  source = "libre-devops/nsg/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  nsg_name              = var.public_nsg_name
  associate_with_subnet = true
  apply_standard_rules  = false
  subnet_id             = module.network.subnets_ids["public"]
  custom_nsg_rules      = {}
}



module "databricks_workspace" {
  source = "libre-devops/databricks-workspace/azurerm"

  databricks_workspaces = [
    {
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      name                                  = var.databricks_workspace_name

      custom_parameters = {
        no_public_ip                                         = true
        public_subnet_name                                   = var.databricks_public_subnet_name
        public_subnet_network_security_group_association_id  = module.public_nsg.nsg_subnet_association_ids[0]
        private_subnet_name                                  = var.databricks_private_subnet_name
        private_subnet_network_security_group_association_id = module.private_nsg.nsg_network_interface_security_group_association_ids[0]
        virtual_network_id                                   = module.network.vnet_id
        vnet_address_prefix                                  = module.network.vnet_address_space[0]
      }
    }
  ]
}
