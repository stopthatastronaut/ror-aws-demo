# ror-aws-demo

A very basic demo of running a simple Ruby On Rails app on EC2.

## Current:

Builds a VM, a Sec Group, and a DNS name based on an existing Route53 Zone. Installs Apache and a basic hello page. TODO: the Ruby On Rails Hello app.

## Fun Facts

- This [Github repo](https://github.com/stopthatastronaut/ror-aws-demo) is itself managed by Terraform, running from and source-controlled in Azure DevOps
- The state was placed in an existing S3 bucket, controlled from the same Terraform config. That config deploys on merge to `main`, via PR, [githubflow](https://githubflow.github.io/) wise.
- The UserData that builds the box was piloted in [Vagrant/virtualbox](https://vagrantup.com/) on a Macbook Pro
- Having never built out a Rails box before, I drew on what I could from the documentation, meaning there could be all manner of idiosyncracies in here. IRL, I'd have a RoR developer on hand to assist with those questions - an important point. You can't just build an environment without knowing what your devs need (unless you're just doing a demo and/or showing off)
- I was tempted to build a windows version just for fun, but AWS only does per-second billing for Linux, and Windows images tend to be more resource hungry. So I figured I'd save the beer money.

## Possible Enhancements and/or notable bugs and bugbears

- Instead of building an EC2 instance which is deployed to multiple times, it could build an immutable AMI or Docker image, which would be better from a dependency point of view
- building that AMI/Docker image could literally happen from CI on commit/PR
- Additional post-deploy tests
- Place the instance behind an ALB or ELB for improved security and the opportunity to scale out
- Add an Octopus Tentacle, to enable delivery
- swap out some variable formatting (Azure DevOps coerces ENV_VARS to upper case, for instance, so this CI chain may constitute a bug)
- Creating PEM keys and finding the appropriate AMI are tony tricky things that could always be done better.

[![CircleCI](https://circleci.com/gh/stopthatastronaut/ror-aws-demo.svg?style=svg)](https://circleci.com/gh/stopthatastronaut/ror-aws-demo)
