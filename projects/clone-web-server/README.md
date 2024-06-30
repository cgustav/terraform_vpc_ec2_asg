# Cloning Websites and serving with EC2

## Cloning websites

Create your script for cloning websites, edit it, and adapt it to your needs

```bash
cp clone.example.sh clone.sh
# Add a new line for each website you want to clone
# Example:
# (website to clone/destination directory)
echo "clone_site 'http://website.com' './website'" >> clone.sh
```

Run the command to clone the static content of the websites you want:

```bash
chmod +x clone.sh
./clone.sh
```

## Deploy infrastructure on AWS

Initialize the state of your terraform project (make sure you have generated valid credentials and stored them in your AWS configuration file).

```bash
terraform init
```

Deploy your infrastructure on AWS.

```bash
terraform apply
```

Finally, destroy your infrastructure on AWS.

```bash
terraform destroy
```

## Requirements

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [AWS CLI Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS CLI Permissions](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [WGET](https://www.gnu.org/software/wget/)