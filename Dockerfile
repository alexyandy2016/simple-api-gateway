FROM openresty/openresty:1.11.2.5-alpine-fat
WORKDIR /usr/local/openresty/nginx
RUN apk add --no-cache nettle libuuid ca-certificates git zlib-dev
RUN \
    luarocks install lua-resty-nettle \
    && luarocks install lua-resty-uuid \
    && luarocks install lua-resty-http \
    && luarocks install lua-zlib \
    && cd /usr/lib \ 
    && ln -s libnettle.so.6 libnettle.so \
    && ln -s libuuid.so.1.3.0 libuuid.so
ADD ./openresty/lua lua/
ADD ./openresty/nginx.conf conf/

