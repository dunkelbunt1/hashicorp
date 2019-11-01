
# Connect to a remote beackend 
data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "pmi-vault-tf-backend"
    key    = "vra/${terraform.workspace}/vault-cluster"
    region = ""${var.region}"
  }
}
#Extract data from the remote backend and save it locally to loop over it
locals {
  vault_server_ip = data.terraform_remote_state.s3.outputs.vault_server_ips
}
#Literate over the the local variable to connect to every single host
resource "null_resource" "plugin_install" {
for_each = {for ip in local.vault_server_ip : ip => ip}
  provisioner "remote-exec" {
  connection {
    type        = "ssh"
    host        = each.value.vault_server_ip
    user        = "${var.ssh_username}"
    password    = "${var.ssh_password}"
    script_path = "/home/${var.ssh_username}/plugin.sh"
  }
  # Install a custom plugin
    inline = [
      "export SHA256=$(sha256sum /home/vault/plugins/vault-secrets-gen | cut -d' ' -f1)",
      "vault write sys/plugins/catalog/secrets-gen sha_256=$SHA256 command=vault-secrets-gen",
      "vault login '${var.vault_server_token}'",
      "vault secrets enable -path=gen -plugin-name=secrets-gen plugin",
    ]
  }
}
