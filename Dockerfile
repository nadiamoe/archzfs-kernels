FROM archlinux@sha256:122c41e04f907f4d962e0a2750d6b09c540a81dd45aace62a899d268e507b1f6 as build

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

FROM nginx:1.29.0-alpine@sha256:6e39bb3765ac959c7e1240509636173417a5e37abf140f418401e2fa73970bbe

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/archzfs-kernels
COPY --from=build /build/out ./
