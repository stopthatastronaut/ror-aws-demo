# ror-aws-demo

A very basic demo of running a simple Ruby On Rails app on EC2.

## Current State

Builds a VM, a Sec Group, and a DNS name based on an existing Route53 Zone (and a few other bits).

- Installs Apache and a basic hello page.
- Can be SSH'd to if you have the right key (and your IP is whitelisted in the sec group)
- Has an instance profile, for access to S3 (for instance, to grab source code for a large-ish rails app)
- Fires up at location [rorawsdemo.takofukku.io](http://rorawsdemo.takofukku.io)
- Runs in CircleCI

![CircleCI Pipeline](/pipeline.png)

TODO: the Ruby On Rails Hello app.

## Fun Facts

- This [Github repo](https://github.com/stopthatastronaut/ror-aws-demo) is itself managed by Terraform, running from and source-controlled in Azure DevOps, with state in Azure Storage
- The state was placed in an existing S3 bucket, controlled from the same Terraform config.
- The config deploys on merge to `main`, via PR, [githubflow](https://githubflow.github.io/) wise. `develop` is the one-developer "hack away at it mate" branch.
- The UserData that builds the box was [piloted in](https://github.com/stopthatastronaut/VagrantLab/tree/master/Ubuntu1804Rails) [Vagrant/virtualbox](https://vagrantup.com/) on a Macbook Pro
- Having never built out a Rails box before, I drew on what I could from the documentation, meaning there could be all manner of idiosyncracies in here. IRL, I'd have a RoR developer on hand to assist with those questions - an important point. You can't just build an environment without knowing what your devs need (unless you're just doing a demo and/or showing off)
- I was tempted to build out a Windows version just for fun, but AWS only does per-second billing for Linux, and Windows images tend to be more resource hungry. So I figured I'd save the beer money. For now.

## Possible Enhancements and/or notable bugs and bugbears

- switch to nginx from Apache?
- Instead of building an EC2 instance which is deployed to multiple times, it could build an immutable AMI or Docker image, which would be better from a dependency point of view
- Building that AMI/Docker image could literally happen from CI on commit/PR
- Additional post-deploy tests
- Place the instance behind an ALB or ELB for improved security and the opportunity to scale out
- Add an Octopus Tentacle or register as an SSH target in Octopus, to enable delivery
- Swap out some variable formatting (Azure DevOps coerces ENV_VARS to upper case, for instance, so this CI chain may constitute a bug)
- Creating PEM keys and finding the appropriate AMI are tiny tricky things that could always be done better.
- The UserData/LaunchConfig might be better pulled from S3. At least you can run some kind of testing on it ahead of time that way.
- Key rotation and management is an open question. So our dev moves on, right? But he's got a private key that means he can walk into this instance.
- There's a bunch of inefficiency in the CI. I'd want that fixed.

[![CircleCI](https://circleci.com/gh/stopthatastronaut/ror-aws-demo.svg?style=svg)](https://circleci.com/gh/stopthatastronaut/ror-aws-demo)
