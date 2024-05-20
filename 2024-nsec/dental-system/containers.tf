terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
    }
  }
}

provider "incus" {}

resource "incus_network" "kv" {
  name = "bcj-kv"

  config = {
    "ipv4.address" = "none"
    "ipv6.address" = "9000:b3c0:7010::1/64"
  }
}

resource "incus_instance" "kv" {
  name             = "ctn-bcotejodoin-kv"
  image            = "images:ubuntu/jammy"
  wait_for_network = true

  config = {
    "security.protection.delete" = "true"
  }

  lifecycle {
    ignore_changes = [image]
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      name    = "eth0"
      network = incus_network.kv.name
    }
  }
}

module "opa_service" {
  source         = "./modules/systemd"
  container_name = incus_instance.kv.name
  name           = "opa"
  command        = "${incus_instance_file.opa.target_path} run --server --addr 127.0.0.1:8181 ${incus_instance_file.opa_bundle.target_path}"
  environment = {
    "FLAG" = "FLAG-04162f91789c87849771c60e3fdc16bd"
  }
}

module "traefik_service" {
  source         = "./modules/systemd"
  container_name = incus_instance.kv.name
  name           = "traefik"
  after          = ["redis-server.service"]
  command        = "${incus_instance_file.traefik.target_path} --configFile=${incus_instance_file.traefik_config.target_path}"
  environment    = {}
}

module "app_service" {
  source         = "./modules/systemd"
  container_name = incus_instance.kv.name
  name           = "app"
  after          = ["redis-server.service"]
  command        = "/usr/bin/bun ${incus_instance_file.app_js.target_path}"
  environment = {
    container  = "lxc"
    FLAG       = "FLAG-2fc6c690e95b6e7cc4d0373b99256ab9"
    REDIS_FLAG = "FLAG-b408c2d105e63ee28e2f90d6b396652c"
    ADMIN_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiJ9.xAHWTQ9r8rfa-ekvh-PAYRSVYjiKMmkxPEnUSGsEABU"
  }
}


resource "null_resource" "download_traefik" {
  provisioner "local-exec" {
    interpreter = ["sh", "-ec"]
    command     = <<-EOF
      if [ ! -f ${path.module}/tmp/traefik.tar.gz ]; then
        wget -qO ${path.module}/tmp/traefik.tar.gz https://github.com/traefik/traefik/releases/download/v2.10.7/traefik_v2.10.7_linux_amd64.tar.gz
      fi

      if [ ! -f ${path.module}/tmp/traefik ]; then
        tar -xvf ${path.module}/tmp/traefik.tar.gz
      fi
    EOF
  }
}

resource "incus_instance_file" "traefik" {
  depends_on = [null_resource.download_traefik]

  instance    = incus_instance.kv.name
  target_path = "/usr/bin/traefik"
  source_path = "${path.module}/tmp/traefik"
  mode        = "0755"
}

resource "null_resource" "download_opa" {
  provisioner "local-exec" {
    interpreter = ["sh", "-ec"]
    command     = <<-EOF
      if [ ! -f ${path.module}/tmp/opa ]; then
        wget -qO ${path.module}/tmp/opa https://github.com/open-policy-agent/opa/releases/download/v0.60.0/opa_linux_amd64_static
      fi
    EOF
  }
}

resource "null_resource" "download_bun" {
  provisioner "local-exec" {
    interpreter = ["sh", "-ec"]
    command     = <<-EOF
      if [ ! -f ${path.module}/tmp/bun ]; then
        docker run --platform=linux/amd64 --rm -v ${path.module}/tmp:/src -w /src oven/bun:latest@sha256:2b283192796dfa02fc2f0f9f3749b4f64ef53bc0a4c7006f3816b7011bcecb0e cp /usr/local/bin/bun /src/bun
      fi
    EOF
  }
}

resource "incus_instance_file" "bun" {
  depends_on = [null_resource.download_bun]

  instance    = incus_instance.kv.name
  target_path = "/usr/bin/bun"
  source_path = "${path.module}/tmp/bun"
  mode        = "0755"
}

resource "incus_instance_file" "opa" {
  depends_on = [null_resource.download_opa]

  instance    = incus_instance.kv.name
  target_path = "/usr/bin/opa"
  source_path = "${path.module}/tmp/opa"
  mode        = "0755"
}

resource "incus_instance_file" "traefik_config" {
  instance    = incus_instance.kv.name
  target_path = "/etc/traefik.yml"
  source_path = "${path.module}/traefik.yml"
  mode        = "0644"
}

module "apt" {
  source = "./modules/exec"

  container_name = incus_instance.kv.name
  command        = "apt-get install -y redis-server"
}

resource "incus_instance_file" "app_js" {
  instance    = incus_instance.kv.name
  target_path = "/app.js"
  source_path = "${path.module}/app/app.js"
  mode        = "0644"
}

resource "incus_instance_file" "opa_bundle" {
  instance    = incus_instance.kv.name
  target_path = "/bundle.tar.gz"
  source_path = "${path.module}/bundle.tar.gz"
  mode        = "0644"
}

resource "incus_instance_file" "redis_conf" {
  depends_on = [module.apt]
  instance    = incus_instance.kv.name
  target_path = "/etc/redis/redis.conf"
  source_path = "${path.module}/redis.conf"
  mode        = "0640"

  lifecycle {
    ignore_changes = [gid, uid]
  }
}
