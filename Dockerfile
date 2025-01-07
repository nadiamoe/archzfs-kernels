FROM archlinux@sha256:1fd38e3e4e6e59b35b4cfc63d1416a1eebff7b9e1c0d206d484b537d70e9ee5a as build

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

FROM nginx:1.27.3-alpine@sha256:4efa432b751239898e576a2178702fb156fc483f6d456e0ad5899b3bf5c0445a

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/archzfs-kernels
COPY --from=build /build/out ./
