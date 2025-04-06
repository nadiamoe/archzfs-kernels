# archzfs-kernels container

This is a fork of https://github.com/endreszabo/kernels.archzfs.com, which reuses most of the approach and logic originally created by @endreszabo, but "containerizes" it to make it easy to deploy.

The ZFS packages and its dependencies are fetched in build time to generate the index files, so the container must be rebuilt periodically or when new ZFS packages come out.

Similarly to the pre-fork repo, this container does not actually serve the kernels, but rather serves redirects to the [Arch Linux Archive](https://wiki.archlinux.org/title/Arch_Linux_Archive). This makes it very cheap to run.

## Build freshness

A CI/CD pipeline rebuilds this image every few hours. As the `Dockerfile` on this repo is built to heavily rely on the container build cache, subsequent builds after the first time will not re-download or re-process any data. The container build process is also made in a fully reproducible way, which means that the digest of `ghcr.io/nadiamoe/archzfs-kernels:main` will also stay the same if nothing had to be rebuilt.

The build cache is automatically invalidated when:

- The archzfs repo index (`http://archzfs.com/archzfs/x86_64/archzfs.db`) changes upstream
- Arch Linux container image is updated
- Nginx container image is updated
- The source tree in this repository changes (i.e. new commits are added)

This means that the `ghcr.io/nadiamoe/archzfs-kernels:main` container image is rebuilt automatically, with a worst-case delay of a couple hours, without abusing anybody's infrastructure. Renovate also keeps the Nginx and Arch Linux containers updated automatically.

## Using this repository

### Hosted instance

I host an instance of this container, with an additional update delay of a couple hours, at `https://archzfs-kernels.nadia.moe`. At the time of writing this is hosted in Germany, but packages are served from the Arch Linux Archive.

* Add the repositories to your `pacman.conf`
```
[zfs-linux]
Server = https://archzfs-kernels.nadia.moe/$repo/

[zfs-linux-lts]
Server = https://archzfs-kernels.nadia.moe/$repo/

# [zfs-packages-for-other-kernels]
# Server = https://archzfs-kernels.nadia.moe/$repo/
```
* Update your system, minding to specify the required kernel versions.

### Run it locally

* Pull the latest image 
  - `docker pull ghcr.io/nadiamoe/archzfs-kernels:main`
* _OR_ build it from source 
  - `docker build . -t ghcr.io/nadiamoe/archzfs-kernels:main`
* Start the contianer
  - `docker run -ti --rm -p 8080:80 ghcr.io/nadiamoe/archzfs-kernels:main`
* Add the repositories to your `pacman.conf`
```
[zfs-linux]
Server = http://localhost:8080/$repo/

[zfs-linux-lts]
Server = http://localhost:8080/$repo/
```
* Update your system, minding to specify the required kernel versions.

