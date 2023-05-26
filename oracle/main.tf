variable "compartment_ocid" { }

resource "oci_core_vcn" "lab" {
  compartment_id = var.compartment_ocid
  cidr_blocks = ["10.0.0.0/16"]
  display_name = "lab"

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_subnet" "lab_public" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.lab.id
  cidr_block = "10.0.0.0/24"
  display_name = "Public Subnet-lab"

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_subnet" "lab_private" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.lab.id
  cidr_block = "10.0.1.0/24"
  display_name = "Private Subnet-lab"

  lifecycle {
    prevent_destroy = true
  }
}

variable "instance_shape" {
  # Always Free Instance Eligible Shapes
  default = "VM.Standard.A1.Flex" # Or VM.Standard.E2.1.Micro
}
variable "instance_ocpus" { 
  default = 1
}
variable "instance_shape_config_memory_in_gbs" {
  default = 6
}
variable "image_source_id" {
  type = map(string)
}
variable "ssh_key" {
  type = map(string)
}

data "oci_identity_availability_domain" "ad1" {
  compartment_id = var.compartment_ocid
  ad_number = 1
}

data "oci_identity_availability_domain" "ad2" {
  compartment_id = var.compartment_ocid
  ad_number = 2
}

data "oci_identity_availability_domain" "ad3" {
  compartment_id = var.compartment_ocid
  ad_number = 3
}

resource "oci_core_instance" "rocky" {

  for_each = {
    rocky = data.oci_identity_availability_domain.ad3.name
    balboa = data.oci_identity_availability_domain.ad1.name
    adrian = data.oci_identity_availability_domain.ad2.name
  }

  #Required
  availability_domain = each.value
  compartment_id = var.compartment_ocid 
  shape = var.instance_shape

  #Optional
  display_name = each.key
  shape_config {
    memory_in_gbs             = var.instance_shape_config_memory_in_gbs
    ocpus                     = var.instance_ocpus
  }

  source_details {
    source_type = "image"
    source_id = var.image_source_id.rocky
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_public.id
    display_name     = each.key
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_key.svchost
  }
}

output "instance_rocky_id" {
  value = {
    for k, v in oci_core_instance.rocky : k => v.id
  }
  description = "OCID of rocky instances"
}
output "instance_rocky_public_ip" {
  value = {
    for k, v in oci_core_instance.rocky : k => v.public_ip
  }
  description = "Public IP address of rocky instances"
}
