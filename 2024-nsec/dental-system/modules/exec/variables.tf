variable "container_name" {
  type = string
}

variable "remote" {
  type = string
  nullable = true
  default = null
}

variable "condition" {
  type    = string
  default = "false"
}

variable "command" {
  type = string
}

variable "nonce" {
  type    = string
  default = "1"
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "cwd" {
  type     = string
  nullable = true
  default  = null
}

variable "uid" {
  type     = number
  nullable = true
  default  = null
}

variable "gid" {
  type     = number
  nullable = true
  default  = null
}
