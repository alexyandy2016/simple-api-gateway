FROM node:6.12.0-alpine as builder
RUN mkdir /app
COPY . /app/
WORKDIR /app
RUN npm install && npm run build

FROM openresty/openresty:1.11.2.5-alpine-fat
WORKDIR /usr/local/openresty/nginx
RUN apk add --no-cache ca-certificates git zlib-dev
RUN luarocks install lua-resty-http \
    && luarocks install lua-zlib
COPY openresty/lua lua
COPY openresty/nginx.conf conf
COPY --from=builder /app/dist html
EXPOSE 80
EXPOSE 8000