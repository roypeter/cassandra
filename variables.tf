variable "add_seeds" {
  description = "add seeds from other region"
  default = []
}

variable "project_name" {
  description = "project name"
  default = "cassandra"
}

variable "cassandra_cluster_name" {
  description = "cassandra cluster name"
  default = "cassandra"
}


variable "cassandra_version" {
  description = "cassandra version"
  default = "311x"
}

variable "machine_type" {
  description = "GCE machine type"
  default = "n1-standard-4"
}

variable "boot_disk_size" {
  description = "boot disk size in GB"
  default = 20
}

variable "data_disk_size" {
  description = "data disk size in GB"
  default = 100
}

variable "tags" {
  description = "tags"
  default = ["allow-private-ssh", "default-to-internet"]
}

variable "subnetwork" {
  description = "subnetwork"
  default = "default"
}

variable "ssh_user" {
  description = "ssh user name for remote exec"
}

variable "ssh_key_path" {
  description = "ssh key path name for remote exec"
}

variable "bootstrap" {
  description = "false for new cluster, true for adding nodes to existing cluster"
}

