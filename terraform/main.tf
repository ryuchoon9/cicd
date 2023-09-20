provider "ncloud" {

  support_vpc = true
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# VPC
data "ncloud_vpc" "selected" {
  id = var.vpc_no
}

#Public Subnet
data "ncloud_subnet" "pub_subnet" {
  id = var.pub_sub_no
}

#Private Subnet
data "ncloud_subnet" "pri_subnet" {
  id = var.pri_sub_no
}

#NAT Gateway
data "ncloud_nat_gateway" "nat_gateway" {
  id = var.nat_gateway_no
}

# Server
resource "ncloud_server" "server_shryu_public" {
  subnet_no                 = data.ncloud_subnet.pub_subnet.id
  name                      = "${var.my_name}-public"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  login_key_name            = "var.name_pemkey"
  //server_product_code       = "SVR.VSVR.STAND.C002.M008.NET.SSD.B050.G002"
}

resource "ncloud_server" "server_shryu_private" {
  subnet_no                 = data.ncloud_subnet.pri_subnet.id
  name                      = "${var.my_name}-private"
  server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
  login_key_name            = "var.name_pemkey"
  //server_product_code       = "SVR.VSVR.STAND.C002.M008.NET.SSD.B050.G002"
}

# Public IP
resource "ncloud_public_ip" "public_ip_shryu" {
  server_instance_no = ncloud_server.server_shryu_public.id
  description        = "for ${var.my_name}"
}
