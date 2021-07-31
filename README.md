# Introduction
This is my first project 'Deploying a Web Server in Azure' project as part of the 'Cloud DevOps using Microsoft Azure' nanodegree program from [Udacity](https://udacity.com). In this project we created Insfrustructure as Code.  

Main Steps
The project consists of the following main steps:
- Deploying a policy
- Creating a Packer template
- Creating a Terraform template
- Deploying the infrastructure
- Creating documentation in the form of a README

# Instructions

## Deploy the policy

Create the policy definitition:
```
az policy definition create --name tagging-policy --mode indexed --rules policy.json
```
Assign the policy definition:
```
az policy assignment create --policy tagging-policy --name tagging-policy
```

## Create a template using packer

Login to azure:
```
az login
```

Before running packer, create a resource group to contain all the resources:
```
az group create -n udacity-project1-rg -l eastus 
```
Create a service principal to allow packer to build templates in azure:
```
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

On the machine you are running packer from, set the following environment variables using the output from the above command, along with your subscription ID:

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- TENANT_ID
- SUBSCRIPTION_ID

we create environment variables for above values
We used these values in creating [server.json](server.json) file.


Create the template in azure:
```
packer build server.json
```

## Provision resources using terraform

Download plugins:
```
terraform init
```  
The following settings can be customized by editing the variables in the [vars.tf](vars.tf) file:
- prefix - The prefix which should be used for all resources in this project
- location - The Azure Region in which all resources in this project should be created.
- number_of_vms - Number of VMs to provision
- username - The username for VM.
- password - The password for VM.
- image - The VM image to deploy (should match the name of the image created by packer)

Provison the resources:
```
terraform apply
```
Once your resources are no longer required, delete them:
```
terraform destroy
```
Finally, you can delete the resource group:
```
az group delete -n udacity-project1-rg
```
