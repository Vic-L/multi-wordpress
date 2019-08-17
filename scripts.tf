# download terraform-providers/null plugin
# with reference to https://github.com/hashicorp/terraform/issues/17621#issuecomment-477749470

resource "null_resource" "startup_script" {
  depends_on = [ aws_instance.this ]

  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    source      = "./startup.sh"
    destination = "/tmp/startup.sh"
  }

  connection {
    host = aws_eip.this.public_ip
    type = "ssh"
    user  = "ec2-user"
    password = ""
    private_key = file("${path.module}/multi_wordpress")
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/startup.sh",
      "/tmp/startup.sh"
    ]
  }
}

resource "null_resource" "automount_reboot_script" {
  depends_on = [
    aws_instance.this,
    null_resource.startup_script
  ]

  provisioner "file" {
    source      = "./automount_reboot.sh"
    destination = "/tmp/automount_reboot.sh"
  }

  connection {
    host = aws_eip.this.public_ip
    type = "ssh"
    user  = "ec2-user"
    password = ""
    private_key = file("${path.module}/multi_wordpress")
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/automount_reboot.sh",
      "/tmp/automount_reboot.sh"
    ]
  }
}