variable "ami_id" {
  description = "The ID of the AMI to use for the instance."
  type        = string
}

variable "db_username" {
  description = "The database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}
