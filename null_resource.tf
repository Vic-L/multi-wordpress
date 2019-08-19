# download terraform-providers/null plugin
# with reference to https://github.com/hashicorp/terraform/issues/17621#issuecomment-477749470

resource "null_resource" "bastion_connection" {
  depends_on = [ aws_instance.this ]

  connection {
    host = aws_eip.this.public_ip
    type = "ssh"
    user  = "ec2-user"
    password = ""
    private_key = file("${path.module}/multi_wordpress")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
    ]
  }
}