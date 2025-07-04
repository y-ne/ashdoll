## ASHDOLL

### Generate RSA SSH_KEY

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/avrora

chmod 600 ~/.ssh/avrora

# SSH ( if you had skill issue )
ssh -v -i ~/.ssh/avrora admin@your_public_ip
```

### AWS

```bash
# MacOS
brew install awscli

aws configure sso

# Output
# AWS Access Key ID [None]: SECRET
# AWS Secret Access Key [None]: SECRET
# Default region name [None]: ap-southeast-1
# Default output format [None]: json
```

#### variables

```bash
# terraform.tfvars
ssh_public_key = "YOUR_PUBLIC_KEY"

```
