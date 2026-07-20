variable "description" {
  description = "Description of the HTTP API."
  type        = string
  default     = null
}

variable "cors_allow_origins" {
  description = "Allowed CORS origins. Must be explicit origins (no wildcard) when credentials are allowed."
  type        = list(string)
  default     = []
}

variable "cors_allow_methods" {
  description = "Allowed CORS methods."
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "Allowed CORS request headers."
  type        = list(string)
  default     = ["Content-Type", "Authorization", "X-CSRF-Token"]
}

variable "cors_allow_credentials" {
  description = "Whether CORS requests may include credentials."
  type        = bool
  default     = true
}

variable "cors_max_age" {
  description = "CORS preflight cache duration in seconds."
  type        = number
  default     = 3600
}

variable "throttle_rate_limit" {
  description = "Default stage throttling rate limit (requests per second)."
  type        = number
  default     = 100
}

variable "throttle_burst_limit" {
  description = "Default stage throttling burst limit."
  type        = number
  default     = 200
}

variable "access_log_group_name" {
  description = "CloudWatch Logs log group name for API access logs."
  type        = string
}

variable "access_log_retention_days" {
  description = "Retention (days) for the API access log group."
  type        = number
  default     = 30
}

variable "access_log_format" {
  description = "Single-line JSON access log format string."
  type        = string
  default     = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\",\"integrationError\":\"$context.integrationErrorMessage\"}"
}

variable "integrations" {
  description = "Map of handler key => Lambda invoke ARN. One AWS_PROXY integration is created per entry."
  type        = map(string)
  default     = {}
}

variable "function_names" {
  description = "Map of handler key => Lambda function name. One invoke permission is granted per entry."
  type        = map(string)
  default     = {}
}

variable "routes" {
  description = "Map of route_key (e.g. \"GET /api/health\") => handler key (must exist in integrations)."
  type        = map(string)
  default     = {}
}

variable "create_5xx_alarm" {
  description = "Whether to create a CloudWatch 5xx alarm for the API."
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "SNS topic ARNs (or other action ARNs) to notify when the 5xx alarm fires."
  type        = list(string)
  default     = []
}
