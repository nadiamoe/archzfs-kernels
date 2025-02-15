FROM archlinux@sha256:33ff44f3d1d18207c1bdc1bf5c4283541b7680bb60e3092e6973437e4e1c3927 as build

RUN pacman -Syu --noconfirm perl wget

WORKDIR /build

# Docker caches this using standard HTTP headers, and thus all layers below.
# On CI/CD, this cache is reused so it is fine to build this contianer periodically and unconditionally.
ADD http://archzfs.com/archzfs/x86_64/archzfs.db .

# Makedb generates a list of urls of the linux- packages that packages in archzfs require, and a script to create repos
# for them.
COPY makedb.pl .
RUN xzcat archzfs.db | perl makedb.pl && chmod +x repo-add.sh
# Download linux packages. We won't serve these, but we need them anyway for the metadata.
RUN cat urls | xargs -n 1 -P 8 wget -nv || true
# Generate repos.
RUN ./repo-add.sh

FROM nginx:1.27.4-alpine@sha256:b471bb609adc83f73c2d95148cf1bd683408739a3c09c0afc666ea2af0037aef

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/archzfs-kernels
COPY --from=build /build/out ./
