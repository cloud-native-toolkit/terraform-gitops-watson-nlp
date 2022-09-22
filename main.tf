locals {
  name          = "watson-nlp"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  #yaml_dir      = "${path.cwd}/.tmp/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  cluster_type = var.cluster_type == "kubernetes" ? "kubernetes" : "openshift"

  models = var.models


  values_content = {
    test = {
      "componentName" = "watson-nlp"
      "serviceType" = "ClusterIP"
      "registries" = var.registries
      "imagePullSecrets" = var.imagePullSecrets
      "runtime" = {
        "registry": var.runtime_registry
        "image": var.runtime_image
      }
      "models" = var.models
    }
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

#module gitops {
#  source = "github.com/cloud-native-toolkit/terraform-tools-gitops.git"
#}

#credMap = var.registry_credentials
#credMapStr = tostring(credMap)

credentialsList = split(",", var.registry_credentials)

module "gitops_pull_secret" {
#   depends_on = [module.gitops]
   source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret.git"
   count = length(var.registryUserNames)
   gitops_config = var.gitops_config
   git_credentials = var.git_credentials
   server_name = var.server_name
   namespace = var.namespace
   kubeseal_cert = var.kubeseal_cert
   docker_server = var.registries[count.index].url
   docker_username = var.registryUserNames[count.index].userName
   docker_password = credentialsList[count.index]
   secret_name = var.imagePullSecrets[count.index]
}



module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
