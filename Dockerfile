FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG TAG

WORKDIR /root
RUN set -ex && \
	apk add --update git build-base && \
	git clone https://github.com/fatedier/frp.git frp && \
	cd ./frp && \
	git fetch --all --tags && \
	git checkout tags/${TAG} && \
	make frps

FROM --platform=${TARGETPLATFORM} alpine:latest
COPY --from=builder /root/frp/bin/frps /usr/bin/

RUN apk add --no-cache ca-certificates su-exec tzdata

RUN mkdir -p /etc/frps

WORKDIR /etc/frps

COPY --from=builder /root/frp/conf/frps.ini /etc/frps/frps.ini

ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone

CMD /usr/bin/frps -c /etc/frps/frps.ini