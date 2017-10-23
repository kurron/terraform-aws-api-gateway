variable "region" {
    type = "string"
    description = "The AWS region to deploy into (e.g. us-east-1)"
}

variable "api_name" {
    type = "string"
    description = "Name of the API"
}

variable "api_description" {
    type = "string"
    description = "Short description about the API"
}

variable "api_root_path" {
    type = "string"
    description = "Base path of the API, e.g. api"
}

variable "api_key_required" {
    type = "string"
    description = "If true, then an API key must be sent with each request, e.g. true"
}

variable "target_url" {
    type = "string"
    description = "URL to proxy requests to, e.g. http://httpbin.org"
}

variable "stage_name" {
    type = "string"
    description = "Current place in the API's lifecycle, e.g. production"
}

variable "stage_description" {
    type = "string"
    description = "Short description of the stage, e.g. API released for public consumption"
}

variable "deployment_description" {
    type = "string"
    description = "Short description of the first deployment, e.g. initial cut of the API"
}