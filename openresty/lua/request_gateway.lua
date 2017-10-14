local redis = require "resty.redis"
local cjson = require "cjson"
local http = require "resty.http"
local zlib = require("zlib")

local HOST = "ip.taobao.com"
local SCHEME = "http://"
local IGNORE_HEADERS = {
    ['Connection'] = "",
    ['Transfer-Encoding'] = "",
    ['Content-Encoding'] = "",
}

local function init_redis(config)
    local conf = {
        ["host"] = config.host or "127.0.0.1",
        ["port"] = config.port or 6379,
        ["database"] = config.database or 0,
        ["timeout"] = config.timeout or 1000,
        ["max_idle_time"] = config.keepalive or 10000,
        ["pool_size"] = config.pool_size or 100
    }
    local conn = redis:new()
    conn:set_timeout(conf.timeout)
    conn:set_keepalive(conf.max_idle_time, conf.pool_size)
    conn:connect(conf.host, conf.port)
    return conn
end

local function decoding_gzip(response)
    local stream = zlib.inflate()
    local encoding = response.headers['Content-Encoding']
    local body = ""

    if encoding == 'gzip' or encoding == 'deflate' or encoding == 'deflate-raw' then
        body = stream(response.body)
    else
        body = response.body
    end

    return body
end

local function save_2_redis(requests)

    local redis_conn = init_redis({ host = "redis" })

    local expire_time = 24 * 60 * 60
    local zset_key = "reqs:" .. ngx.var.remote_addr .. ":" .. ngx.today():gsub("-", ""):sub(3)

    redis_conn:init_pipeline()
    redis_conn:zadd(zset_key, ngx.now(), cjson.encode(requests))
    redis_conn:expire(zset_key, expire_time)
    redis_conn:commit_pipeline()
end

local function send_request(request)
    request.headers["host"] = HOST
    local http_conn = http.new()
    http_conn:set_timeout(2000)
    local uri = SCHEME .. HOST .. request.path .. "?" .. ngx.encode_args(request.query)
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

    requests["response"] = {
        headers = response.headers,
        status = response.status,
        body = decoding_gzip(response)
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


