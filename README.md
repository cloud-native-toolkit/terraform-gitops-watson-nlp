# terraform-gitops-watson-nlp Module
 
 | Verify  |  Metadata   |
 |--- | --- |
 |![Verify](https://github.com/cloud-native-toolkit/terraform-gitops-watson-nlp/actions/workflows/verify.yaml/badge.svg)|![Verify metadata](https://github.com/cloud-native-toolkit/terraform-gitops-watson-nlp/actions/workflows/verify-pr.yaml/badge.svg)|

## 1. Objective

This module deploys an IBM Watson NLP pod with a runtime container and multiple model containers to OpenShift clusters. The pod provides gRCP and REST interfaces to embed NLP (natural language processing) functionality in applications.

## 2. Example deployment

Refer to the [Watson Automation documentation](https://github.com/IBM/watson-automation) for instructions how to use the module.

Add the module to your BOM (bill of material) file:

```
spec:
  modules:
    ...
    - name: terraform-gitops-watson-nlp
      alias: terraform_gitops_watson_nlp
      version: v1.0.0
```

Configure the Watson NLP module in variables.yaml:

```
variables:
   ...

  # nlp
  - name: terraform_gitops_watson_nlp_runtime_image
    value: watson-nlp-runtime:1.0.0
  - name: terraform_gitops_watson_nlp_runtime_registry
    value: artifactory
  - name: terraform_gitops_watson_nlp_accept_license
    value: true
  - name: terraform_gitops_watson_nlp_imagePullSecrets
    value:
      - artifactory-key
  - name: terraform_gitops_watson_nlp_models
    value:
      - registry: artifactory
        image: watson-nlp_syntax_izumo_lang_en_stock:1.0.0
  - name: terraform_gitops_watson_nlp_registries
    value:
      - name: artifactory
        url: wcp-ai-foundation-team-docker-virtual.artifactory.swg-devops.com
  - name: terraform_gitops_watson_nlp_registryUserNames
    value:
      - registry: artifactory
        userName: xxx
```

## 3. Example usage

The following snippet shows how the BOM file and variables file are translated to and executed with Terraform.

```hcl-terraform
module "terraform_gitops_watson_nlp" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-watson-nlp?ref=v0.0.80"

  accept_license = var.terraform_gitops_watson_nlp_accept_license
  cluster_ingress_hostname = var.terraform_gitops_watson_nlp_cluster_ingress_hostname
  cluster_type = var.terraform_gitops_watson_nlp_cluster_type
  enable_sso = var.terraform_gitops_watson_nlp_enable_sso
  git_credentials = module.gitops_repo.git_credentials
  gitops_config = module.gitops_repo.gitops_config
  imagePullSecrets = var.terraform_gitops_watson_nlp_imagePullSecrets == null ? null : jsondecode(var.terraform_gitops_watson_nlp_imagePullSecrets)
  kubeseal_cert = module.gitops_repo.sealed_secrets_cert
  models = var.terraform_gitops_watson_nlp_models == null ? null : jsondecode(var.terraform_gitops_watson_nlp_models)
  namespace = module.namespace.name
  registries = var.terraform_gitops_watson_nlp_registries == null ? null : jsondecode(var.terraform_gitops_watson_nlp_registries)
  registry_credentials = var.terraform_gitops_watson_nlp_registry_credentials
  registryUserNames = var.terraform_gitops_watson_nlp_registryUserNames == null ? null : jsondecode(var.terraform_gitops_watson_nlp_registryUserNames)
  runtime_image = var.terraform_gitops_watson_nlp_runtime_image
  runtime_registry = var.terraform_gitops_watson_nlp_runtime_registry
  server_name = module.gitops_repo.server_name
  tls_secret_name = var.terraform_gitops_watson_nlp_tls_secret_name
}
```
