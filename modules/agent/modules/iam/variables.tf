variable "secret_arns" {
  description = "A list of arns of secrets and keys to grant accesss to."
  type        = list(string)
  default     = []
}
