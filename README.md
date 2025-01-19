```hcl
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
      delegation = [
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

      name = var.databricks_workspace_name

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
```
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_databricks_workspace"></a> [databricks\_workspace](#module\_databricks\_workspace) | libre-devops/databricks-workspace/azurerm | n/a |
| <a name="module_network"></a> [network](#module\_network) | libre-devops/network/azurerm | n/a |
| <a name="module_private_nsg"></a> [private\_nsg](#module\_private\_nsg) | libre-devops/nsg/azurerm | n/a |
| <a name="module_public_nsg"></a> [public\_nsg](#module\_public\_nsg) | libre-devops/nsg/azurerm | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | n/a |
| <a name="module_subnet_calculator"></a> [subnet\_calculator](#module\_subnet\_calculator) | libre-devops/subnet-calculator/null | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_private_subnet_name"></a> [databricks\_private\_subnet\_name](#input\_databricks\_private\_subnet\_name) | The name of the private subnet to create for the Databricks workspace | `string` | `"private"` | no |
| <a name="input_databricks_public_subnet_name"></a> [databricks\_public\_subnet\_name](#input\_databricks\_public\_subnet\_name) | The name of the public subnet to create for the Databricks workspace | `string` | `"public"` | no |
| <a name="input_databricks_workspace_name"></a> [databricks\_workspace\_name](#input\_databricks\_workspace\_name) | The name of the Databricks workspace | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | `"uksouth"` | no |
| <a name="input_private_nsg_name"></a> [private\_nsg\_name](#input\_private\_nsg\_name) | The name of the private subnet NSG to create for the Databricks workspace | `string` | `"private"` | no |
| <a name="input_public_nsg_name"></a> [public\_nsg\_name](#input\_public\_nsg\_name) | The name of the public subnet NSG to create for the Databricks workspace | `string` | `"public"` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space for the VNet | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the VNet to inject the Databricks workspace into | `string` | n/a | yes |

## Outputs

No outputs.
