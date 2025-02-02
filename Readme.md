# Core Banking Setup with Terraform


## Requirements

### Create a public key 
```shell
ssh-keygen -t rsa -b 4096 -f ~/.ssh/corebank-key
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