# archzfs-kernels container

This is a fork of https://github.com/endreszabo/kernels.archzfs.com, which reuses most of the approach and logic originally created by @endreszabo, but "containerizes" it to make it easy to deploy.

The ZFS packages and its dependencies are fetched in build time to generate the index files, so the container must be rebuilt periodically or when new ZFS packages come out.

The `Dockerfile` is built with caching in mind, and all the costly steps of downloading packages and rebuilding the repos will not be re-run if the upstream `archzfs.db` file has not changed since the last build. Thus, it is fine to build this container periodically, as the CI/CD pipeline in this repo does.
