provider "tfe" {
  ##Please add your TFE token to TFE_TOKEN enviroment variable. 
  ##This token need to have permission to read all managed workspaces and write variables
  ## By default this provider manages TFC, to manage an TFE enviroment, set TFE_HOSTNAME envirioment variable to the hostname of you TFE.
}

provider "vault" {
  ##Please add your Vault address and token to VAULT_ADDR and VAULT_TOKEN enviroment variable.
}
//get a list of TFC/E workspaces that has tag 'aws' and 'autoinject'
data "tfe_workspace_ids" "aws-apps" {
  tag_names    = ["aws","autoinject"]
  organization = var.organization
}

//Add AWS credentials as enviroment variables, with no value.
resource "tfe_variable" "aws_access_key_id" {
  for_each     = data.tfe_workspace_ids.aws-apps.ids
  key          = "AWS_ACCESS_KEY_ID"
  value        = "set your aws_access_key_id here"
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
  value        = "set your aws_secret_access_key here"
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
  value        = "set your aws_session_token here"
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



//get a list of TFC/E workspaces that has tag 'azure' and 'autoinject'
data "tfe_workspace_ids" "azure-apps" {
  tag_names    = ["azure","autoinject"]
  organization = var.organization
}

#get azure credential from Vault in path'kv/azure'
data "vault_generic_secret" "azure" {
    path = "kv/azure"
}

#Attach workspaces with azure and autoinject tag to Azure variable set.
data "tfe_variable_set" "azure" {
  name         = "Global Varset for Azure"
  organization = var.organization
}

resource "tfe_workspace_variable_set" "azure" {
  for_each = data.tfe_workspace_ids.azure-apps.ids
  variable_set_id = data.tfe_variable_set.azure.id
  workspace_id    = each.value
}


#get Vault credential from Vault

resource "vault_token" "deployment" {
  display_name = "deployment"
  policies = ["super-user"]
  renewable = true
  ttl = "744h" //24 hour *31 days
}

//get a list of TFC/E workspaces that has tag 'vault' and 'autoinject'
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
  value        = "http://vault.yulei.aws.hashidemos.io"
  category     = "env"
  workspace_id = each.value
  sensitive = true
  description  = "Vault Address"
}
