# Variable declaration
variable application_name {
  default = "07-backend-state"
}

variable project_name {
  default = "users"
}

variable environment {
  default = "dev"
}

# We want the tfstate for users to be stored in a S3 bucket instead of storing it locally 
terraform {
  backend "s3" {
    bucket = "dev-application-backend-state-sonypuli" // Bucket name is defined in main.tf of backend-state. 
    #key = "${var.application_name}-${var.project_name}-${var.environment}"                 // Best practise - key should contain app name , project name & environment
    key            = "dev/07-backend-state/users/backend-state" // Alternate method of defining key structure which will generate folder hierarchy in AWS -<> services -> S3. Best practise - key should contain app name , project name & environment
    region         = "us-east-1"
    dynamodb_table = "dev_application_locks" // table name is defined in main.tf of backend-state Specifies a lock so that multiple users cannot update the table together. 
    encrypt        = true                    // encrypt the tfstate of users
  }
}



# provider info
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.46"
}

# define IAM user
resource "aws_iam_user" "my_iam_user" {
  name = "${terraform.workspace}_django_machan_updated"   // Using teh workspace name can avoid compolictions whiel trying to create the user in different envoronmnets or workspaces as only one user with a unique anme can exist in AWS. 

}


