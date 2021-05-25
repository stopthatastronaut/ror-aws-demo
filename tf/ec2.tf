resource "aws_instance" "rordemo" {
    ami = "ami-0585c832178a3fc32"
    instance_type = "t3.micro"
    # current pricing suggests t3.micro is cheap and will work for demo purposes
    # and qualifies for per-second billing so I can't possibly go bankrupt :)

    key_name = "rorawsdemo"
    associate_public_ip_address = true

# add
    user_data = <<-EOF
                #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y httpd
                sudo apt-get install -y ruby node yarn

                sudo add-apt-repository -y ppa:certbot/certbot


                sudo apt-get install python-certbot-apache

                sudo gem install rails

                sudo chkconfig httpd on
                sudo service httpd start
                echo "<h1>hello world</h1>" | sudo tee /var/www/html/index.html
                EOF

    tags = {
        Name = "terraform-basic-apache"
    }
}

variable "ssh_in_cidr" {}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # SSL with ACME is a nice-to-have bonus right now
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [
            var.ssh_in_cidr
            ]
    }

    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_route53_zone" "tako" {
    name = "takofukku.io."
}

resource "aws_route53_record" "rorawsdemo" {
    zone_id = data.aws_route53_zone.tako.zone_id
    name = "rorawsdemo.${data.aws_route53_zone.tako.name}"
    type = "A"
    ttl = 600
    records = [aws_instance.rordemo.public_ip]
}

