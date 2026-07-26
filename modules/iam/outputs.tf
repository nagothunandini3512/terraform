output "ebs_csi_driver_arn" {
  description = "IAM role ARN for the EBS CSI driver pod identity association"
  value       = aws_iam_role.ebs_csi_driver.arn
}
