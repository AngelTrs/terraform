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
variable "instance_ocpus" { default = 1 }
variable "instance_shape_config_memory_in_gbs" { default = 6 }
variable "image_source_id" { 
  # Canonical-Ubuntu-18.04-aarch64-2022.03.02-0
  default = "ocid1.image.oc1.iad.aaaaaaaadccmxiexvxgfkrnc4lsfsmeqyjaimxdz6jud7s24gmf6g2dddpna"

  # Canonical-Ubuntu-20.04-aarch64-2022.08.15-0 for us-ashburn-1
  # = "ocid1.image.oc1.iad.aaaaaaaant4oipiblsefokfvssw76b2tr2p6ckr6yzsuf4kxijvpdlxsydoq"
}

variable "ssh_public_key1" {}
variable "ssh_public_key2" {}

data "oci_identity_availability_domain" "ad1" {
  compartment_id = var.compartment_ocid
  ad_number = 1
}

data "oci_identity_availability_domain" "ad3" {
  compartment_id = var.compartment_ocid
  ad_number = 3
}

resource "oci_core_instance" "svc-remote" {
  #Required
  availability_domain = data.oci_identity_availability_domain.ad1.name
  compartment_id = var.compartment_ocid 
  shape = var.instance_shape

  #Optional
  display_name = "svc-remote-instance"
  shape_config {
    memory_in_gbs             = var.instance_shape_config_memory_in_gbs
    ocpus                     = var.instance_ocpus
  }

  source_details {
    source_type = "image"
    source_id = var.image_source_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_public.id
    display_name     = "svc-remote-instance"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key1
  }
}

resource "oci_core_instance" "uptime" {
  #Required
  availability_domain = data.oci_identity_availability_domain.ad3.name
  compartment_id = var.compartment_ocid 
  shape = var.instance_shape

  #Optional
  display_name = "uptime-instance"
  shape_config {
    memory_in_gbs             = var.instance_shape_config_memory_in_gbs
    ocpus                     = var.instance_ocpus
  }

  source_details {
    source_type = "image"
    source_id = var.image_source_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_public.id
    display_name     = "uptime-instance"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key2
  }
}
