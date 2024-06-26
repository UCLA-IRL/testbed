# syntax=docker/dockerfile:1

ARG NDN_CXX_VERSION=latest

FROM ghcr.io/named-data/ndn-cxx-runtime:${NDN_CXX_VERSION} AS testbed-master

RUN <<EOF
    set -eux

    apt-get -Uy install --no-install-recommends ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get install -Uy --no-install-recommends \
        git \
        busybox \
        python3 \
        python3-pip \
        docker-ce-cli \
        docker-compose-plugin
    apt-get distclean

    pip install --no-cache-dir --disable-pip-version-check --break-system-packages \
        PyYAML \
        python-ndn==0.4.2 \
        Jinja2==3.1.4
EOF

VOLUME /testbed
WORKDIR /testbed


FROM caddy:2 AS testbed-caddy

ADD https://nfd-status-page.ndn.today/NDNts-NFD-status-page.txz /srv/n/dist.txz
RUN tar -Jxvf /srv/n/dist.txz -C /srv/n && rm /srv/n/dist.txz
