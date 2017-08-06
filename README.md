# Terraform Starter - Snowplow Analytics

## Terraform as Documentation

This repository is intended to be documentation of what a Snowplow (Scala Streaming) stack can look like. It attempts to explicitly state technical specifications of such a stack.

The documentation is written with [Terraform](https://www.terraform.io/)

## Terraform as a Starter

This repository may double as way to quickly create a working Snowplow Analytics stack.

1. `git clone https://github.com/fingerco/snowplow-terraform-starter.git && cd snowplow-terraform-starter`

1. `cp variables.tf.example variables.tf`

1. Modify variables.tf to configure everything

1. `terraform init`

1. `terraform plan`

1. `terraform apply`

1. `terraform destroy`

**Note:** Due to the extreme levels of customization that can happen in such a stack, I cannot promise that this setup will fit your exact needs.

I encourage you to look through this, understand it, and modify it as you need.


## Contributions

Feel free to fork this and submit a Pull Request, if you'd like to improve upon it!
