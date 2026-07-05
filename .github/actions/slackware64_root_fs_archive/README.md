# Slackware Build Image Action

This GitHub Action builds (and optionally pushes) a Docker image from the repository's Slackware build context.

Usage (in a workflow):

```yaml
uses: ./.github/actions/slackware_build_image
with:
  context: slackware64
  tag: myorg/slackware:latest
  push: 'false'
  registry: ghcr.io
  username: ${{ secrets.REGISTRY_USERNAME }}
  password: ${{ secrets.REGISTRY_PASSWORD }}
```

Notes:
- The action uses the `docker` CLI inside the action container. For `docker build` and `docker push` to work, the runner must provide access to a Docker daemon (e.g., by running on a self-hosted runner with Docker or by binding `/var/run/docker.sock`).
- If Docker is not available inside the container, the action falls back to creating a tarball of the build context in `/workspace`.
