output ec2-info {
  value       = aws_instance.aviatrixcopilot.*
  description = "EC2 instance info"
}

output private_ip {
  value       = aws_instance.aviatrixcopilot.*.private_ip
  description = "Private IP address of the Aviatrix Copilot"
}

output public_ip {
  value       = aws_eip.copilot_eip.*.public_ip
  description = "Public IP address of the Aviatrix Copilot"
}
