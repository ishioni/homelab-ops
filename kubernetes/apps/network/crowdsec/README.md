# CrowdSec

This first stage deploys CrowdSec and the Envoy bouncer without an Envoy Gateway `SecurityPolicy`. It does not block public requests. The agent reads public Envoy pod logs through the Kubernetes API; its namespaced role can read logs from any pod in `network`, although acquisition is restricted to the public Envoy selector.

## Prerequisite

Create a `crowdsec` item in the `onepassword` secret store with a strong, randomly generated `CROWDSEC_BOUNCER_KEY` field before merging. External Secrets writes the same key to `crowdsec-secret` for both LAPI registration and the bouncer. Do not put the key in Git. The Helm releases will not become ready without this secret. Key rotation must also be coordinated with the bouncer registration persisted in the LAPI database; updating the secret alone may not replace an existing registered key.

LAPI stores its SQLite database and configuration on two `openebs-hostpath` PVCs. These are node-local: a node failure can leave LAPI unavailable until the volumes are recovered or recreated. Include the data in your backup and recovery plan. CrowdSec's online community API is enabled and the agent downloads its collection from the CrowdSec Hub; Console enrollment and AppSec are not configured.

The ingress policies allow the agent and bouncer to connect to LAPI, public Envoy to the bouncer, Prometheus to metrics, and node-origin traffic to probe ports. Outbound traffic is not restricted. Kubernetes API access is limited by the agent's Role, not by an egress network policy.

## Before enabling enforcement

1. Check that both Helm releases, the ExternalSecret, and the Cilium policies are healthy; confirm the agent acquires and parses public Envoy logs and the bouncer connects to LAPI.
2. Attach a temporary fail-open Envoy Gateway `SecurityPolicy` to a test HTTPRoute, not the whole Gateway. Ensure the ext-auth gRPC request contains Envoy's `X-Envoy-External-Address`; the bouncer trusts that header and falls back to XFF if it is absent.
3. From a controlled, non-exempt client address, add a temporary LAPI ban decision and verify that requests are denied, including requests with spoofed `X-Forwarded-For` and `X-Envoy-External-Address` headers. Remove the decision and verify access returns. `10.1.0.0/16` and `172.16.0.0/16` are exempt from bouncer evaluation.
4. Test bouncer unavailability and recovery, then decide whether to apply a fail-open `SecurityPolicy` to `envoy-external`. Do not target `envoy-internal`. Re-check address ranges and whether internal clients should be exempt before enabling enforcement.
