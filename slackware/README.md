# Slackware64 base image

## Building locally or on a VM:

1. Copy the `slackware64-15.0` (or other release) folder from a Slackware mirror into this folder, or specify the path using the `SOURCE` bash variable.

    > :warning: **Warning:** Using a stale package source can result in a vulnerable base image!

1. Ensure enough free space (~600 MB to cover both base directory and archive) is available on the filesystem. You may specify a different location for installing the packages before archiving with the `TARGET` bash variable.

1. The included packages strive to be the bare minimum, plus Slackpkg and its prerequisites. You may add or remove packages by adjusting `pkgs.list`.

1. Run the `build` script:
    ```sh
    build
    ```
    Or:
    ```sh
    SOURCE=/mnt/dvd TARGET=/tmp/base build
    ```

1. Build the base image archive into Docker (optionally, set metadata with `--label`):
    ```sh
    docker build --tag slackware64:latest .
    ```

1. To clean up, simply remove the `$TARGET` directory (defaults to `./base`).

## Testing a newly built image:

Test the image by building it with [Dockerfile.test](./Dockerfile.test) and running the provided [tests.sh](./tests.sh):
1. Build a test image:
    ```sh
    docker image build \
        --build-arg BASE_IMAGE=slackware64:latest \
        --file ./Dockerfile.test \
        --tag slackware64:latest_test \
        .
    ```    

1. Run the test container specifyling `ARCH`, `MIRROR`, and whether to skip SSL certificate verficiation with `WGET_NO_CHECK_CERTIFICATE`
    ```sh
    docker container run --tty --attach stdout --attach stderr \
        --env ARCH=x86_64 \
        --env MIRROR='https://mirrors.slackware.com/slackware/slackware64-15.0/' \
        --env WGET_NO_CHECK_CERTIFICATE=0 \
        slackware64:latest_test
    ```

1. Check for test exit codes:

    |Exit Code|Meaning|
    |:---|:---|
    |0|Success|
    |99|Slackpkg related error|
    |98|Target architecture related error|
    |97|`umask` is not 0022|
    |Other|Likeyly an error message from other programs|

## Building in a Docker container

The build can be executed in a Slackware Docker container as long as the container has some basic tools:


1. Pull a Slackware image that contains the build prerequisites below:
    * `installpkg`
    * `bash`
    * `ldconfig`
    * `chroot`
    * `grep`
    * `sed`

    ```sh
    docker image pull ghcr.io/erikkugel/slackware64:latest
    ```

1. Run the build script in a Slackware container:
    ```sh
    docker container run \
        --mount type=bind,src=/mnt/tmp/slackware64-15.0,dst=/source \
        --mount type=bind,src=./,dst=/build \
        --env SOURCE=/source \
        --env TARGET=/base \
        --workdir /build \
        ghcr.io/erikkugel/slackware64:latest \
        ./build
    ```

1. Build the base image:
    ```sh
    docker image build --tag slackware64:${TAG} \
        --label "org.opencontainers.image.source=$(git ls-remote --get-url)" \
        --label "org.opencontainers.image.description=Slackware64 base image" \
        --label "org.opencontainers.image.licenses=WTFPL" \
        .
    ```

## Building with GitHub Actions

There's a [GitHub Actions Workflow](../.github/workflows/slackware_base_images.yaml) to perform the above build and push the image to the GitHub Conatiner Regisrty.

The workflow accepts the following inputs:

```yaml
slackware_mirror_domain:
  description: 'Slackware mirror domain'
  type: string
  required: true
  default: 'mirrors.slackware.com'
slackware_mirror_ssl_check:
  description: 'Check Slackware mirror SSL certificate?'
  type: boolean
  required: true
  default: true
push_to_registry:
  description: 'Push the image to the registry?'
  type: boolean
  required: true
  default: true
build_if_no_new_packages:
  description: 'Build even if there are no new packages?'
  type: boolean
  required: true
  default: false
```

### Using [Nektos gh-act GitHub CLI extension](https://github.com/nektos/gh-act) to run the GitHub Actions Workflow locally:

1. Install [GitHub CLI](https://cli.github.com/).

1. Install and test the [GitHub Act CLI extension](https://github.com/nektos/gh-act).

1. Trigger a local workflow run from the repository's root folder:
    ```sh
    gh act --workflow .github/workflows/slackware_base_images.yaml workflow_dispatch \
        --platform ubuntu-latest=catthehacker/ubuntu:act-latest \
        --input build_if_no_new_packages=1 \
        --input push_to_registry=1 \
        --input slackware_mirror_ssl_check=0 \
        --input slackware_mirror_domain='https://mirrors.slackware.com/slackware/slackware64-15.0/'
    ```