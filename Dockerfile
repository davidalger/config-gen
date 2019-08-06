FROM centos:7 AS builder

## Install rust-lang using rustup
RUN curl https://sh.rustup.rs -sSf | sh /dev/stdin -y

## Install build dependencies
RUN yum install -y gcc openssl openssl-devel git

## Build config-gen binary
COPY . /opt/config-gen
RUN source $HOME/.cargo/env \
    && cd /opt/config-gen \
    && cargo build

FROM centos:7

## Install runtime dependencies
RUN yum install -y openssl \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY docker-entrypoint /usr/local/bin/
COPY --from=builder /opt/config-gen/target/debug/config-gen /usr/local/bin/

ENTRYPOINT ["docker-entrypoint"]
CMD "config-gen"
