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

output "ecr_repository_url" {
  description = "ECR repository URL for image push"
  value       = try(aws_ecr_repository.app[0].repository_url, null)
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = try(aws_ecs_cluster.app[0].name, null)
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = try(aws_ecs_service.app[0].name, null)
}
