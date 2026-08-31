# Slackware64 base image

1. Copy the `slackware64-15.0` (or other version) folder from a Slackware mirror into this folder, or specify the path using the `SOURCE` bash variable.

    > [!CAUTION]
    > Using an outdated package source will result in a stale and insecure base image that will need to be updated before it can be built upon.

1. Ensure enough free space (~600 MB to cover both base directory and archive) is available on the filesystem. You may specify a different location for installing the packages before archiving with the `TARGET` bash variable.

1. The included packages strive to be the bare minimum, plus Slackpkg and its prerequisites. You may add or remove packages by adjusting `pkgs.list`.

1. Run the `build` script:
    ```
    build
    ```
    Or:
    ```
    SOURCE=/mnt/dvd TARGET=/tmp/base build
    ```

1. Build the base image archive into Docker (optionally, set metadata with `--label`):
    ```
    docker build --tag slackware64:latest .
    ```

1. Test the image by updating Slackpkg:
    ```
    docker run slackware64:latest slackpkg update
    ```

1. To clean up, simply remove the `$TARGET` directory (defaults to `./base`).
