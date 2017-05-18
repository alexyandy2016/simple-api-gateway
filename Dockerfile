FROM openresty/openresty:1.11.2.2-alpine-fat
RUN apk add --no-cache nettle libuuid ca-certificates
WORKDIR /usr/local/openresty/nginx
RUN \
    /usr/local/openresty/luajit/bin/luarocks install lua-resty-nettle \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-uuid \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-http \
    && cd /usr/lib \ 
    && ln -s libnettle.so.6 libnettle.so \
    && ln -s libuuid.so.1.3.0 libuuid.so
ADD ./openresty/lua lua/
ADD ./openresty/nginx.conf conf/

