## ASHDOLL

### Generate RSA SSH_KEY

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/yy

chmod 600 ~/.ssh/avrora

# SSH ( if you had skill issue )
ssh -v -i ~/.ssh/yy user@your_public_ip
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

#### VARIABLES

```bash
# terraform.tfvars
ssh_public_key = "YOUR_PUBLIC_KEY"

```

#### BASIC VPS SETUP

```bash
### NOTE : preferably create a new user for every newly spawn instance you had (do your homework) ###

### CHANGE PASSWORD ###
# root
sudo passwd root

# default_user
sudo passwd user

### UPDATE PACKAGES ###
sudo apt update -y

### UTILITIES ###
sudo apt install -y build-essential git tmux unzip curl wget

### AWS CLI ###
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws --version
```
