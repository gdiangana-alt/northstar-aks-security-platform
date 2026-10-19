# NorthStar AKS Security Platform

An Azure Kubernetes security implementation in Canada Central that demonstrates secure platform foundations, workload identity, secrets delivery, policy enforcement, controlled deployment, and operational evidence.

## Security objectives

- Use Microsoft Entra ID integration and Azure RBAC for AKS access.
- Use workload identity so applications avoid stored cloud credentials.
- Deliver secrets from Azure Key Vault through the Secrets Store CSI driver.
- Enforce a restricted workload baseline with Azure Policy.
- Restrict network exposure and define explicit traffic paths.
- Use Terraform, GitHub Actions validation, and evidence-driven operational checks.

## Delivery boundary

- Region: Canada Central
- One small AKS system node only during active validation.
- No production data, customer data, or long-lived application secrets.
- Deployment occurs only after Terraform review and a cost budget is in place.
- Teardown is part of the completion criteria.

## Planned evidence

- Architecture and threat model
- Terraform plan and validated deployment outputs
- Policy denial evidence for a non-compliant workload
- Workload identity and Key Vault secret-access evidence
- Network and operational validation results
- Teardown confirmation and cost-control record

## Repository layout

- `docs/` — architecture, threat model, implementation notes, and evidence
- `terraform/` — Azure infrastructure as code
- `.github/workflows/` — validation and quality checks
- `scripts/` — repeatable validation and teardown helpers
