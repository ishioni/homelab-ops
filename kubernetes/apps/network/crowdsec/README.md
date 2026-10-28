# CrowdSec

This first stage deploys CrowdSec and the Envoy bouncer without an Envoy Gateway `SecurityPolicy`. It does not block public requests. The agent reads public Envoy pod logs through the Kubernetes API; its namespaced role can read logs from any pod in `network`, although acquisition is restricted to the public Envoy selector.

## Prerequisite

Create a `crowdsec` item in the `onepassword` secret store with three independently generated strong secrets before merging:

- `CROWDSEC_BOUNCER_KEY`: shared by LAPI and the Envoy bouncer.
- `CROWDSEC_POSTGRES_PASSWORD`: the dedicated PostgreSQL application user's password.
- `CROWDSEC_LAPI_PASSWORD`: the local `cscli` LAPI user's password.

External Secrets supplies the database password to both the `database` and `network` namespaces and creates the LAPI and bouncer credentials. Do not put secrets in Git. The PostgreSQL cluster and Helm releases cannot become ready without them. Key rotation must be coordinated with the bouncer registration persisted in PostgreSQL; updating the secret alone may not replace an existing registered key. The chart's CAPI registration hook also creates a Kubernetes Secret; back up the database and these credentials and test recovery together.

A dedicated three-instance CloudNativePG cluster stores its data on `openebs-hostpath`, archives WAL to the existing `rustfs` object store, and runs daily backups. LAPI uses PostgreSQL and has no data or configuration PVC; its configuration is supplied through chart-generated ConfigMaps and Secrets. One LAPI replica remains a single point of failure. Database PVCs are node-local, so recovery still depends on healthy replicas and tested backups. LAPI uses TLS to PostgreSQL with `sslmode: require` (encryption without certificate identity verification). CrowdSec's online community API is enabled and the agent downloads its collection from the CrowdSec Hub; Console enrollment and AppSec are not configured.

The ingress policies allow the agent and bouncer to connect to LAPI, public Envoy to the bouncer, Prometheus to metrics, and node-origin traffic to probe ports. Outbound traffic is not restricted. Kubernetes API access is limited by the agent's Role, not by an egress network policy.

## Before enabling enforcement

1. Check that both Helm releases, the ExternalSecret, and the Cilium policies are healthy; confirm the agent acquires and parses public Envoy logs and the bouncer connects to LAPI.
2. Attach a temporary fail-open Envoy Gateway `SecurityPolicy` to a test HTTPRoute, not the whole Gateway. Ensure the ext-auth gRPC request contains Envoy's `X-Envoy-External-Address`; the bouncer trusts that header and falls back to XFF if it is absent.
3. From a controlled, non-exempt client address, add a temporary LAPI ban decision and verify that requests are denied, including requests with spoofed `X-Forwarded-For` and `X-Envoy-External-Address` headers. Remove the decision and verify access returns. `10.1.0.0/16` and `172.16.0.0/16` are exempt from bouncer evaluation.
4. Test bouncer unavailability and recovery, then decide whether to apply a fail-open `SecurityPolicy` to `envoy-external`. Do not target `envoy-internal`. Re-check address ranges and whether internal clients should be exempt before enabling enforcement.
