packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
  }
}


build {
    
    hcp_packer_registry {
        bucket_name = "learn-packer-ubuntu"
        description = "Description about the image being published."

    bucket_labels = {
    
        "owner"          = "platform-team"
        "os"             = "Ubuntu",
        "ubuntu-version" = "Jammy 22.04", 
    }

    build_labels = {
        "ubuntu-version" = Jammy 22.04"
        "build-time"   = timestamp()
        "build-source" = basename(path.cwd)
    }

    sources = ["source.amazon-ebs.basic-ubuntu-central"]


    provisioner "shell" {
        environment_vars = [
            "FOO=hello world",
        ]   
    }

        inline = [
            "echo Adding file to Docker Container",
            "echo \"FOO is $FOO\" > example.txt",
        ]
    }
    ############################

    provisioner "shell" {
        inline = ["echo Running ${var.docker_image} Docker image."]
    }

    provisioner "shell" {
        inline = ["echo Running $(cat /etc/os-release | grep VERSION= | sed 's/\"//g' | sed 's/VERSION=//g') Docker image."]
    }

    post-processor "docker-tag" {
        repository = "learn-packer"
        tags       = ["ubuntu-jammy", "packer-rocks"]
        only       = ["docker.ubuntu"]
    }

    post-processor "docker-tag" {
        repository = "learn-packer"
        tags       = ["ubuntu-focal", "packer-rocks"]
        only       = ["docker.ubuntu-focal"]
    }

}
