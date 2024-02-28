packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
  
    
# Set the `source_ami` to the base artifact id
source "amazon-ebs" "basic-ubuntu-cemtral" {
  region = "us-east-2"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
    }    

    owners      = ["099720109477"]
    most_recent = true
  
  }

  instance_type  = "t2.medium"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "packer_AWS_{{timestamp}}"

}

build {
  name = "ubuntu-amazon-ebs"
  sources = [ "source.amazon-ebs.basic-ubuntu-central"]
}

#export  HCP_PACKER_BUCKET_NAME=example-amazon-ebs
