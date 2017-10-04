--
-- Created by IntelliJ IDEA.
-- User: tomczhen
-- Date: 17-10-4
-- Time: 下午7:04
-- To change this template use File | Settings | File Templates.
--
local ngx_re = require "ngx.re"
local redis = require "resty.redis"
local cjson = require "cjson"

parameters = {
    ["requests"] = ""
}

path_parameters = ngx_re.split(ngx.var.uri, "/", nil, { pos = 2 })

if not parameters[path_parameters[1]] then
    ngx.status = ngx.HTTP_NOT_FOUND
else
    local redis_conn = redis:new()
    redis_conn:set_timeout(1000)
    local status, err = redis_conn:set_keepalive(10000, 500)
    local status, err = redis_conn:connect("redis", 6379)

    local res, err = redis_conn:zrange("172.18.0.1:20171005", 0, -1)

    ngx.print(res[1])
end