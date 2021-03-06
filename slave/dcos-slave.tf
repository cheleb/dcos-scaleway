#resource "scaleway_ip" "server-ip" {
#  server = "${scaleway_server.server.id}"
#}

data "scaleway_image" "centos" {
  architecture = "x86_64"
  name         = "CentOS 7.2"
}


resource "scaleway_server" "server" {
  name                = "${var.server_name}"
  image               = "${data.scaleway_image.centos.id}"
  type                = "VC1M"
  dynamic_ip_required = true
  security_group      = "${var.security}"

  volume {
    size_in_gb = 50
    type       = "l_ssd"
  }

  provisioner "remote-exec" {
    inline = [
      "yum remove docker",
      "service firewalld stop",
      "yum remove docker-common",
      "curl https://get.docker.com |sh",
      "chkconfig ntpd on",
      "ntpdate -s ntp.ubuntu.com",
    ]
  }
}

resource "scaleway_security_group_rule" "security-rule" {
  security_group = "${var.security}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${scaleway_server.server.private_ip}"
  protocol  = "TCP"
}

output "internal_ip" {
  value = "${scaleway_server.server.private_ip}"
}
