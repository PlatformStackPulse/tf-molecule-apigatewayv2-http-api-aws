locals {
  enabled = module.this.enabled
  tags    = module.this.tags
}

# HTTP API (v2)
module "api" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-apigatewayv2-api-aws.git?ref=61e8dd063cd693e3d26978859c3da4c0e6e2f19d"

  context       = module.this.context
  protocol_type = "HTTP"
  description   = var.description

  cors_configuration = {
    allow_origins     = var.cors_allow_origins
    allow_methods     = var.cors_allow_methods
    allow_headers     = var.cors_allow_headers
    allow_credentials = var.cors_allow_credentials
    max_age           = var.cors_max_age
  }
}

# Access log group
resource "aws_cloudwatch_log_group" "access" {
  count = local.enabled ? 1 : 0

  name              = var.access_log_group_name
  retention_in_days = var.access_log_retention_days
  tags              = local.tags
}

# Default stage with throttling + JSON access logging
module "stage" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-apigatewayv2-stage-aws.git?ref=381b2bd5d7744996faaffce0e2f48bc48769c7aa"

  context     = module.this.context
  api_id      = module.api.id
  stage_name  = "$default"
  auto_deploy = true

  default_route_settings = {
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }

  access_log_destination_arn = local.enabled ? aws_cloudwatch_log_group.access[0].arn : null
  access_log_format          = var.access_log_format
}

# One AWS_PROXY integration per handler
module "integration" {
  for_each = local.enabled ? var.integrations : {}
  source   = "git::https://github.com/PlatformStackPulse/tf-atom-apigatewayv2-integration-aws.git?ref=dc3912a79d19796cbfae7ba94ce726b1d3231702"

  context         = module.this.context
  api_id          = module.api.id
  integration_uri = each.value
}

# One route per route_key, targeting the integration of its handler
module "route" {
  for_each = local.enabled ? var.routes : {}
  source   = "git::https://github.com/PlatformStackPulse/tf-atom-apigatewayv2-route-aws.git?ref=f69353f058af96150a0f07c3423d6f797cf1a4a1"

  context   = module.this.context
  api_id    = module.api.id
  route_key = each.key
  target    = "integrations/${module.integration[each.value].id}"
}

# Allow API Gateway to invoke each backing Lambda
resource "aws_lambda_permission" "invoke" {
  for_each = local.enabled ? var.function_names : {}

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"
}

# 5xx alarm for the API
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  count = local.enabled && var.create_5xx_alarm ? 1 : 0

  alarm_name          = "${module.this.id}-5xx"
  alarm_description   = "API Gateway 5xx errors for ${module.this.id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xx"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ApiId = module.api.id
    Stage = module.stage.name
  }

  tags = local.tags
}
