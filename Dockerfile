FROM archlinux@sha256:4e77cf2ea5f410e6f8be5abf93ccf17ce2436e87a138c167208356711a405dbd as build

RUN pacman -Syu --noconfirm perl wget

WORKDIR /build

# Docker caches this using standard HTTP headers, and thus all layers below.
# On CI/CD, this cache is reused so it is fine to build this contianer periodically and unconditionally.
ADD https://github.com/archzfs/archzfs/releases/download/experimental/archzfs.db .

# Makedb generates a list of urls of the linux- packages that packages in archzfs require, and a script to create repos
# for them.
COPY makedb.pl .
RUN xzcat archzfs.db | perl makedb.pl && chmod +x repo-add.sh
# Download linux packages. We won't serve these, but we need them anyway for the metadata.
RUN cat urls | xargs -n 1 -P 8 wget -nv || true
# Generate repos.
RUN ./repo-add.sh

FROM nginx:1.31.6-alpine@sha256:df221db836e1754089190208cee7eeda94f233197056426eda74a43ab1abeac2

COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/archzfs-kernels
COPY --from=build /build/out ./
