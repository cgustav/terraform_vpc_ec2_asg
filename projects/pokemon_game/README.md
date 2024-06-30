# Pokemon Online Game AWS Infrastructure

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Pokemon](https://img.shields.io/badge/Pokemon-%23FFCB05.svg?style=for-the-badge&logo=pokemon&logoColor=black)

This project deploys a resilient infrastructure on AWS to serve an online Pokemon game application. The infrastructure is managed using Terraform and designed for high availability and scalability.

## Infrastructure Overview

- **VPC**: Custom VPC with four subnets (two public, two private) across two Availability Zones
- **EC2 Instances**: 
  - Web servers in an Auto Scaling Group
  - MySQL database server
- **Load Balancer**: Distributes traffic among web server instances
- **Security Groups**: Configured for web and database tiers
- **Terraform**: Used for infrastructure as code and management

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- Basic knowledge of AWS services and Terraform

## Quick Start

1. Clone the repository:
   ```
   git clone https://github.com/your-username/pokemon-game-aws.git
   cd pokemon-game-aws
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Review the Terraform plan:
   ```
   terraform plan
   ```

4. Apply the Terraform configuration:
   ```
   terraform apply
   ```

5. Confirm the action by typing `yes` when prompted.

## Project Structure

```
pokemon-game-aws/
│
├── main.tf           # Main Terraform configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── vpc.tf            # VPC and subnet configurations
├── ec2.tf            # EC2 instances and Auto Scaling Group
├── rds.tf            # RDS MySQL instance
├── alb.tf            # Application Load Balancer
├── security.tf       # Security Groups
└── README.md         # This file
```

## Configuration

Modify the `variables.tf` file to customize your deployment:

- `region`: AWS region for deployment
- `vpc_cidr`: CIDR block for the VPC
- `public_subnet_cidrs`: CIDR blocks for public subnets
- `private_subnet_cidrs`: CIDR blocks for private subnets
- `db_username`: Username for the MySQL database
- `db_password`: Password for the MySQL database (use AWS Secrets Manager in production)

## Outputs

After successful deployment, Terraform will output:

- VPC ID
- Public subnet IDs
- Private subnet IDs
- Load Balancer DNS name
- Database endpoint

## Cleaning Up

To destroy the created infrastructure:

```
terraform destroy
```

Confirm the action by typing `yes` when prompted.

## Security Considerations

- Ensure that your AWS credentials are kept secure and not committed to version control.
- Review and adjust security group rules as needed for your specific requirements.
- Consider using AWS Secrets Manager for database credentials in a production environment.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Pokemon is a trademark of Nintendo, Creatures Inc., and GAME FREAK inc.
- This project is for educational purposes only and is not affiliated with Pokemon or Nintendo.