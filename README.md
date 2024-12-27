# archzfs-kernels container

This is a fork of https://github.com/endreszabo/kernels.archzfs.com, which reuses most of the approach and logic originally created by @endreszabo, but "containerizes" it to make it easy to deploy.

The ZFS packages and its dependencies are fetched in build time to generate the index files, so the container must be rebuilt periodically or when new ZFS packages come out.

The `Dockerfile` is built with caching in mind, and all the costly steps of downloading packages and rebuilding the repos will not be re-run if the upstream `archzfs.db` file has not changed since the last build. Thus, it is fine to build this container periodically, as the CI/CD pipeline in this repo does.

Similarly to the pre-fork repo, this container does not actually serve the kernels, but rather serves redirects to the [Arch Linux Archive](https://wiki.archlinux.org/title/Arch_Linux_Archive). This makes it very cheap to run.

## Using this repository

### Hosted instance

I host an instance of this container, updated daily, at `https://archzfs-kernels.nadia.moe`. At the moment this is served from Germany.

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

