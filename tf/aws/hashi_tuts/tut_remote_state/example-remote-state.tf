# remote state for team workflows

# required configuration
# sign up
#   - https://app.terraform.io/signup
# follow steps:
#   - https://learn.hashicorp.com/terraform/cloud/tf_cloud_gettingstarted.html
# Error: Required token could not be found   # didn't do the config steps


terraform {
  backend "remote" {
    organization = "Cloud-Org"
    workspaces {
      name = "Dev-QA"
    }
  }
}

