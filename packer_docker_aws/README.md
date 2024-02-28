


#packer inspect var-foo.pkr.hcl
#"echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
#chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}


export  HCP_PACKER_BUCKET_NAME=example-amazon-ebs


## Some OS configurations don't properly kill all network connections on reboot, 
/etc/init.d/net.eth0 stop


## Note: when provisioning via git you should add the git server keys into the ~/.ssh/known_hosts file otherwise the git command could hang awaiting input.  ##

provisioner "shell" {
  inline = [
    "sudo apt-get install -y git",
    "ssh-keyscan github.com >> ~/.ssh/known_hosts",
    "git clone git@github.com:exampleorg/myprivaterepo.git"
  ]
}

Adding a -x flag to the shebang at the top of the script (#!/bin/sh -x) will echo the script

provisioner "shell" {
  inline = ["sleep 10"]
}
