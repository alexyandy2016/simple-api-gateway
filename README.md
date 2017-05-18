# 使用说明

## 部署

**由于使用了 Linux 的运行库，所以只能在 Linux 上运行**

### 使用 Docker 部署

推荐使用 Docker 部署

#### 构建镜像

```
docker build -t tomczhen/api-gateway .
```
#### 运行容器

```
docker run -d --name api-gateway \
-p 8000:80 \
tomczhen/api-gateway
```

### 安装 OpenResty 手动部署

> 参考: http://openresty.org/en/installation.html


## 功能说明

一句话说明：将请求加密后转发到`api-center-dev.lan.51djt.com`站点，并将响应体解密返回。

### 注意事项

* 不支持文件提交
* `HOLD_HEDADERS` 控制 `headers` 是否转发
* `NOT_ENCRYPT_HEDADERS` 控制 `headers` 是否加密

### 使用方法

使用 `Postman` 等调试工具，参数值保持明文即可，请求地址修改为部署服务器地址（注意使用的端口）。


遇到问题请在本项目中提交。

### 返回信息说明

* `source_request`  
发起的原始请求

* `handled_request`  
由 `api-gateway` 处理后的请求

* `response`  
相应内容

### 其他

如果本项目稳定，可以考虑使用 `postman` 管理接口文档。

# TODO
## 代码

* 尝试使用面对对象

## 部署

* 完善 Docker 编排文件用于部署

## 功能

* 使用 Redis 保存请求与响应内容
* 在页面中展示请求与响应内容