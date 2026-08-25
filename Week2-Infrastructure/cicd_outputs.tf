output "cicd_instance_public_ip" {
  description = "Public IP of the dedicated CI/CD deployment instance"
  value       = aws_instance.cicd.public_ip
}

output "cicd_ssh_private_key" {
  description = "SSH private key for the CI/CD instance. Copy this exact value into the GitHub secret EC2_SSH_KEY. Run 'terraform output -raw cicd_ssh_private_key' to get it without escaping."
  value       = tls_private_key.cicd.private_key_pem
  sensitive   = true
}

output "cicd_app_url" {
  description = "Direct URL to the app running on the CI/CD instance"
  value       = "http://${aws_instance.cicd.public_ip}:${var.app_port}"
}
