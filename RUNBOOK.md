# TwentyCRM Deployment Runbook


**Infrastructure repo:** https://github.com/nagothunandini3512/terraform.git

---

## 1. Prerequisites

Before deploying, make sure you have the following in place.

### 1.1 Accounts & Access
- An AWS account with permissions to create VPCs, IAM roles, EKS clusters, and load balancers.
- Access to the Helm chart repository containing the `twentycrm` Helm chart.
- Access to the GitHub repository containing the environment-specific `values.yaml` files: https://github.com/nagothunandini3512/terraform.git
- kubeconfig / cluster access to the target EKS cluster (or permission to generate one via AWS CLI once the cluster exists).

### 1.2 Tools (install locally or ensure available in CI runner)
| Tool | Purpose |
|---|---|
| Terraform | Provisions AWS infrastructure (VPC, EKS, IAM, node groups) |
| kubectl | Interact with the Kubernetes cluster |
| Helm | Renders/inspects the TwentyCRM Helm chart |
| AWS CLI | Authenticates to AWS, updates kubeconfig |

> **Note on ownership:** `terraform apply` and the ArgoCD `Application` CRD creation are both handled by the CI/CD pipeline in the Terraform repo — not run manually. The tools above are still needed locally for inspection, debugging, and emergency break-glass actions, but day-to-day deploys go through the pipeline, not your terminal.

### 1.3 Infrastructure Prerequisites (provisioned by Terraform)
- VPC with public and private subnets
- NAT Gateway
- Security Groups
- IAM Roles (including IRSA roles for in-cluster controllers)
- Amazon EKS Cluster with managed node groups
- Internet connectivity from the cluster to pull container images and Helm charts
- ArgoCD installed on the EKS cluster (GitOps controller)

---

## 2. Step-by-Step Deployment Instructions

```bash
cd <req-environment for example dev, staging, production>
terraform init
terraform plan -out=tfplan
terraform apply
```

The deployment follows a GitOps model: Terraform provisions infrastructure once, then ArgoCD takes over continuous delivery of the application from Git.

### Step 1 — Provision Infrastructure (via CI/CD)
Infrastructure is **not applied manually**. A CI/CD pipeline (triggered on push/merge to the Terraform repo) runs `terraform init`, `terraform plan`, and `terraform apply` automatically.

Check the pipeline logs  to confirm `apply` succeeded.

This provisions (including the ArgoCD install and ArgoCD `Application` resources — see Step 3):
- VPC, public/private subnets, NAT Gateway
- Security Groups
- IAM Roles
- Amazon EKS Cluster + managed node groups
- ArgoCD installation
- ArgoCD `Application` CRD(s)

> **Manual `terraform apply` is only for break-glass/emergency use** (e.g. CI/CD is down at 2am and you must act now). If you do run it manually, immediately follow up by re-running it through the pipeline once it's back up, so pipeline state and actual cluster state don't drift apart. Always check `terraform plan` output carefully before an emergency manual apply — you're bypassing whatever safety checks the pipeline normally runs.

Once the pipeline reports success, update your local kubeconfig to inspect the cluster:
```bash
aws eks update-kubeconfig --name <cluster-name> --region <aws-region>
kubectl get nodes   # sanity check
```

### Step 2 — Install ArgoCD on the EKS Cluster(via Terraform)
ArgoCD is the GitOps controller: it continuously watches Git repositories and keeps the cluster in sync with the desired state. Confirm it's running:
```bash
kubectl get pods -n argocd
```

### Step 3 — ArgoCD Application (created via Terraform, not manually)
The ArgoCD `Application` CRD is **not created manually** through the ArgoCD UI/CLI. It is defined as a Terraform resource in the same Terraform repo and applied by the CI/CD pipeline along with the rest of the infrastructure (Step 1).

The Terraform-managed `Application` resource references:
- Helm Repository URL
- Helm Chart Name: `twentycrm`
- Helm Chart Version
- The GitHub repo containing `values.yaml` as an **additional source**

So Steps 3 and 4 from the original manual process happen automatically the moment the pipeline applies the Terraform config — there is nothing to do by manually here. If you need to change the chart version, repo URL, or values source, edit the relevant `.tf` file (e.g. the `modules/argocd/argocd_application` resource block) in the Terraform repo and push — the pipeline re-applies it.

### Step 4 — Custom Values (managed via Git, applied automatically)
Once the Application resource exists (from Step 3), ArgoCD itself automatically:
1. Downloads the Helm chart from the Helm repository.
2. Retrieves the environment-specific `values.yaml` from GitHub.
3. Combines both during Helm rendering (`helm template chart -f values.yaml`).

This part **is** still GitOps-driven by ArgoCD (not Terraform) — meaning day-to-day config changes (image tags, replicas, resource limits, etc.) should be made by editing `values.yaml` in Git and letting ArgoCD auto-sync, **not** by re-running Terraform. Terraform only owns the *existence and shape* of the Application resource itself, not its runtime config values.

### Step 5 — Deploy the Application
Sync the ArgoCD Application (via UI, CLI, or auto-sync policy):
```bash
argocd app sync twentycrm-<env>
```
ArgoCD will:
- Render Helm templates with the supplied `values.yaml`
- Generate Kubernetes manifests
- Apply them to the EKS cluster, creating: Deployments, Services, ConfigMaps, Secrets, Ingress, PVCs

The application is considered up once all pods reach `Running` state.

### Step 6 — Continuous GitOps Sync
After initial deployment, ArgoCD continuously watches `values.yaml` repo. Any change pushed to Git — image tag bumps, replica count changes, resource limit changes, env var updates, ingress changes — is automatically detected and synced to the cluster. **No manual `kubectl apply` is needed for routine changes; push to Git instead.**

---

## 3. Deploying to Different Environments (Dev / Staging / Production)

All environments follow the identical GitOps workflow above. The only difference is the infrastructure (separate EKS cluster per environment) and which values file is referenced.

| Environment | Helm Chart | Values File |
|---|---|---|
| Development | TwentyCRM | `values-dev.yaml` |
| Staging | TwentyCRM | `values-staging.yaml` |
| Production | TwentyCRM | `values-prod.yaml` |

Process per environment:
1. Terraform provisions a **dedicated EKS cluster** for that environment (from the Terraform repo, typically using an environment-specific `.tfvars` or workspace — check the repo for the exact variable naming before applying).
2. ArgoCD is installed on that cluster.
3. A separate ArgoCD Application is created for that environment.
4. The Application references the same TwentyCRM Helm chart but points at concerned environment's values file (`Dev-values.yaml`, `Staging-values.yaml`, `Production-values.yaml`).

---

## 4. Verifying the Deployment

### 4.1 Access the Application
Terraform outputs the Application Load Balancer (ALB) URL after apply. Open it in a browser.
- TwentyCRM login page loads → deployment successful.

### 4.2 Verify via ArgoCD Dashboard
Terraform also outputs the ArgoCD Load Balancer URL. Log in with the initial admin credentials (from the Kubernetes secret):
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
Confirm:
- Application status = **Healthy**
- Sync status = **Synced**
- No resources in **OutOfSync** or **Degraded** state

If a resource failed, ArgoCD's UI shows the specific error and the affected Kubernetes object — start there.

### 4.3 Verify Kubernetes Resources Directly
```bash
kubectl get pods -n <namespace>
kubectl get svc -n <namespace>
kubectl get ingress -n <namespace>
kubectl get pvc -n <namespace>
```
Check that:
- All pods are `Running`
- Services exist and have correct selectors/ports
- Ingress has an external address assigned
- PVCs are `Bound`

---

## 5. Rollback Procedure

Because this is a GitOps deployment, **rollback is done through Git, not kubectl.**

### Preferred method — revert in Git
1. Identify the last known-good commit for `values.yaml` (or the Helm chart version) in the config repo.
2. `git revert` (or manually restore) the change and push to the branch ArgoCD tracks.
3. ArgoCD detects the reverted state and automatically re-syncs the cluster to match — no manual intervention needed.

### Alternative — ArgoCD Application History
If a fast rollback is needed and there isn't time to raise/merge a Git revert:
```bash
argocd app history twentycrm-<env>
argocd app rollback twentycrm-<env> <revision-id>
```
This deploys a previously successful revision directly from ArgoCD's history.

> Note: an ArgoCD-history rollback is a stopgap. Follow up with a proper Git revert afterward so the repository state matches what's actually running — otherwise the next auto-sync will silently re-apply the bad config.

---

## 6. Common Issues & Troubleshooting

| Symptom | Likely Cause | How to Confirm | Fix |
|---|---|---|---|
| No ALB created / Ingress has no address | Incorrect `IngressClass` | `kubectl describe ingress -n <namespace>`; check AWS Load Balancer Controller logs (`kubectl logs -n kube-system deploy/aws-load-balancer-controller`) | Correct the `ingressClassName` in `values.yaml`, push fix, let ArgoCD sync |
| PVC stuck in `Pending` | Missing or incorrect `StorageClass` | `kubectl get pvc -n <namespace>` and `kubectl get storageclass` | Set the correct StorageClass in `values.yaml`; ensure it exists on the cluster |
| AWS Load Balancer Controller (or other pod) can't reach AWS APIs | Incorrect IRSA (IAM Roles for Service Accounts) setup | Check ServiceAccount annotations (`kubectl describe sa <name> -n <namespace>`), IAM role trust policy, and attached IAM policies | Fix the trust relationship / role annotation in Terraform, re-apply |
| App unreachable after "successful" deploy | Could be networking, app config, or runtime error | Check, in order: ALB URL/target health → ArgoCD app status → `kubectl get svc,endpoints -n <namespace>` → pod logs (`kubectl logs <pod> -n <namespace>`) | Narrow down by layer before changing anything |

### General triage order (use this at 2am)
1. `argocd app get twentycrm-<env>` — is it Synced/Healthy?
2. `kubectl get pods -n <namespace>` — are pods Running or crash-looping?
3. `kubectl describe pod <pod> -n <namespace>` and `kubectl logs <pod> -n <namespace>` — what's the actual error?
4. `kubectl get ingress,svc,endpoints -n <namespace>` — is traffic routing correctly?
5. If none of the above shows the issue, check IAM/IRSA and Security Groups (most "mystery" failures in this stack are permissions or networking, not application code).

---

## Quick Reference

```bash
# Provision infra + ArgoCD Application CRD (all via Terraform)
# -> Do NOT run terraform apply manually in normal operation.
# -> Push/merge to the Terraform repo and let CI/CD apply it.
git push origin <branch>   # then merge PR -> pipeline runs terraform apply

# Point kubectl at the right cluster (for inspection only)
aws eks update-kubeconfig --name <cluster-name> --region <region>

# App-level config changes (image tag, replicas, resources, etc.)
# -> edit values-<env>.yaml in Git, push -> ArgoCD auto-syncs
# -> do NOT edit these via kubectl or Terraform

# Check health
argocd app get twentycrm-<env>
kubectl get pods,svc,ingress,pvc -n <namespace>

# Rollback (emergency, use with Git follow-up)
argocd app rollback twentycrm-<env> <revision-id>

# Emergency-only manual apply (CI/CD down) — follow up with pipeline re-run after
terraform plan   # review carefully first
terraform apply
```

**Repo for Terraform and environment configs:** https://github.com/nagothunandini3512/terraform.git
