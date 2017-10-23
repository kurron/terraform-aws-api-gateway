terraform {
    required_version = ">= 0.10.6"
    backend "s3" {}
}

provider "aws" {
    region     = "${var.region}"
}

resource "aws_api_gateway_rest_api" "rest_api" {
    name        = "${var.api_name}"
    description = "${var.api_description}"
}

resource "aws_api_gateway_resource" "parent_resource" {
    rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    parent_id   = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
    path_part   = "api"
}

resource "aws_api_gateway_resource" "child_resource" {
    rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
    parent_id   = "${aws_api_gateway_resource.parent_resource.id}"
    path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "parent_method" {
    rest_api_id        = "${aws_api_gateway_rest_api.rest_api.id}"
    resource_id        = "${aws_api_gateway_resource.parent_resource.id}"
    http_method        = "ANY"
    authorization      = "NONE"
    api_key_required   = "false"
    request_parameters = {
        "method.request.header.host" = true,
        "method.request.path.proxy" = true
    }
}

resource "aws_api_gateway_method" "child_method" {
    rest_api_id        = "${aws_api_gateway_rest_api.rest_api.id}"
    resource_id        = "${aws_api_gateway_resource.child_resource.id}"
    http_method        = "ANY"
    authorization      = "NONE"
    api_key_required   = "false"
    request_parameters = {
        "method.request.header.host" = true,
        "method.request.path.proxy" = true
    }
}

resource "aws_api_gateway_integration" "parent_integration" {
    depends_on = ["aws_api_gateway_method.parent_method"]

    rest_api_id             = "${aws_api_gateway_rest_api.rest_api.id}"
    resource_id             = "${aws_api_gateway_resource.parent_resource.id}"
    http_method             = "${aws_api_gateway_method.parent_method.http_method}"
    integration_http_method = "ANY"
    type                    = "HTTP_PROXY"
    uri                     = "http://httpbin.org/"
    passthrough_behavior    = "WHEN_NO_MATCH"
    cache_key_parameters    = []
    request_parameters      = {
        "integration.request.header.x-forwarded-host" = "method.request.header.host"
        "integration.request.path.proxy"              = "method.request.path.proxy"
    }
}

resource "aws_api_gateway_integration" "child_integration" {
    depends_on = ["aws_api_gateway_method.child_method"]

    rest_api_id             = "${aws_api_gateway_rest_api.rest_api.id}"
    resource_id             = "${aws_api_gateway_resource.child_resource.id}"
    http_method             = "${aws_api_gateway_method.child_method.http_method}"
    integration_http_method = "ANY"
    type                    = "HTTP_PROXY"
    uri                     = "http://httpbin.org/{proxy}"
    passthrough_behavior    = "WHEN_NO_MATCH"
    cache_key_parameters    = ["method.request.path.proxy"]
    request_parameters      = {
        "integration.request.header.x-forwarded-host" = "method.request.header.host",
        "integration.request.path.proxy"              = "method.request.path.proxy"
    }
}

resource "aws_api_gateway_deployment" "deployment" {
    depends_on = ["aws_api_gateway_integration.parent_integration","aws_api_gateway_integration.child_integration"]

    rest_api_id       = "${aws_api_gateway_rest_api.rest_api.id}"
    stage_name        = "development"
    description       = "Just kicking the tires on Terraform integration"
    stage_description = "API releases currently under development"
}
