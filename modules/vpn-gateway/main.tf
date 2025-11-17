resource "aws_vpn_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.environment}-vpn-gateway"
    Environment = var.environment
  }
}

resource "aws_customer_gateway" "onpremise" {
  bgp_asn    = 65000
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name        = "${var.environment}-customer-gateway"
    Environment = var.environment
    Location    = "on-premise"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.onpremise.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name        = "${var.environment}-vpn-connection"
    Environment = var.environment
  }
}

resource "aws_vpn_connection_route" "onpremise" {
  destination_cidr_block = var.onpremise_cidr
  vpn_connection_id      = aws_vpn_connection.main.id
}
