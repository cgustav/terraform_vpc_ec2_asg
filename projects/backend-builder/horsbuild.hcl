bucket         = "pokemon-app-terraform-bucket-state-store"
key            = "terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "pokemon-app-terraform-state-lock"
encrypt        = false
