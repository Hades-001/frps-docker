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

ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
	echo "${TZ}" > /etc/timezone

RUN mkdir -p /etc/frps

VOLUME ["/etc/frps"]

WORKDIR /etc/frps

ENV PUID=1000 PGID=1000 HOME=/etc/frps

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

CMD /usr/bin/frps