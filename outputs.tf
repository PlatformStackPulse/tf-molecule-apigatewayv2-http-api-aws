output "api_id" {
  description = "The HTTP API identifier."
  value       = module.api.id
}

output "api_arn" {
  description = "The HTTP API ARN."
  value       = module.api.arn
}

output "api_endpoint" {
  description = "The default execute-api endpoint URI."
  value       = module.api.api_endpoint
}

output "execution_arn" {
  description = "The API execution ARN (for Lambda permission source ARNs)."
  value       = module.api.execution_arn
}

output "stage_invoke_url" {
  description = "The invoke URL of the default stage."
  value       = module.stage.invoke_url
}

output "access_log_group_arn" {
  description = "ARN of the access log group."
  value       = try(aws_cloudwatch_log_group.access[0].arn, null)
}
