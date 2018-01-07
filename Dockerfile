FROM openresty/openresty:1.13.6.1-alpine-fat
WORKDIR /usr/local/openresty/nginx
RUN apk add --no-cache ca-certificates git zlib-dev
RUN luarocks install lua-resty-http \
    && luarocks install lua-zlib
COPY lua lua
COPY sample.nginx conf/nginx.conf
EXPOSE 80