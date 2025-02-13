# Core Banking Setup with Terraform


## Requirements

### Install Terraform


### Make a copy pf the `.tfvars` file 
```shell
cp terraform.example.tfvars terraform.tfvars
```

### Update the following in `terraform.tfvars`
- ami_id
- db_username
- db_password

### Create a public key 
```shell
ssh-keygen -t rsa -b 4096 -f ~/.ssh/core-bank-key
```

### AWS Environment Variables
```shell
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
```

## Run Setup
```shell
terraform init
terraform plan
terraform apply
```
