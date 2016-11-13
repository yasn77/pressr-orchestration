# PressR Orchestration
---
This repostiory contains the Terraform and Ansible configuration needed to bring up the PressR platform.

## Getting Started
It is highly recommended that you use [direnv](http://direnv.net/). A `.envrc` exists that facilitates in setting up virtualenv and source enviroment variables used by both Terraform and Ansible.

The following environment variables are required to be set:

|Environment Variable|Description|
|--------------------|-----------|
|`AWS_SECRET_ACCESS_KEY`|AWS Secret Access Key|
|`AWS_ACCESS_KEY_ID`|AWS Access Key ID|
|`TF_VAR_db_password`|Password used for the created AWS RDS Instance|
|`TF_VAR_access_key`|Set same as `AWS_ACCESS_KEY_ID`|
|`TF_VAR_secret_key`|Set Same as `AWS_ACCESS_KEY_ID`|
|`TF_VAR_sshpubkey_file`|Path to SSH private key (will be used to SSH in to EC2 Instances)|

If you use `direnv`, then these can be stored in `<REPO_ROOT>/.secrets` and will automatically be loaded and exported.

### Terraform
You will need to install [Terraform](https://www.terraform.io/). Installation instructions can be found on the [Terraform website](https://www.terraform.io/intro/getting-started/install.html). The code has been tested with Terraform version `v0.7.5`, however it should work fine with newer versions.

Below are the default variables (which can all be overriden using [environment variables](https://www.terraform.io/docs/configuration/environment-variables.html)):
```
variable "access_key" {}
variable "secret_key" {}
variable "sshpubkey_file" { default = "sshpub.key" }
variable "region" { default = "eu-west-1" }
variable "ami_id" {
  default = "ami-0d77397e"
}
variable "instance_type" {
  default = "t2.small"
}
variable "root_disk_size" {
  default = "25"
}
variable "db_username" { default = "pressr" }
variable "db_password" {}
# Instance count, per availability zone
variable "app_instance_count" { default = "2" }
variable "haproxy_instance_count" { default = "1" }
variable "consul_instance_count" { default = "2" }
variable "environment" {}
variable "resource_prefix" {}
variable "cidr_block" {}
variable "primary_subnet" {}
variable "secondary_subnet" {}
variable "db_name" {}
```

### Ansible
It is recommended to use virtualenv, if you use `direnv` this will automatically be created.

Ansible (and it's dependencies) can be installed using pip:
```shell
$ pip install -r requirements.txt # Run in the repository root folder
```
## Building an Environment
The repository supports two environments:
 - development
 - production

To launch and build and environment simply run `cloud-automation.sh` script:
```shell
$ ./cloud-automation.sh

The following environment variables need to be set:
        AWS_SECRET_ACCESS_KEY
        AWS_ACCESS_KEY_ID
        TF_VAR_db_password
        TF_VAR_access_key
        TF_VAR_secret_key
        TF_VAR_sshpubkey_file

Valid environments:
        development
        production

Valid app(s) that can be deployed:
        pressr

Usage: cloud-automation.sh <app> <environment> <num_servers> <server_size>

Note: <num_servers> is the number of instances to launch *per* availability zone
(currently configured to use 2 availability zones), so the actual instances
launched is <num_servers> * number_of_availability_zones
```
For example:
```shell
cloud-automation.sh pressr development 2 t2.small
```
This will launch a development environment in AWS, with 2 App instances per availability zone (2 availability are used), using t2.micro instances.

Since both Ansible and Terraform are idempotent, there is no harm in running the script multiple times (if configuration hasn't changed).

## Technical Details
The infrastructure comprises of:
 - EC2 instances that run:
  - The Docker apps
  - HAProxy
  - Consul
 - AWS ELB
 - AWS RDS (MySQL)

Consul (plus [registrator](http://gliderlabs.com/registrator/latest/) and [consul-template](https://github.com/hashicorp/consul-template)) is used to for Docker container discovery. Once a container comes online, metadata about the instance is stored in Consul and HAProxy configuration is created with the new container details.

HAProxy servers exist in both availability zones and the AWS ELB instance point to both all the HAProxy instances, ensuring high resiliancy.

Deployments to the App servers are limited to a set of servers (using Ansible [`serial`](http://docs.ansible.com/ansible/playbooks_delegation.html#rolling-update-batch-size)), to ensure that there will always be a number of hosts that can service requests. This is in attempt to minimise downtime during deployments.
