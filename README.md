# Info
This repository is a Terraform IaC template that deploys the following resources to AWS:

- An API Gateway Endpoint with two paths, `turn_on` & `turn_off`
- An API GW Usage Plan restricted to an API Key
- Two Lambda functions `turn_on` & `turn_off`, triggered by the API GW
- A Lambda role that allows `ec2:StopInstances` & `ec2:StartInstances` (limited to specified `InstanceId`)

# Usage
This provides an API GW Endpoint on a `development` stage with two paths, `turn_on` and `turn_off`. `turn_on` turns the specified instance off, the same goes for `turn_off`. The endpoint is restricted with a Usage Plan to an API key and basic rate limiting. The API key can be retrieved from the console after deployment. Terraform will `output` the stage's URL as well. 

Terraform will package the Lambda Python code using a bash script.

# Deployment
## Prerequisites
- `terraform` installed `~0.14.0`
- `pip` installed
- AWS credentials set up

## How to deploy

1. Clone this repository
2. `terraform init`
3. Change the `instance_id` variable to your target instance's Id.
4. `terraform plan`
5. `terraform apply`