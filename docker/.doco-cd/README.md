# Doco-CD on TrueNAS SCALE

Deploy this file through the TrueNAS SCALE UI:

```text
docker/.doco-cd/docker-compose.updater.yaml
```

The UI-managed application is the bootstrap updater. Do not deploy
`docker-compose.app.yaml` through the UI; that is the main Doco-CD instance and
is deployed by the updater using `.doco-cd.updater.yaml` in this directory.

Both instances scope Git HTTP(S) credentials to `github.com` via
`GIT_AUTH_DOMAINS` (required for global credentials since Doco-CD v0.130.0).
After changing the updater's Compose file, redeploy the UI-managed updater in
TrueNAS SCALE; it will deploy the main instance from the repository on its next
poll. If the updater is stopped, redeploy it through the UI first.
