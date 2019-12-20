Repository contains modules to utilize in infrastructure patterns defined in another repo: https://github.com/slitsevych/terragrunt-example-live

Modules only contain Terraform code and all variable data is set as a variable {}

Outputs from modules are being exchanged through "discovered" configuration data method in the way as it was proposed in 
https://github.com/solsglasses/terraform-control

Discovered Configuration Data are attributes of resources that Terraform has created. Examples: 
The VPC module needs to share subnets data with RDS module, the RDS module needs to share its endpoint with the Ec2 module,
etc.

All variable configuration data that is shared between modules is done with AWS's SSM Parameter Store.
This has the added benefit of being able to share data with 3rd party tools outside of Terraform.

Other methods (like data.terraform_remote_state, or outputs {}) are not being used intentionally.