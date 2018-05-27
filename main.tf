data "template_file" "install" {
  template = "${file("${path.module}/templates/install.tpl")}"
  vars {
    cassandra_version = "${var.cassandra_version}"
  }
}

data "template_file" "configure" {
  template = "${file("${path.module}/templates/configure.tpl")}"
  vars {
    cluster_name = "${var.cassandra_cluster_name}"
    seeds = "${local.seeds}"
  }
}

data "template_file" "attach_disk" {
  template = "${file("${path.module}/templates/attach_disk.tpl")}"
}

data "google_compute_zones" "available" {}

locals {
  count = "${length(data.google_compute_zones.available.names)}"
  seeds = "${join("," , concat( slice(google_compute_instance.default.*.network_interface.0.address,0,2),var.add_seeds))}"
}

resource "google_compute_disk" "default" {
  count = "${local.count}"

  name  = "${var.project_name}-data-${count.index}"
  type  = "pd-ssd"
  zone  = "${data.google_compute_zones.available.names[count.index]}"
  size  = "${var.data_disk_size}"
}

resource "google_compute_instance" "default" {
  count = "${local.count}"

  name         = "${var.project_name}-${count.index}"
  machine_type = "${var.machine_type}"
  zone         = "${data.google_compute_zones.available.names[count.index]}"
  allow_stopping_for_update = true

  tags = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20180509"
      size  = "${var.boot_disk_size}"
      type  = "pd-ssd"
    }
  }
  
  attached_disk {
    source = "${element(google_compute_disk.default.*.name, count.index)}"
  }

  network_interface {
    subnetwork = "${var.subnetwork}"
  }
}

resource "null_resource" "attach_disk" {
  count = "${local.count}"

  depends_on = ["google_compute_disk.default"]

  triggers {
    script = "${data.template_file.attach_disk.rendered}"
  }

  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(google_compute_instance.default.*.network_interface.0.address, count.index)}"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.attach_disk.rendered}"]
  }
}

resource "null_resource" "install" {
  count = "${local.count}"

  depends_on = ["null_resource.attach_disk"]
  triggers {
    script = "${data.template_file.install.rendered}"
  }

  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(google_compute_instance.default.*.network_interface.0.address, count.index)}"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.install.rendered}"]
  }
}

resource "null_resource" "configure" {
  count = "${local.count}"
  
  depends_on = ["null_resource.install"]
  triggers {
    script = "${data.template_file.configure.rendered}"
  }

  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    private_key = "${file("${var.ssh_key_path}")}"
    host = "${element(google_compute_instance.default.*.network_interface.0.address, count.index)}"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.configure.rendered}"]
  }
}
