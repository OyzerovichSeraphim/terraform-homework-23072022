variable "token" {
  type        = string
}

variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "access_key" {
  type        = string
}

variable "secret_key" {
  type        = string
}

variable "zone" {
  type        = string
  default     = "ru-central1-b"
}

variable "family_image" {
  type        = string
  default     = "lamp"
}

variable "vpc_subnet_id" {
  type        = string
}
