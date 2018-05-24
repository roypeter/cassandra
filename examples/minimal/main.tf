provider "google" {
  credentials = "${file("path/to/service_account.json")}"
  project     = "project name"
  region      = "us-west1"
}

module "cassandra" {
  source = "../../"

  ssh_user = "ssh user name"
  ssh_key_path = "path/to/ssh/private/key"
}
