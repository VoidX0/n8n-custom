FROM blowsnow/n8n-chinese:latest

# Copy apk and its deps from Alpine 3.23
COPY --from=alpine:3.23 /sbin/apk /sbin/apk
COPY --from=alpine:3.23 /usr/lib/libapk.so* /usr/lib/

USER root

RUN apk add --no-cache docker-cli-compose
RUN apk add --no-cache yq

USER node