# provider info
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.46"
}

# Create a S3 bucket which will hold the tfstate info for all projects. Each project will have a separate key to access the bucket inorder to get the relevant tfstate from teh S3 bucket.
# The tfstate can be encrypted.
resource "aws_s3_bucket" "enterprise_backend_state" {
  bucket = "dev-application-backend-state-sonypuli" // Note : Bucket names do not support underscores!!!
  // Lifecysle : Allows to specify whtehr a terraform destro can delete the bucket or not.
  lifecycle {
    prevent_destroy = false
    #prevent_destroy = true
  }

  // Versioning : Allows fallback to previous revisions 
  versioning {
    enabled = true
  }


  // Encryption : Allows contents of the bucket to be encrypted
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" // use algoithm Advanced Encryption Standard - 256   
      }
    }
  }

}






# Lock defintion 
# Note : We will need to defiuen a lock as multiple projects/users will try to access the tfstate. SOoif a user is using a bcuket, they should lock it so that others cannot access it at the sam e time.
# Dynamo DB : We will use a dynamo DB to for locking and isolation. 
## Process : Get a lock, update the tf state and finally release the lock.

resource "aws_dynamodb_table" "enterprise_backend_lock" {
  name         = "dev_application_locks"
  billing_mode = "PAY_PER_REQUEST" // Note : there are other options for billing. ReferAWS documentation.

  // Hash each row in the Dynamo db table - refer below declaration for table attribute/column names
  hash_key = "LockID" // The hash key used is the LockID attribute/column which is defined below


  //Table Attribute/Column defintion 
  attribute {
    name = "LockID" // This name value "LockID" cannot be changed !!
    type = "S"      // String
  }

}
