locals {
  container_name = var.remote == null ? var.container_name : "${var.remote}:${var.container_name}"
}

resource "null_resource" "exec" {
  triggers = {
    remote         = var.remote
    container_name = var.container_name
    command        = var.command
    condition      = var.condition
    nonce          = var.nonce
  }

  provisioner "local-exec" {
    interpreter = flatten([
      "incus", "exec", local.container_name,
      "--env", "EXEC_COND=${var.condition}",
      "--env", "EXEC_CMD=${var.command}",
      var.uid != null ? ["--user", var.uid] : [],
      var.gid != null ? ["--group", var.gid] : [],
      var.cwd != null ? ["--cwd", var.cwd] : [],
      [for k, v in var.environment : ["--env", "${k}=${v}"]],
      "--",
      "sh", "-c"
    ])

    command = "sh -c \"$EXEC_COND\" || sh -c \"$EXEC_CMD\""
  }
}
