locals {
  argument_create = format("'%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'",
    var.subscription_id, var.client_id, var.client_secret, var.tenant_id,
    var.controller_public_ip, var.controller_private_ip, var.controller_username, var.controller_password,
    var.controller_resource_group_name, var.controller_network_security_group_name, var.controller_security_rule_name,
    var.controller_security_rule_priority, var.copilot_cluster_resource_group_name, var.main_copilot_public_ip,
    var.main_copilot_private_ip, var.main_copilot_username, var.main_copilot_password,
    var.main_copilot_network_security_group_name, var.main_copilot_security_rule_name,
    var.main_copilot_security_rule_priority, join(",", var.node_copilot_public_ips),
    join(",", var.node_copilot_private_ips), join(",", var.node_copilot_usernames),
    join(",", var.node_copilot_passwords), join(",", var.node_copilot_names),
    join(",", var.node_copilot_network_security_group_names), join(",", var.node_copilot_security_rule_names),
    join(",", var.node_copilot_security_rule_priorities), var.private_mode,
  )

  argument_destroy = format("'%s' '%s' '%s' '%s' '%s' '%s' '%s'",
    var.subscription_id, var.client_id, var.client_secret, var.tenant_id,
    var.controller_resource_group_name, var.controller_network_security_group_name, var.controller_security_rule_name,
  )
}

resource "null_resource" "run_script" {
  triggers = {
    argument_destroy = local.argument_destroy
  }

  provisioner "local-exec" {
    command = "python3 -W ignore ${path.module}/aviatrix_copilot_cluster_init.py ${local.argument_create}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "python3 -W ignore ${path.module}/clean_controller_sg.py ${self.triggers.argument_destroy}"
    on_failure = continue
  }
}
