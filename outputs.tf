output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN of the node IAM role (for aws-auth mapRoles)"
  value       = aws_iam_role.eks_nodes.arn
}

output "kubectl_config" {
  description = "kubeconfig content for the EKS cluster"
  value = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_id           = aws_eks_cluster.main.name
    cluster_endpoint     = aws_eks_cluster.main.endpoint
    cluster_auth_base64  = aws_eks_cluster.main.certificate_authority[0].data
  })
  sensitive = true
}
