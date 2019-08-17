provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-035b3c7efe6d061d5"
  instance_type = "t2.micro"
}