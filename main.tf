locals {
  name          = "watson-nlp"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  #yaml_dir      = "${path.cwd}/.tmp/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  cluster_type = var.cluster_type == "kubernetes" ? "kubernetes" : "openshift"
  values_content = {
    watson-nlp = {
      "serviceType" = "ClusterIP"
      "components.abcRuntime.name" = "product-runtime"
      "imagePullSecrets" = [{"name" = "artifactory-key"}, {"name" = "deleeuw-icr-pull-secret"}]
      "containerRegistry" = "uk.icr.io/deleeuw-product-abc"
      "images.product-abc-container.repository" = "product-abc-container"
      "images.product-abc-container.tag" = "v1"
      "models" = [{"model1" = "", "name" = "model1", "image" = "wcp-ai-foundation-team-docker-virtual.artifactory.swg-devops.com/watson-nlp_ensemble_classification-wf_lang_en_emotion-stock:1.23.0"}, {"model2" = "", "name" = "model2", "image" = "wcp-ai-foundation-team-docker-virtual.artifactory.swg-devops.com/watson-nlp_ensemble_classification-wf_lang_en_dummy:1.12.0"}]
    }
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
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
