


build {
    name    = "learn-packer"
    sources = [
        "source.docker.ubuntu"
    ]
    
    provisioner "shell" {
        environment_vars = [
            "FOO=hello world",
    ]
    
        inline = [
            "echo Adding file to Docker Container",
            "echo \"FOO is $FOO\" > example.txt",
        ]
    }

    provisioner "shell" {
        inline = ["echo This provisioner runs last"]
  
        ]
    }

}




