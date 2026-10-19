# Architecture

## Components

| Component | Security role |
| --- | --- |
| AKS | Managed Kubernetes control plane with Entra ID and Azure RBAC |
| System node pool | One Standard_B2s node during validation; autoscaling constrained |
| Azure Container Registry | Private image registry with AKS pull access |
| Azure Key Vault | RBAC-controlled secret store; no secret values committed to Git |
| Workload identity | Federated application identity for Key Vault access |
| Azure Policy add-on | Cluster admission and compliance integration |
| Kubernetes Pod Security Admission | Restricted workload namespace baseline |
| Azure Monitor | Control-plane and workload operational visibility |

## Security flow

1. An operator authenticates with Microsoft Entra ID and receives Azure RBAC permissions.
2. Terraform creates the resource boundary, AKS, registry, Key Vault, identities, and monitoring controls.
3. AKS receives images from the private registry using managed identity.
4. A Kubernetes service account federates to a user-assigned managed identity.
5. The workload reads an allowed Key Vault secret at runtime through the CSI driver.
6. Restricted Pod Security Admission rejects a deliberately non-compliant workload.

## Cost boundary

The validation deployment uses one small node and a monthly Azure cost budget. Resources are removed after evidence collection.
