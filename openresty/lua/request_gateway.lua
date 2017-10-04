local redis = require "resty.redis"

local des = require "resty.nettle.des"
local base64 = require "resty.nettle.base64"
local pkcs7 = require "resty.nettle.padding.pkcs7"
local resty_uuid = require "resty.uuid"
local cjson = require "cjson"
local http = require "resty.http"

local zlib = require("zlib")
local stream = zlib.inflate()

local DES_KEY = "des_key"
local DES_IV = "des_iv"
local HOST = "ip.taobao.com"
local IGNORE_HEADERS = {
    ['Connection'] = "",
    ['Transfer-Encoding'] = "",
    ['Content-Encoding'] = "",
}

local function des_encrypt(data)
    local ds, wk = des.new(DES_KEY, "cbc", DES_IV)
    return base64.encode(ds:encrypt(pkcs7.pad(data, 8)))
end

local function des_decrypt(data)

    local ds, wk = des.new(DES_KEY, "cbc", DES_IV)
    return pkcs7.unpad(ds:decrypt(base64.decode(data)), 8)
end

local function save_2_redis(requests)

    local redis_conn = redis:new()
    redis_conn:set_timeout(1000)
    local status, err = redis_conn:set_keepalive(10000, 500)
    local status, err = redis_conn:connect("redis", 6379)

    if not status then
        ngx.say("Failed To Connect Redis : ", err)
        return
    end

    local expire_time = 24 * 60 * 60
    local key = ngx.var.remote_addr .. ":" .. ngx.today():gsub("-", "")

    redis_conn:init_pipeline()
    redis_conn:zadd(key, ngx.now(), cjson.encode(requests))
    redis_conn:expire(key, expire_time)
    redis_conn:commit_pipeline()

    local status, err = redis_conn:close()
end

local function send_request(request)
    request.headers["host"] = HOST
    local http_conn = http.new()
    http_conn:set_timeout(2000)
    local uri = "http://" .. HOST .. request.path .. "?" .. ngx.encode_args(request.query)
    local response, err = http_conn:request_uri(uri, {
        method = request.method,
        headers = request.headers,
        body = request.body,
    })
    http_conn:set_keepalive()
    return response, err
end

ngx.req.read_body()

local requests = {
    request_id = ngx.var.request_id,
    http_version = ngx.req.http_version(),
    time_stamp = ngx.localtime(),
    request = {
        method = ngx.req.get_method(),
        headers = ngx.req.get_headers(50),
        path = ngx.var.uri,
        query = ngx.req.get_uri_args(20),
        body = ngx.req.get_post_args(20),
    }
}

local response, err = send_request(requests.request)

if response then
    for k, v in pairs(response.headers) do
        if not IGNORE_HEADERS[k] then
            ngx.header[k] = v
        end
    end

    local encoding = response.headers['Content-Encoding']
    local body = ""

    if encoding == 'gzip' or encoding == 'deflate' or encoding == 'deflate-raw' then
        body = stream(response.body)
    else
        body = response.body
    end

    requests["response"] = {
        headers = response.headers,
        status = response.status,
        body = body
    }

    ngx.status = response.status
else
    requests["response"] = {
        body = {
            message = "Request Fail!",
            status = err
        }
    }
end

save_2_redis(requests)

ngx.print(requests.response.body)


