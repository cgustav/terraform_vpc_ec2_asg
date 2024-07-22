# Backend Builder for Terraform State

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue.svg)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-4.0+-orange.svg)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Managing Terraform state can be challenging, especially when it comes to setting up and maintaining remote backends. Manually creating resources for state storage is often tedious and time-consuming. Moreover, declaring backend resources within your main project can lead to circular dependencies and complicate your infrastructure management.

This Backend Builder simplifies and automates the process of creating a robust remote backend for your Terraform projects. By separating the backend setup from your main infrastructure code.

## Prerequisites

- Terraform installed (recommended version: 1.0 or higher)
- Linux-based CLI
- AWS credentials with sufficient permissions to perform S3 and DynamoDB management operations
- AWS CLI configured with appropriate credentials

## Project Structure

The project consists of the following main files:

- `main.tf`: Main resource definition (S3 bucket and DynamoDB table)
- `outputs.tf`: Project outputs definition
- `variables.tf`: Declaration of variables used in the project
- `deploy.sh`: Automation script for deployment

## Quick Start

1. **Configure variables:**
   Copy the example file and edit the properties according to your desired configuration:

   ```bash
   cp build.tfvars.example build.tfvars
   ```

2. **Initialize the project:**

   ```bash
   terraform init
   ```

3. **Plan the deployment:**

   ```bash
   terraform plan -var-file=build.tfvars -out=planned.tfplan
   ```

4. **Apply the plan:**
   If everything looks good, execute the plan:

   ```bash
   terraform apply "planned.tfplan"
   ```

5. **Capture output variables:**

   ```bash
   terraform output -json > ./infrastructure.json
   ```

   You can now use the values stored in `infrastructure.json` to configure your backend files or Terraform scripts.

## Automation Script

For faster execution, you can use the `deploy.sh` automation script:

1. **Configure variables:**

   ```bash
   cp build.tfvars.example build.tfvars
   ```

   Edit `build.tfvars` according to your needs.

2. **Run the script:**

   ```bash
   chmod +x ./deploy.sh

   ./deploy.sh --backend-file-out=/path/to/your/terraform-project/backend.hcl
   ```

   This command will deploy S3 and DynamoDB resources and generate a `backend.hcl` file in the specified path.

## Using the Remote Backend

Once the `backend.hcl` file is generated, you can use it in other Terraform projects:

1. In the Terraform project where you want to use the remote backend, initialize with:

   ```bash
   terraform init -backend-config=/path/to/backend.hcl
   ```

2. You can now plan and deploy your resources with a remote backend in S3.
3. Reconfigure your terraform state in case you already did without a remote backend configuration

   ```bash
   terraform init -reconfigure -backend-config=path/to/backend.hcl
   ```

## Security Considerations

- Ensure that AWS credentials are properly configured and have the minimum necessary permissions.
- Consider using server-side encryption for the S3 bucket.
