
==============================================================================
 DOM03 - IaC Lab 3: AWS Infrastructure with Terraform
==============================================================================

------------------------------------------------------------------------------
1. OVERVIEW
------------------------------------------------------------------------------

This project uses Terraform to deploy a VPC with a public subnet and an EC2
instance on AWS. Terraform state is stored remotely in an S3 bucket, with a
DynamoDB table used for state locking.

The code is split into reusable modules (network, server) that are composed
together by the environment configuration (envs/prod). The remote backend
resources are created separately by a bootstrap configuration.


------------------------------------------------------------------------------
2. PROJECT STRUCTURE
------------------------------------------------------------------------------

DOM03-IACLab/
|-- bootstrap/
|   `-- main.tf            Creates the S3 state bucket and DynamoDB lock table
|
|-- envs/
|   `-- prod/
|       |-- backend.tf     Points Terraform state at the S3 bucket
|       |-- versions.tf    Required Terraform and provider versions
|       |-- providers.tf   AWS provider configuration
|       |-- variables.tf   Input variables for the environment
|       |-- terraform.tfvars  Values for this environment
|       |-- main.tf        Calls the network and server modules
|       `-- outputs.tf     Values printed after apply
|
|-- modules/
|   |-- network/           VPC, internet gateway, public subnet, route table
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   `-- server/            Security group and EC2 instance
|       |-- main.tf
|       |-- variables.tf
|       `-- outputs.tf
|
`-- .gitignore

How the pieces connect:

  - bootstrap/ is run once, on its own. It is not called by anything.
  - envs/prod/ is the only place Terraform is run after that.
  - envs/prod/main.tf calls modules/network, takes its outputs (vpc_id,
    public_subnet_id) and passes them into modules/server.
  - The modules never call each other.


------------------------------------------------------------------------------
3. PREREQUISITES
------------------------------------------------------------------------------

  - Terraform >= 1.10 installed         (check: terraform version)
  - AWS CLI installed and configured    (check: aws sts get-caller-identity)
  - An AMI ID that exists in eu-west-1
  - Your public IP address              (e.g. from https://checkip.amazonaws.com)


------------------------------------------------------------------------------
4. DEPLOYMENT STEPS
------------------------------------------------------------------------------

STEP 1 - Create the remote backend (bootstrap)

    cd bootstrap
    terraform init
    terraform apply

  Type "yes" to confirm. When it finishes, note the two outputs:

    state_bucket_name = "lab3-state-backend-xxxxxx"
    lock_table_name   = "tf-state"


STEP 2 - Configure the backend for prod

  Open envs/prod/backend.tf and paste the values from Step 1:

    bucket         = "<state_bucket_name>"
    dynamodb_table = "<lock_table_name>"

  Note: the backend block cannot use variables or module outputs, so these
  values must be typed in directly.


STEP 3 - Set the environment values

  Edit envs/prod/terraform.tfvars:

    my_ip = "<your-public-ip>/32"
    ami   = "<ami-id-in-eu-west-1>"


STEP 4 - Initialise prod

    cd ../envs/prod
    terraform init

  Terraform connects to the S3 bucket and downloads the providers.
  Expect a deprecation warning about dynamodb_table; this is harmless.


STEP 5 - Review the plan

    terraform plan

  Confirm the plan shows resources to create: VPC, internet gateway,
  subnet, route table, route table association, security group, security
  group rules, and the EC2 instance.


STEP 6 - Apply

    terraform apply

  Type "yes" to confirm. At the end, Terraform prints the server's public
  IP (server_ip). The state file is written to the S3 bucket at
  prod/terraform.tfstate.


STEP 7 - Verify

  - EC2 console: the instance is running in the lab VPC and public subnet.
  - S3 console: the bucket contains prod/terraform.tfstate.
  - DynamoDB console: the lock table exists (a LockID entry appears while
    a plan or apply is running).


------------------------------------------------------------------------------
5. CLEANUP
------------------------------------------------------------------------------

STEP 8 - Destroy the prod infrastructure

    cd envs/prod
    terraform destroy

  Type "yes" to confirm.


STEP 9 - (Optional) Destroy the backend

  Only do this after Step 8, otherwise the prod state is lost.

  The bucket is protected by prevent_destroy and contains versioned state
  files, so first:
    1. Remove the lifecycle { prevent_destroy = true } block in
       bootstrap/main.tf (or add force_destroy = true to the bucket and apply terraform apply -target=aws_s3_bucket.state_backend).
    2. Empty the bucket, including all object versions, in the S3 console.
  Then:

    cd ../../bootstrap
    terraform destroy

  Finally, check the EC2, VPC, S3 and DynamoDB consoles to confirm nothing
  is left running.


==============================================================================
 DELIVERABLES
==============================================================================


------------------------------------------------------------------------------
D1. Screenshot - state setup
------------------------------------------------------------------------------

    i. init
    screenshots/state-init.png
    ii. plan
    screenshots/state-plan.png
    iii. apply
    screenshots/state-apply.png
    iv. destory
    screenshots/state-destroy-before-force.png
    screenshots/state-destory-after-force.png


------------------------------------------------------------------------------
D2. Screenshot - terraform plan
------------------------------------------------------------------------------

screenshots/prod-plan.png



------------------------------------------------------------------------------
D3. Screenshot - terraform apply
------------------------------------------------------------------------------

screenshots/prod-apply.png



------------------------------------------------------------------------------
D4. Screenshot - terraform destroy
------------------------------------------------------------------------------

screenshots/prod-destory.png



------------------------------------------------------------------------------
D5. AWS Console - EC2 instance
------------------------------------------------------------------------------

  screenshots/instance.png

------------------------------------------------------------------------------
D6. Proof of remote backend configuration
------------------------------------------------------------------------------

  S3 bucket (showing prod/terraform.tfstate)

  screenshots/state-bucket.png

  screenshots/state-in-bucket.png


  DynamoDB lock table

  screenshots/dynamo-db.png




------------------------------------------------------------------------------
NOTES
------------------------------------------------------------------------------

  - DynamoDB-based state locking is deprecated in Terraform 1.11+. The
    newer approach is use_lockfile = true in the S3 backend, which stores
    the lock in the bucket itself. I used DynamoDB here because it is a
    lab requirement.

==============================================================================