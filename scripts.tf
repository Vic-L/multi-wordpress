# download terraform-providers/null plugin
# with reference to https://github.com/hashicorp/terraform/issues/17621#issuecomment-477749470

resource "null_resource" "startup" {
  depends_on = [
    aws_instance.this,
    module.secrets_bucket,
    aws_s3_bucket_object.ssh_key,
  ]

  provisioner "file" {
    source = "./scripts/startup.sh"
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

resource "null_resource" "reboot" {
  depends_on = [
    null_resource.startup
  ]

  provisioner "file" {
    source = "./scripts/reboot.sh"
    destination = "/tmp/reboot.sh"
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
      "chmod +x /tmp/reboot.sh",
      "/tmp/reboot.sh"
    ]
  }
}

resource "null_resource" "git_clone" {
  depends_on = [
    null_resource.startup,
    aws_s3_bucket_object.ssh_key,
  ]

  provisioner "file" {
    source = "./scripts/git_clone.sh"
    destination = "/tmp/git_clone.sh"
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
      "chmod +x /tmp/git_clone.sh",
      "/tmp/git_clone.sh ${module.secrets_bucket.id} ${var.multi_wordpress_repository}"
    ]
  }
}

resource "null_resource" "git_pull" {
  depends_on = [
    null_resource.git_clone,
    aws_s3_bucket_object.ssh_key,
  ]

  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    source = "./scripts/git_pull.sh"
    destination = "/tmp/git_pull.sh"
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
      "chmod +x /tmp/git_pull.sh",
      "/tmp/git_pull.sh"
    ]
  }
}

resource "null_resource" "app" {
  depends_on = [
    null_resource.git_pull,
    aws_s3_bucket_object.ssh_key,
  ]

  triggers = {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    source = "./scripts/app.sh"
    destination = "/tmp/app.sh"
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
      "chmod +x /tmp/app.sh",
      "/tmp/app.sh"
    ]
  }
}

resource "null_resource" "files" {
  provisioner "file" {
    source = "./nginx.conf"
    destination = "/multi_wordpress_volume/nginx.conf"
  }

  provisioner "file" {
    source = "./docker-compose.production.yml"
    destination = "/multi_wordpress_volume/docker-compose.production.yml"
  }
}