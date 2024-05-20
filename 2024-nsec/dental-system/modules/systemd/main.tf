terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
  }
}

resource "incus_instance_file" "service" {
  instance    = var.container_name
  target_path = "/etc/systemd/system/${var.name}.service"
  mode        = "0644"
  content     = <<-EOF
    [Unit]
    Description=${var.name}
    ${join("\n", [for a in var.after : "After=${a}"])}

    [Service]
    Type=simple
    User=${var.user}
    Group=${var.group}
    ExecStart=${var.command}
    Restart=always
    WorkingDirectory=${var.working_directory}
    ${join("\n", [for k, v in var.environment : "Environment=\"${k}=${v}\""])}

    [Install]
    WantedBy=multi-user.target
  EOF
}

module "boot" {
  depends_on = [incus_instance_file.service]
  source         = "../exec"
  container_name = var.container_name
  remote         = var.remote
  command        = "systemctl enable ${var.name}.service"
}
