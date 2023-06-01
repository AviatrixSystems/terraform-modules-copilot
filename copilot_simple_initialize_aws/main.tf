locals {
  argument_create = format("'%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'",
    var.aws_access_key, var.aws_secret_access_key, var.controller_public_ip, var.controller_private_ip,
    var.controller_region, var.controller_username, var.controller_password,
    var.copilot_public_ip, var.copilot_private_ip, var.copilot_username, var.copilot_password,
    var.private_mode, var.controller_sg_name
  )

  argument_destroy = format("'%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'",
    var.aws_access_key, var.aws_secret_access_key, var.controller_private_ip, var.controller_region,
    var.copilot_public_ip, var.copilot_private_ip, var.private_mode, var.controller_sg_name
  )
}

resource "null_resource" "run_script" {
  triggers = {
    argument_destroy = local.argument_destroy
  }

  provisioner "local-exec" {
    command = "python3 -W ignore ${path.module}/aviatrix_copilot_simple_init.py ${local.argument_create}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "python3 -W ignore ${path.module}/clean_controller_sg.py ${self.triggers.argument_destroy}"
    on_failure = continue
  }
}
