#!/bin/sh
# Substitute environment variables into nginx.conf template
PORT=${PORT:-8080}
export PORT

envsubst '${PORT}' < /app/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf

exec /usr/local/openresty/bin/openresty -g "daemon off;"
