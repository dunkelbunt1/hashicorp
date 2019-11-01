#THis is used to increase the lease time for Vault control groups

provider "vault" {
        address = var.vault_server_address
        token = var.vault_server_token
        skip_tls_verify = var.vault_server_skip_tls_verify
}
resource "vault_generic_endpoint" "control-goup-lease" {
  path      = "/sys/config/control-group"
    data_json = <<EOT
    {
    "max_ttl": "3d"
    }
    EOT
}
