output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = local.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = local.bucket_arn
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "ec2_test_instance_id" {
  description = "Instance ID for the EC2 destroy test"
  value       = try(aws_instance.destroy_test[0].id, null)
}

output "ec2_test_private_ip" {
  description = "Private IP for the EC2 destroy test"
  value       = try(aws_instance.destroy_test[0].private_ip, null)
}
