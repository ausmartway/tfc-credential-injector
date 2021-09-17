provider "tfe" {
  ##Please add your TFE token to TFE_TOKEN enviroment variable. 
  ##This token need to have permission to read all managed workspaces and write variables
  ## By default this provider manages TFC, to manage an TFE enviroment, set TFE_HOSTNAME envirioment variable to the hostname of you TFE.
}

provider "vault" {

}
//get a list of TFC/E workspaces that has tag 'aws'
data "tfe_workspace_ids" "aws-apps" {
  tag_names    = ["aws"]
  organization = var.organization
}

//Add AWS credentials as enviroment variables
resource "tfe_variable" "aws_access_key_id" {
  for_each     = data.tfe_workspace_ids.aws-apps.ids
  key          = "AWS_ACCESS_KEY_ID"
  value        = ""
  category     = "env"
  workspace_id = each.value
  description  = "AWS Access Key ID"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "tfe_variable" "aws_secret_access_key" {
  for_each     = data.tfe_workspace_ids.aws-apps.ids
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = "my_value_name"
  sensitive    = true
  category     = "env"
  workspace_id = each.value
  description  = "AWS Secret Access Key"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "tfe_variable" "aws_session_token" {
  for_each     = data.tfe_workspace_ids.aws-apps.ids
  key = "AWS_SESSION_TOKEN"
  sensitive    = true
  value        = "my_value_name"
  category     = "env"
  workspace_id = each.value
  description  = "AWS Session Token"
  lifecycle {
    ignore_changes = [value]
  }
}

##Optional AWS_REGION

# resource "tfe_variable" "aws_region" {
#   for_each     = data.tfe_workspace_ids.aws-apps.ids
#   key          = "AWS_REGION"
#   value        = var.aws_default_region
#   category     = "env"
#   workspace_id = each.value
#   description  = "AWS REGION"
# }



//get a list of TFC/E workspaces that has tag 'azure'
data "tfe_workspace_ids" "azure-apps" {
  tag_names    = ["azure"]
  organization = var.organization
}

#get azure credential from Vault
data "vault_generic_secret" "azure" {
    path = "kv/azure"
}

## Add Azure credentials ENV variables 
resource "tfe_variable" "azure_subscription_id" {
  for_each     = data.tfe_workspace_ids.azure-apps.ids
  key          = "ARM_SUBSCRIPTION_ID"
  value        = data.vault_generic_secret.azure.data["ARM_SUBSCRIPTION_ID"]
  category     = "env"
  workspace_id = each.value
  description  = "Azure Subscription Id"
  # lifecycle {
  #   ignore_changes = [value]
  # }
}

resource "tfe_variable" "azure_tenant_id" {
  for_each     = data.tfe_workspace_ids.azure-apps.ids
  key          = "ARM_TENANT_ID"
  value        = data.vault_generic_secret.azure.data["ARM_TENANT_ID"]
  category     = "env"
  workspace_id = each.value
  description  = "Azure Tenant Id"
  # lifecycle {
  #   ignore_changes = [value]
  # }
}

resource "tfe_variable" "azure_client_id" {
  for_each     = data.tfe_workspace_ids.azure-apps.ids
  key          = "ARM_CLIENT_ID"
  value        = data.vault_generic_secret.azure.data["ARM_CLIENT_ID"]
  category     = "env"
  workspace_id = each.value
  description  = "Azure Client Id"
  # lifecycle {
  #   ignore_changes = [value]
  # }
}

resource "tfe_variable" "azure_client_secret" {
  for_each     = data.tfe_workspace_ids.azure-apps.ids
  key          = "ARM_CLIENT_SECRET"
  value        = data.vault_generic_secret.azure.data["ARM_CLIENT_SECRET"]
  category     = "env"
  workspace_id = each.value
  sensitive = true
  description  = "Azure Client Secret"
}

#get Vault credential from Vault

resource "vault_token" "deployment" {
  display_name = "deployment"
  policies = ["super-user"]
  renewable = false
  ttl = "15d"
}

//get a list of TFC/E workspaces that has tag 'vault'
data "tfe_workspace_ids" "vault-apps" {
  tag_names    = ["vault","autoinject"]
  organization = var.organization
}


resource "tfe_variable" "vault_token" {
  for_each     = data.tfe_workspace_ids.vault-apps.ids
  key          = "VAULT_TOKEN"
  value        = vault_token.deployment.client_token
  category     = "env"
  workspace_id = each.value
  sensitive = true
  description  = "Vault Token"
}

resource "tfe_variable" "vault_addr" {
  for_each     = data.tfe_workspace_ids.vault-apps.ids
  key          = "VAULT_ADDR"
  value        = "set your vault address here."
  category     = "env"
  workspace_id = each.value
  sensitive = true
  description  = "Vault Token"
}
