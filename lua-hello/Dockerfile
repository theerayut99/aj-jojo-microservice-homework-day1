FROM openresty/openresty:1.27.1.2-alpine

RUN apk add --no-cache gettext

WORKDIR /app

COPY nginx.conf.template ./nginx.conf.template
COPY entrypoint.sh ./entrypoint.sh
COPY lua/ ./lua/
COPY openapi.json ./openapi.json

RUN chmod +x ./entrypoint.sh

ENV PORT=8080
ENV SERVICE_NAME=loan-service
ENV SERVICE_VERSION=1.2.0
ENV SERVICE_ENV=production

EXPOSE 8080

STOPSIGNAL SIGQUIT

ENTRYPOINT ["./entrypoint.sh"]
