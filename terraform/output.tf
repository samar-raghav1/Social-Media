output "instance_public_ip" {
    value = aws_instance.social-instance.public_ip
}
output "instance_public_dns" {
    value = aws_instance.social-instance.public_dns
}
output "instance_public_ip" {
    value = aws_instance.social-kube.public_ip
}
output "instance_public_dns" {
    value = aws_instance.social-kube.public_dns
}

# ansible inventory file

output "ansible_inventory" {
  value = <<EOT
[ec2]
${aws_instance.social-instance.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/socialmediakey
EOT
}
