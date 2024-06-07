variable "nebocicd_cluster" {
  description = "name of cluster"
  type        = string
  default     = "nebocicd-cluster"

}
variable "region" {
  description = "name of cluster"
  type        = string
  default     = "us-east-1"

}

variable "ecr_repository_uri" {
  description = "URI for the ECR repository"
  type        = string
  default     = "590183940136.dkr.ecr.us-east-1.amazonaws.com/nebo_cicd"
}

variable "ecr_image_tag" {
  description = "Tag for the image in the ECR repository"
  type        = string
  default     = "latest"
}
