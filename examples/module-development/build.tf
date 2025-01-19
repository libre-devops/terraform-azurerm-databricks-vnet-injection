
module "databricks_vnet_injection" {
  source = "../../"

  rg_name                   = "rg-${var.short}-${var.loc}-${var.env}-02"
  databricks_workspace_name = "databricks-${var.short}-${var.loc}-${var.env}-01"
  vnet_name                 = "vnet-${var.short}-${var.loc}-${var.env}-01"
  tags                      = local.tags
}

