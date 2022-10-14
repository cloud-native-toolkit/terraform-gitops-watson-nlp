# terraform-gitops-watson-nlp Module
 
 | Verify  |  Metadata   |
 |--- | --- |
 |![Verify](https://github.com/cloud-native-toolkit/terraform-gitops-watson-nlp/actions/workflows/verify.yaml/badge.svg)|![Verify metadata](https://github.com/cloud-native-toolkit/terraform-gitops-watson-nlp/actions/workflows/verify-pr.yaml/badge.svg)|

## 1. Objective

This module deploys the container images required to provide embedded Watson NLP libraries which can be called from another application. 

At a minimum a Watson NLP runtime image is required. The NLP runtime container runs in the Watson NLP pod at runtime. Additional `model images' are necessary for different functionality provided by Watson NLP. There are two types of model images:

* Stock models provided by IBM
* Custom models provided by consumers

The model containers run as Kubernetes initContainers. They are triggered when pods are created. Their purpose is to put the model artifacts onto pod storage so that the Watson NLP runtime container can access them. Once they have done this, these containers terminate.

## 2. Example deployment

Refer to the [Watson Automation documentation](https://github.com/IBM/watson-automation) for sample Bill of Material files and full instructions.

## 3. Example usage

Module input variables:

TBD

```hcl-terraform
module "terraform-gitops-watson-nlp" {
   source = "TBD/terraform-gitops-watson-nlp.git"
   
   gitops_config = module.gitops.gitops_config
   git_credentials = module.gitops.git_credentials
   server_name = module.gitops.server_name
   namespace = module.gitops_namespace.name
   kubeseal_cert = module.gitops.sealed_secrets_cert
   server_name = module.server_name.server_name
   enable_sso = 
   tls_secret_name =
   cluster_ingress_hostname =
   cluster_type = 
   runtime_registry = 
   runtime_image = 
   models = 
   imagePullSecrets = 
   registries = 
   registryUserNames = 
   registry_credentials = 
}
```
Test
