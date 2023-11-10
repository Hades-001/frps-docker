FROM --platform=${TARGETPLATFORM} golang:1.21-bullseye as builder

ARG CGO_ENABLED=0
ARG TAG
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates git gcc make libc-dev && \
    git clone https://github.com/fatedier/frp.git frp && \
    cd ./frp && \
    git fetch --all --tags && \
    git checkout tags/${TAG} && \
    make frps

FROM --platform=${TARGETPLATFORM} gcr.io/distroless/base-debian11
COPY --from=builder /root/frp/bin/frps /usr/bin/

ENV TZ=Asia/Shanghai

CMD [ "/usr/bin/frps" ]
