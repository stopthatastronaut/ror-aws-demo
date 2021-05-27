resource "aws_instance" "rordemo" {
  ami           = "ami-0585c832178a3fc32"
  instance_type = "t3.micro"
  # current pricing suggests t3.micro is cheap and will work for demo purposes
  # and qualifies for per-second billing so I can't possibly go bankrupt :)

  key_name                    = "rorawsdemo"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.rorsec.name]
  iam_instance_profile        = aws_iam_instance_profile.rordemoprofile.id

  # add
  user_data = <<-EOF
                sudo add-apt-repository universe

                sudo apt-get update

                sudo apt-get install -y apache2

                # Rails install script sourced from the RoR site.
                sudo apt-get update
                sudo apt-get install -y curl gpgv2 ruby-dev

                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
                echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
                sudo apt-get update && sudo apt-get install -y yarn

                gem install bundler

                echo "setting up rails"

                gem install rails -v 6.1.3.2

                rails -v

                echo "setting up a dummy file in WWW"

                echo "<h1>hello world</h1>" | sudo tee /var/www/html/index.html
                EOF

  tags = {
    Name = "RoR-AWS-demo"
    Stage = "Apache static"
  }
}

variable "ssh_in_cidr" {}

resource "aws_security_group" "rorsec" {
  name = "rorinstancesec"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSL with ACME is a nice-to-have bonus right now
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      var.ssh_in_cidr
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-basic-apache"
  }
}

# always good to assign a role. Used to be you couldn't add that afterwards
# failing to assign an EC2 role is frankly an antipattern, but there are caveats
# don't let roles over-proliferate
# don't make your roles too complex. Sure, Terraform is human-readable, but what human wants to read that?

resource "aws_iam_instance_profile" "rordemoprofile" {
  name = "test_profile"
  role = aws_iam_role.rordemorole.name
}


resource "aws_iam_role" "rordemorole" {
  name = "ror_dev_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


data "aws_route53_zone" "tako" {
  name = "takofukku.io."
}

resource "aws_route53_record" "rorawsdemo" {
  zone_id = data.aws_route53_zone.tako.zone_id
  name    = "rorawsdemo.${data.aws_route53_zone.tako.name}"
  type    = "A"
  ttl     = 600
  records = [aws_instance.rordemo.public_ip]
}

