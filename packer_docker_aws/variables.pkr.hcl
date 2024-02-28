# variables.pkr.hcl
variable "key" {
    sensitive = true
    default   = {
        key = "SECR3TP4SSW0RD"
        type        = string
        default     = "the default value of the `foo` variable"
        escription = "description of the `foo` variable"
        sensitive   = false
    }   
}
    # When a variable is sensitive all string-values from that variable will be
    # obfuscated from Packer's output.

variable "image_id" {
    type        = string
    description = "The ID of the machine image (AMI) to use for the server."

    validation {
        condition       = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
        error_message   = "The image_id value must be a valid AMI ID, starting with \"ami-\"."
    }

    validation {
        condition     = substr(var.image_metadata.something.foo, 0, 3) == "bar"
        error_message = "The image_metadata.something.foo field must start with \"bar\"."
    }
}
    validation {
        # regex(...) fails if it cannot find a match
        condition     = can(regex("^ami-", var.image_id))
        error_message = "The image_id value must be a valid AMI ID, starting with \"ami-\"."
    }
}

variable "availability_zone_names" {
    type    = list(string)
    default = ["us-west-1a"]
}

variable "docker_ports" {
    type = list(object({
        internal = number
        external = number
        protocol = string
}    ))
    default = [
        {
        internal = 8300
        external = 8300
        protocol = "tcp"
        }
    ]
}
    
#packer inspect var-foo.pkr.hcl
#"echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
#chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}

provisioner "shell" {
  environment_vars = [
    "FOO=foo",
    "BAR=bar's",
    "BAZ=baz=baz",
    "QUX==qux",
    "FOOBAR=foo bar",
    "FOOBARBAZ='foo bar baz'",
    "QUX2=\"qux\""
  ]
  inline = [
    "echo \"FOO is $FOO\"",
    "echo \"BAR is $BAR\"",
    "echo \"BAZ is $BAZ\"",
    "echo \"QUX is $QUX\"",
    "echo \"FOOBAR is $FOOBAR\"",
    "echo \"FOOBARBAZ is $FOOBARBAZ\"",
    "echo \"QUX2 is $QUX2\""
  ]
}

