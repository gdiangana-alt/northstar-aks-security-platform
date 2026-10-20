# Security Validation Results

Validated on 2026-10-20 in Canada Central.

## Platform controls

- AKS uses Microsoft Entra ID authentication, Azure RBAC, workload identity, Azure Policy, and Cilium network policy.
- AKS API access and Key Vault network access are limited to approved IP ranges.
- Key Vault uses RBAC authorization and denies network access by default.
- The AKS kubelet identity has `AcrPull` on the platform container registry.

## Workload identity and secrets

A `workloads/secret-reader` workload used federated workload identity with the Secrets Store CSI driver to mount `aks-demo-secret` from Azure Key Vault. The mounted value was read successfully.

## Admission policy

Azure Policy and Gatekeeper denied a privileged container in the `workloads` namespace during a server-side dry run:

`Privileged container is not allowed`

## Cilium network policy

The `cilium-egress-probe` workload was restricted by `probe-dns-only`.

- DNS lookup of `kubernetes.default.svc.cluster.local` succeeded.
- HTTP access to `http://1.1.1.1` timed out.

This confirms that the policy permits cluster DNS while blocking external egress for the probe workload.

## Lab constraint

This validation cluster has one system node. The validation workloads include a temporary `CriticalAddonsOnly` toleration. A production deployment should use a separate user node pool for application workloads.
