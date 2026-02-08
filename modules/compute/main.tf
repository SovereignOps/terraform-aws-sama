# EKS Cluster
data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_eks_cluster" "sama_cluster" {
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true  # HARDCODE: Private
    endpoint_public_access  = false # HARDCODE: No public access
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"] # HARDCODE: Audit Logs

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  tags = {
    Name           = "${var.project_name}-eks"
    Classification = "Confidential"
  }
}

# Node Group (Private)
resource "aws_eks_node_group" "sama_nodes" {
  cluster_name    = aws_eks_cluster.sama_cluster.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]

  tags = {
    Name           = "${var.project_name}-node-group"
    Classification = "Confidential"
  }
}

# IAM Role for Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# IAM Role for Nodes
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-eks-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  tags = {
    Name = "${var.project_name}-eks-sg"
  }
}
