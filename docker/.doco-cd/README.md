# Self-updating Doco-CD on TrueNAS SCALE

This directory contains the two Doco-CD Compose definitions used by the
TrueNAS deployment:

- `docker-compose.app.yaml` is the **main** instance. It deploys the stacks
  under `docker/truenas/` and is deployed by the updater.
- `docker-compose.updater.yaml` is the **bootstrap updater**. This is the
  definition pasted into the TrueNAS SCALE UI. It polls Git and deploys the
  main instance through the repository-root `.doco-cd.updater.yaml` target.

The updater is intentionally not under `docker/truenas/`: the main instance's
auto-discovery would otherwise try to deploy a second updater.

## Before starting

1. Make sure the changes for this setup have been merged to `master`.
2. Confirm that the repository is cloneable by Doco-CD. The current setup does
   not configure `GIT_ACCESS_TOKEN`, so this requires a publicly cloneable
   repository or credentials supplied separately in the updater app.
3. Save the existing TrueNAS Doco-CD app configuration before changing it.
4. From the TrueNAS Shell, inspect the current main container and record its
   `/data` volume. The main instance may otherwise receive a new Compose-named
   volume during the handover:

   ```sh
   docker inspect doco-cd
   docker volume ls
   ```

   Losing the Doco-CD `/data` volume does not remove the application data
   volumes, but it does lose Doco-CD's local clone/cache/state and causes it to
   bootstrap again.

## TrueNAS cutover

The updater must take over the TrueNAS UI app before it performs its first
poll. Do not run the old UI-managed `doco-cd` container and the updater-driven
main instance through the cutover at the same time.

1. Open the existing Doco-CD application in the TrueNAS SCALE UI.
2. Replace its Compose YAML with the contents of
   `docker-compose.updater.yaml` from this directory.
3. Apply/deploy the application. This stops the old UI-managed `doco-cd`
   container and starts `doco-cd-updater` instead.
4. If TrueNAS leaves the old container behind, stop and remove only the old
   `doco-cd` container before continuing. Do not remove application containers
   or application data volumes.
5. Confirm that `doco-cd-updater` is running and healthy:

   ```sh
   docker ps --filter name=doco-cd
   docker logs --tail 100 doco-cd-updater
   ```

6. Wait for the updater's poll interval, or restart the updater once to cause
   an immediate initial poll. It should apply `.doco-cd.updater.yaml` and
   create the main `doco-cd` container from `docker-compose.app.yaml`.
7. Confirm both instances are running:

   ```sh
   docker ps --filter name=doco-cd
   ```

   The main instance should expose the existing ports `8080` and `9120`.
   The updater deliberately has no host-published ports.

8. Check the main Doco-CD logs and confirm that it discovers and deploys the
   application directories under `docker/truenas/`.

After the cutover, the TrueNAS UI owns the updater only. The main `doco-cd`
container is owned by the updater through `.doco-cd.updater.yaml`; do not
redeploy that container independently from the TrueNAS UI.

## GitHub webhook

The existing GitHub webhook can remain unchanged. The webhook hook currently
posts to `http://leo.ishioni.casa:8080/v1/webhook`, which is the main Doco-CD
instance's published port from `docker-compose.app.yaml`. The updater has no
host-published ports and should not be the webhook destination.

The main instance also keeps `WEBHOOK_SECRET_FILE` and the existing secret file
mount, so the Kubernetes webhook's `GITHUB_WEBHOOK_SECRET` must continue to
contain the same value as the TrueNAS `/mnt/SSD/Userhomes/movi/.config/doco-cd/webhook_secret`
file.

A push therefore has two paths: the webhook immediately asks the main instance
to deploy the application configuration, while the updater's poll detects the
same commit and reconciles the main Doco-CD definition. The updater target does
not permanently use `force_recreate`, so an application-only push does not
needlessly restart the main Doco-CD container. A real change to the main
Compose definition still causes the normal Compose update.

## Update flow

1. A commit changes either the main Doco-CD definition or the application
   configuration.
2. `doco-cd-updater` polls `master` and applies the `updater` target.
3. The updater recreates the main `doco-cd` container when needed.
4. The main instance starts and deploys the application changes using
   `docker/truenas/.doco-cd.yaml`.

The updater and main image references are intentionally pinned by version and
digest. Updating Doco-CD requires changing the image reference in both
Compose definitions and merging that change to `master`. This setup reacts
to repository changes; it does not independently watch GHCR for new releases.
A dependency-update tool such as Renovate can automate those image-reference
changes if desired.

The updater has `SCHEDULER_ENABLED=false` so scheduled jobs run only on the
main instance.

## Rollback

If the updater cannot start the main instance:

1. Stop the TrueNAS updater app.
2. Restore the saved original UI Compose YAML for the main `doco-cd` app.
3. Remove the updater-created `doco-cd` container only if it prevents the UI
   app from starting.
4. Reuse the original `/data` volume when restoring the main app.
5. Start the restored UI app and inspect the Doco-CD logs.

Do not delete the application stack volumes as part of this rollback.
