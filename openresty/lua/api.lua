local redis = require "resty.redis"

local des = require "resty.nettle.des"
local base64 = require "resty.nettle.base64"
local pkcs7 = require "resty.nettle.padding.pkcs7"
local resty_uuid = require "resty.uuid"
local cjson = require "cjson"
local http = require "resty.http"

local DES_KEY = "des_key"
local DES_IV = "des_iv"
local HOST = "www.tomczhen.com"
local IGNORE_HEADERS = {
    ['Connection'] = "",
    ['Transfer-Encoding'] = "",
}

local function des_encrypt(data)
    local ds, wk = des.new(DES_KEY, "cbc", DES_IV)
    return base64.encode(ds:encrypt(pkcs7.pad(data, 8)))
end

local function des_decrypt(data)

    local ds, wk = des.new(DES_KEY, "cbc", DES_IV)
    return pkcs7.unpad(ds:decrypt(base64.decode(data)), 8)
end

local function save_2_redis(response)

    local id = resty_uuid:generate_time_safe()
    local redis_conn = redis:new()
    local status, err = redis_conn:set_keepalive(10000, 500)
    local status, err = redis_conn:connect("redis", 6379)

    redis_conn:init_pipeline()
    redis_conn:set("requests:" .. id, cjson.encode(response))
    redis_conn:expire("requests:" .. id, 86400)
    redis_conn:lpush(ngx.var.remote_addr, id)
    redis_conn:expire(ngx.var.remote_addr, 86400)
    redis_conn:commit_pipeline()

    local status, err = redis_conn:close()
end

local function send_request(request)
    local http_conn = http.new()
    --http_conn:set_timeout(100)
    local uri = "http://"..HOST .. request.path .. "?" .. ngx.encode_args(request.query)
    local response, err = http_conn:request_uri(uri, {
        method = request.method,
        headers = request.headers,
        body = request.body,
    })

    return response, err
end

ngx.req.read_body()

local request = {
    request_id = ngx.var.request_id,
    http_version = ngx.req.http_version(),
    method = ngx.req.get_method(),
    headers = ngx.req.get_headers(50),
    path = ngx.var.uri,
    query = ngx.req.get_uri_args(20),
    body = ngx.req.get_post_args(20),
}

request.headers["host"] = HOST
local response, err = send_request(request)

if response then

    for k, v in pairs(response.headers) do
        if not IGNORE_HEADERS[k] then
            ngx.header[k] = v
        end
    end
    ngx.status = response.status
    --ngx.print(cjson.encode(response.headers))
    --ngx.print(cjson.encode(request.headers))
    ngx.print(response.body)
else
    ngx.print(cjson.encode({
        message = "Request fail",
        status = err
    }))
end