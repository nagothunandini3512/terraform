resource "helm_release" "twentycrm" {

  name             = "twenty-crm"
  repository       = "https://amecea.github.io/helm-twentycrm"
  chart            = "twentycrm"
  namespace        = "twentycrm"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  wait    = true
  atomic  = true
  timeout = 900
}
