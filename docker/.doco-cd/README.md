# Doco-CD on TrueNAS SCALE

Deploy this file through the TrueNAS SCALE UI:

```text
docker/.doco-cd/docker-compose.updater.yaml
```

The UI-managed application is the bootstrap updater. Do not deploy
`docker-compose.app.yaml` through the UI; that is the main Doco-CD instance and
is deployed by the updater using the repository-root `.doco-cd.updater.yaml`
target.
