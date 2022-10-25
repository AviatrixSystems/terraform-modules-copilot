locals {
  argument_create = format("'%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'",
    var.user_id, var.tenancy_id, var.fingerprint, var.key_file, var.region,
    var.controller_public_ip, var.controller_private_ip, var.controller_username, var.controller_password,
    var.controller_nsg_id, var.main_copilot_public_ip,
    var.main_copilot_private_ip, var.main_copilot_username, var.main_copilot_password, var.main_copilot_nsg_id,
    join(",", var.node_copilot_public_ips), join(",", var.node_copilot_private_ips),
    join(",", var.node_copilot_usernames), join(",", var.node_copilot_passwords), join(",", var.node_copilot_names),
    join(",", var.node_copilot_nsg_ids),
  )
}

resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = "python3 -W ignore ${path.module}/aviatrix_copilot_cluster_init.py ${local.argument_create}"
  }
}
