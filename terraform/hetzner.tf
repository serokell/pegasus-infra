data "vault_generic_secret" "hcloud_token" {
  path = "kv/sys/hetzner/tokens/pegasus"
}

provider "hcloud" {
  version = "~> 1.16.0"
  token = data.vault_generic_secret.hcloud_token.data["token"]
}
