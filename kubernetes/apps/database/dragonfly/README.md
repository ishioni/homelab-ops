# Dragonfly access

Dragonfly uses the `REDIS_PASSWORD` field in the existing `dragonfly` 1Password item. External Secrets distributes it to the database and client namespaces; do not commit the password. Client traffic uses plaintext Redis, so the password and data are not encrypted in transit. Cilium restricts ingress to the configured clients, Dragonfly peers, the operator, and monitoring; the operator's admin port remains unauthenticated and unencrypted.

## Initial cutover

1. Add a strong, non-empty `REDIS_PASSWORD` field to the `dragonfly` 1Password item **before merging or reconciling these changes**. The same item also holds the existing S3 credentials; preserve those fields. A missing field can prevent existing application secrets from refreshing.
2. Schedule a maintenance window. Flux reconciles the server and client Kustomizations independently, and External Secrets refreshes asynchronously. Clients may temporarily fail whether they switch before or after the server; Paperless jobs and ToolHive sessions are affected. Confirm backups and replication health before proceeding.
3. Merge and reconcile the changes. Check that the ExternalSecrets for Dragonfly, Immich, Paperless, SearXNG, Renovate, and ToolHive are ready and that the generated Secrets have the expected keys, without printing their values. The Dragonfly operator manages its own rolling update even though its StatefulSet uses `OnDelete`; do not manually delete pods while it is rolling. Check that replicas are synchronized and the cluster is healthy throughout.
4. Verify each application, a Renovate job, ToolHive sessions, Dragonfly replication, Gatus, and Prometheus. Confirm that the normal Redis port rejects unauthenticated commands and accepts authenticated commands from an authorized client. The monitoring TCP check alone does not test authentication. Review Cilium policy drops if connectivity fails.

## Rotation and rollback

Password changes are not atomic: Dragonfly and clients consume credentials through environment variables or secret references, and existing processes may retain the old value. Plan a maintenance window and coordinate the secret update with restarts and verification; in particular, restart the operator-managed ToolHive gateway after the Secret changes. Do not assume a Secret update automatically rolls Dragonfly or every client. Verify replication before restarting Dragonfly instances, and avoid deleting the primary directly. To roll back, coordinate the server and clients back to matching credentials; reverting only one side will interrupt access.
