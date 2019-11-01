locals { 
  secretengines_list = csvdecode(file("${path.module}/securiy-engines.csv")) 
} 

resource "vault_mount" "secret_engines" { 
  for_each    = {for se in local.secretengines_list : se.id => se } 
  path        = lower(each.value.secret_engine) 
  type        = "kv" 
  description = "Secret Engine mount for ${lower(each.value.secret_engine)}. ${lower(each.value.description)} " 
  options = { 
    version = 2 
  } 
}

#Assuming you have a secret_engines.csv in the following format
#id,secret_engine,description
#1,TEST,This is a test
