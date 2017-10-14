# simple-api-gateway

使用 Vue、OpenResty、Reids 打造的简易 API 网关。

将请求转发到指定地址，并且将请求内容与返回的响应内容保存到 Redis ，通过 Vue 前端展示。

使用了 Webpack 作为前端打包工具，使用的 Docker 作为后端部署工具。

## 构建与部署

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build
```

前端 build 完成后，执行 `docker-compose build` 构建 Docker 镜像，可以根据需要调整编排文件中暴露的端口。

默认转发请求到 `http://ip.taobao.com`，可以根据需要修改 `openresty/lua/request_gatteway.lua` 中的 `HOST` 与 `SCHEME` 变量值进行修改。

## 使用

默认用于转发记录请求的站点监听 `80` 端口，对该站点的请求将转发至配置的 `HOST`。

默认展示记录的请求与响应站点监听 `8000` 端口。