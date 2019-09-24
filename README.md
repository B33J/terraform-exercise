# This repo is an exercise in me learning and using Terraform.
___

## Structure of repo:

**main.tf** - main configuration file that creates the plan

**variables.tf** - variables that are used inside the main.tf file for easy value editing

**terraform_plan_apply_output.txt** - the output from running the APPLY command

**terraform_plan_output.txt** - a review of the plan to be executed

___
## What it does:
* Interacts with AWS.
* Makes a zip of the lambda function node.js file (index.js).
* Creates an Origin Access Identity that the CloudFront distribution uses to access the S3 bucket.
* Creates an S3 bucket which holds all of the website files.
* Creates a null_resource to execute an AWS CLI command to upload the files to the bucket while simultaenously setting the metadata of cache-control max-age to 300 seconds.
* Creates an IAM role for the lambda function to use to be able to run on Lambda's backend.
* Creates an IAM policy to give permissions to the Lambda function.
* Creates the Lambda function itself and selects the zip of the js files to upload and use.
* Searches existing hosted zone records for the root domain's ARN to associate the SSL certificate.
* Creates the record (subdomain) under the root domain (b33j.com) and makes an alias that points to the CloudFront distribution.

# Notes:

I am unable to find or develop a javascript solution that redirects any page that's not /index.html to said /index.html, but the entire Terraform function works perfectly.  I would need more time or to ask for help.
