terraform {
  required_version = ">= 1.2.2"

  required_providers {
    oci = {
      source = "oracle/oci"
      version = "4.89.0"
    }
  }
}

variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "private_key_path" { type = string }
variable "fingerprint" { type = string }
variable "region" { type = string }

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  region = var.region
}
