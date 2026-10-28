# CrowdSec

CrowdSec reads public Envoy logs and enforces decisions using a fail-open `SecurityPolicy` on `envoy-external`. Route-level security policies take precedence over the Gateway policy: routes protected by Authentik retain their authentication but do not use the CrowdSec bouncer. Check the Gateway policy's `Overridden` condition for affected routes. The agent reads public Envoy pod logs through the Kubernetes API; its namespaced role can read logs from any pod in `network`, although acquisition is restricted to the public Envoy selector.

## Prerequisite

Create a `crowdsec` item in the `onepassword` secret store with three independently generated strong secrets before merging:

- `BOUNCER_KEY`: shared by LAPI and the Envoy bouncer.
- `POSTGRES_PASS`: the dedicated PostgreSQL application user's password.
- `LAPI_PASSWORD`: the local `cscli` LAPI user's password.

External Secrets supplies the database password to both the `database` and `network` namespaces and creates the LAPI and bouncer credentials. Do not put secrets in Git. The PostgreSQL cluster and Helm releases cannot become ready without them. Key rotation must be coordinated with the bouncer registration persisted in PostgreSQL; updating the secret alone may not replace an existing registered key. The chart's CAPI registration hook also creates a Kubernetes Secret; back up the database and these credentials and test recovery together.

A dedicated three-instance CloudNativePG cluster stores its data on `openebs-hostpath`, archives WAL to the existing `rustfs` object store, and runs daily backups. LAPI uses PostgreSQL and has no data or configuration PVC; its configuration is supplied through chart-generated ConfigMaps and Secrets. One LAPI replica remains a single point of failure. Database PVCs are node-local, so recovery still depends on healthy replicas and tested backups. LAPI uses TLS to PostgreSQL with `sslmode: require` (encryption without certificate identity verification). CrowdSec's online community API is enabled and the agent downloads its collection from the CrowdSec Hub; Console enrollment and AppSec are not configured.

No CrowdSec-specific network policies are included in this initial deployment. LAPI and the bouncer are ClusterIP services but remain reachable from cluster workloads unless existing cluster policies restrict them. Kubernetes API access is limited by the agent's Role. Add and test Cilium policies separately after verifying the required traffic paths.

## Follow-up validation

1. Check the Helm releases and ExternalSecrets, agent acquisition and parser metrics, and the bouncer's LAPI connection.
2. From a controlled, non-exempt client address, add a temporary LAPI ban decision and verify that an unprotected test route is denied, including requests with spoofed `X-Forwarded-For` and `X-Envoy-External-Address` headers. Remove the decision and verify access returns. The bouncer trusts Envoy's `X-Envoy-External-Address` and falls back to XFF if it is absent. `10.1.0.0/16` and `172.16.0.0/16` are exempt from bouncer evaluation.
3. Test bouncer unavailability and recovery, and verify Authentik redirects and authenticated requests continue to work. Coverage of Authentik-protected routes requires a separate solution; do not replace their route policies with CrowdSec.
