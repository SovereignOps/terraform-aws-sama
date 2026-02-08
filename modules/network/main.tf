resource "aws_vpc" "sama_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name           = "${var.project_name}-vpc"
    Classification = "Confidential"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.sama_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name           = "${var.project_name}-private-subnet-${count.index + 1}"
    Classification = "Confidential"
  }
}

# NACL with Deny All by Default (Implicitly, if no rules are added, it denies everything)
resource "aws_network_acl" "sama_nacl" {
  vpc_id     = aws_vpc.sama_vpc.id
  subnet_ids = aws_subnet.private_subnets[*].id

  # Explicit Deny All Rule (though implicit is deny)
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name           = "${var.project_name}-nacl-deny-all"
    Classification = "Top Secret"
  }
}

resource "aws_flow_log" "sama_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.sama_vpc.id
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name       = "/aws/vpc-flow-log/${var.project_name}"
  kms_key_id = var.kms_key_arn
}

resource "aws_iam_role" "flow_log_role" {
  name = "${var.project_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.project_name}-flow-log-policy"
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.flow_log_group.arn}:*"
      }
    ]
  })
}
