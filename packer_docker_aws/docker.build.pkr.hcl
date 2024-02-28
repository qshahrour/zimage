

source "docker" "example" {
    image = "ubuntu"
    commit = true
      changes = [
      "USER www-data",
      "WORKDIR /var/www",
      "ENV HOSTNAME www.example.com",
      "VOLUME /test1 /test2",
      "EXPOSE 80 443",
      "LABEL version=1.0",
      "ONBUILD RUN date",
      "CMD [\"nginx\", \"-g\", \"daemon off;\"]",
      "ENTRYPOINT /var/www/start.sh"
    ]
}

post-processors {
    post-processor "docker-import" {
        repository =  "qshahrour"
        tag = "latest"
      }
    post-processor "docker-push" {}
  }
}

  post-processors {
    post-processor "docker-tag" {
        repository =  "qshahrour"
        tags = ["latest"]
      }
    post-processor "docker-push" {}
  }
}

 post-processors {
    post-processor "docker-tag" {
        repository =  "myrepo/myimage1"
        tags = ["0.7"]
      }
    post-processor "docker-push" {}
  }
  post-processors {
    post-processor "docker-tag" {
        repository =  "myrepo/myimage2"
        tags = ["0.7"]
      }
    post-processor "docker-push" {}
  }
}

post-processors {
  post-processor "docker-tag" {
    repository = "public.ecr.aws/YOUR REGISTRY ALIAS HERE/YOUR REGISTRY NAME HERE"
    tags       = ["latest"]
  }

  post-processor "docker-push" {
    ecr_login = true
    aws_access_key = "YOUR KEY HERE"
    aws_secret_key = "YOUR SECRET KEY HERE"
    login_server = "public.ecr.aws/YOUR REGISTRY ALIAS HERE"
  }
}   

       post-processor "docker-tag" {
            repository = "public.ecr.aws/YOUR REGISTRY ALIAS HERE/YOUR REGISTRY NAME HERE"
            tags       = ["latest"]
        }

        post-processor "docker-push" {
            "ecr_login": true,
            "aws_access_key": "YOUR KEY HERE",
            "aws_secret_key": "YOUR SECRET KEY HERE",
            login_server = "public.ecr.aws/YOUR REGISTRY ALIAS HERE"
        }
    }
