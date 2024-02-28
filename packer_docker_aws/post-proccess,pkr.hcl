

source "docker" "example" {
    image = "ubuntu:22.04"
    export_path = "party_parrot.tar"
}  

post-processor "docker-import" {
    repository = "local/ubuntu"
    tag = "latest"
  }

post-processor "docker-import" {
  repository = "hashicorp/packer"
  tag = "0.7"
}

post-processor "docker-import" {
  repository = "local/centos6"
  tag = "latest"
  changes = [
    "USER www-data",
    "WORKDIR /var/www",
    "ENV HOSTNAME www.example.com",
    "VOLUME /test1 /test2",
    "EXPOSE 80 443",
    "LABEL version=1.0",
    "ONBUILD RUN date",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]",
    "ENTRYPOINT /var/www/start.sh",
  ]
}
#}
