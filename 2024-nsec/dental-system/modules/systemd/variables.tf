variable "name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "remote" {
  type     = string
  nullable = true
  default  = null
}

variable "command" {
  type = string
}

variable "working_directory" {
  type    = string
  default = "/"
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "user" {
  type    = string
  default = "root"
}

variable "group" {
  type    = string
  default = "root"
}

variable "after" {
  type    = list(string)
  default = ["network.target"]
}
