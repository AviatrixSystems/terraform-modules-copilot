locals {
  argument_create = format("'%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'",
    var.project_id, var.service_account_private_key,
    var.controller_public_ip, var.controller_private_ip, var.controller_username, var.controller_password,
    var.controller_network_tag, var.main_copilot_public_ip, var.main_copilot_private_ip,
    var.main_copilot_username, var.main_copilot_password, var.main_copilot_network_tag,
    join(",", var.node_copilot_public_ips), join(",", var.node_copilot_private_ips),
    join(",", var.node_copilot_usernames), join(",", var.node_copilot_passwords), join(",", var.node_copilot_names),
    join(",", var.node_copilot_network_tags)
  )
}

resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = "python3 -W ignore ${path.module}/aviatrix_copilot_cluster_init.py ${local.argument_create}"
  }
}
