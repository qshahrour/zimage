packer {
  required_plugins {
    amazon = {
      version = "~> 1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "basic-test" {
  region          = "eu-central-1"
  instance_type   = "m2.medium"
  source_ami      = "ami-0faab6bdbac9486fb"
  ssh_username    = "ubuntu"
  ami_name        = "basic-amazon-ebs"
  skip_create_ami = true
}

build {
  sources = ["source.amazon-ebs.basic-test"]
}
