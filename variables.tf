
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "enable_sso" {
  type        = bool
  description = "Flag indicating if oauth should be applied (only available for OpenShift)"
  default     = true
}

variable "tls_secret_name" {
  description = "The name of the secret containing the tls certificate values"
  default     = ""
}

variable "cluster_ingress_hostname" {
  type        = string
  description = "Ingress hostname of the cluster."
  default     = ""
}

variable "cluster_type" {
  description = "The cluster type (openshift or kubernetes)"
  default     = "openshift"
}

variable "runtime_registry" {
  description = "runtime_registry"
  default     = "wcp-ai-foundation-team-docker-virtual.artifactory.swg-devops.com"
}

variable "runtime_image" {
  description = "runtime_image"
  default     = "watson-nlp-runtime:0.16.0_ubi8_py39"
}

variable "models" {
  type    = list(map(string))
  default = []
}

variable "imagePullSecrets" {
  type    = list(string)
  default = []
}

variable "registries" {
  type    = list(map(string))
  default = []
}

variable "registryUserNames" {
  type    = list(map(string))
  default = []
}
