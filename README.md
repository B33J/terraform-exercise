# This repo is an exercise in learning and using Terraform.

## Structure of repo:

**main.tf** - main configuration file that creates the plan

**variables.tf** - variables that are used inside the main.tf file for easy value editing

**terraform_plan_apply_output.txt** - the output from running the APPLY command

**terraform_plan_output.txt** - a review of the plan to be executed

## What it does:
* Interacts with AWS.
* Makes a zip of the lambda function node.js file (index.js) for a Lambda@Edge function.
* Creates an Origin Access Identity that the CloudFront distribution uses to access the S3 bucket.
* Creates an S3 bucket which holds all of the website files.
* Creates a null_resource to execute an AWS CLI command to upload the files to the bucket while simultaenously setting the metadata of cache-control max-age to 300 seconds.
* Creates an IAM role for the lambda function to use to be able to run on Lambda's backend.
* Creates an IAM policy to give permissions to the Lambda function.
* Creates the Lambda function itself and selects the zip of the js files to upload and use.
* Creates the CloudFront distribution which uses the S3 bucket as the Origin, includes the Lambda function, and uses the `*.b33j.com` SSL cert. 
* Searches existing hosted zone records for the root domain's ARN to associate the SSL certificate.
* Creates the record (subdomain) under the root domain (b33j.com) and makes an alias that points to the CloudFront distribution.
