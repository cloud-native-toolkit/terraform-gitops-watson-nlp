
resource local_file write_outputs {
  filename = "gitops-output.json"

  content = jsonencode({
    name        = module.gitops_watson-nlp.name
    branch      = module.gitops_watson-nlp.branch
    namespace   = module.gitops_watson-nlp.namespace
    server_name = module.gitops_watson-nlp.server_name
    layer       = module.gitops_watson-nlp.layer
    layer_dir   = module.gitops_watson-nlp.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_watson-nlp.layer == "services" ? "2-services" : "3-applications")
    type        = module.gitops_watson-nlp.type
  })
}