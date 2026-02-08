output "cluster_endpoint" {
  value = aws_eks_cluster.sama_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.sama_cluster.name
}
