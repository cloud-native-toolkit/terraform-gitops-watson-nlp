locals {
  name          = "watson-nlp"
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  models = var.models

  values_content = {
    "componentName" = "-embedded"
    "acceptLicense" = var.accept_license
    "serviceType" = "ClusterIP"
    "registries" = var.registries
    "imagePullSecrets" = var.imagePullSecrets
    "runtime" = {
      "registry": var.runtime_registry
      "image": var.runtime_image
    }
    "models" = var.models
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

resource gitops_pull_secret imagePullSecrets {
  count = length(var.registryUserNames)
  name = var.imagePullSecrets[count.index]
  namespace = var.namespace
  server_name = var.server_name
  branch = local.application_branch
  layer = "infrastructure"
  credentials = yamlencode(var.git_credentials)
  config = yamlencode(var.gitops_config)
  kubeseal_cert = var.kubeseal_cert
  registry_server = var.registries[count.index].url
  registry_username = var.registryUserNames[count.index].userName
  registry_password = element(split(",", var.registry_credentials),count.index)
  secret_name = var.imagePullSecrets[count.index]
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource gitops_module setup_gitops {
  depends_on = [null_resource.create_yaml]

  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}