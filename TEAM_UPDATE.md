# TEAM_UPDATE.md

> Slack message to post in `#eng-deploys` (cross-post to `#product` / `#support` if launching customer-facing changes)

---

📢 **TwentyCRM Deployment — [Dev/Staging/Prod]**

**What & why:**
Deploying TwentyCRM to our EKS cluster(s) via Terraform + ArgoCD (GitOps). This gives us automated, auditable infra provisioning and continuous sync of app config from Git — no more manual `kubectl apply`.

**🔧 Key changes / impact:**
- Infra (VPC, EKS, IAM, node groups) and the ArgoCD `Application` resource are now fully Terraform-managed
- App config (image tags, replicas, resources, ingress) lives in `values-<env>.yaml` and auto-syncs via ArgoCD — **all future app changes go through Git, not manual commands**
- `terraform apply` now runs via CI/CD pipeline on merge, not manually from local machines
- No expected downtime — rolling deploy, pods replaced gradually

**🗓 Timeline:**
| Env | Window | Notes |
|---|---|---|
| Dev | *[date/time]* | Already validated / validating now |
| Staging | *[date/time]* | Pending dev sign-off |
| Prod | *[date/time]* | Pending staging sign-off + change approval |

**🔗 Links:**
- PR: *[link to Terraform repo PR]*
- Runbook: `RUNBOOK.md` — *[link]*
- Terraform repo: https://github.com/nagothunandini3512/terraform.git
- ArgoCD dashboard: *[link]*
- Monitoring / dashboards: *[link — Grafana/CloudWatch/etc.]*
- Architecture doc: *[link, if available]*

**⚠️ Risks / things to watch:**
- First rollout of the CI/CD-driven Terraform apply for this app — flagging in case pipeline behaves unexpectedly
- IRSA / IngressClass misconfig is the most common failure mode for this stack (see runbook § Troubleshooting) — watch for ALB provisioning issues post-deploy
- Rollback is Git-revert based (not instant) — ArgoCD history rollback available as a faster stopgap if needed

**🙋 Who to contact if something breaks:**
- Primary: *[your name / @handle]*
- Backup / on-call: *[name or on-call rotation link]*
- Escalation: *[team channel, e.g. #eng-oncall]*

_Full step-by-step deploy, verification, and rollback details are in `RUNBOOK.md`. Ping me with questions before/after the window._
