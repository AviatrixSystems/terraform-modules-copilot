output aviatrix_copilot_private_ip {
  value       = aws_instance.aviatrixcopilot.*.private_ip
  description = "Private IP address of the Aviatrix Copilot"
}

output aviatrix_copilot_public_ip {
  value       = aws_eip.copilot_eip.*.public_ip
  description = "Public IP address of the Aviatrix Copilot"
}
