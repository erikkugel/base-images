# Slackware Root File-System Archive Creation
This GitHub Action creates a Slackware root filesystem archive for import into a a Docker image

## Environment Variables

## `ARCH`
The target architecture of the base image, one of:
- `x86_64`
- `i686`

## `RELEASE`
The Slackware release from which to build the image:
- `15.0`
- `current`

## `SOURCE`
Where the source packages are located

## `TARGET`
Which directory to use to staging the filesystem before archiving

## Example usage
```yaml
uses: ./.github/actions/slackware_root_fs_archive
with:
    ARCH: 'x86_64'
    RELEASE: '15.0'
    SOURCE: ${{ github.workspace }}/source
    TARGET: ${{ github.workspace }}/base
```