resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.51.6"

  values = [
    file("${path.module}/argocd-values.yaml")
  ]
}

resource "kubectl_manifest" "twentycrm_app" {
  depends_on = [helm_release.argocd]

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "twentycrm-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      sources = [
        {
          repoURL        = "https://amecea.github.io/helm-twentycrm"
          chart          = "twentycrm"
          targetRevision = "0.2.0"
          helm = {
            valueFiles = [
              "$values/app/values.yaml"
            ]
          }
        },
        {
          repoURL        = "https://github.com/NagothuNandini/terraform.git"
          targetRevision = "main"
          ref            = "values"
        }
      ]

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "twentycrm"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })
}


data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}
