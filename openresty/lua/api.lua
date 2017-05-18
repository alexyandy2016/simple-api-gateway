local redis = require "resty.redis"

local des = require "resty.nettle.des"
local base64 = require "resty.nettle.base64"
local pkcs7 = require "resty.nettle.padding.pkcs7"
local resty_uuid = require "resty.uuid"
local cjson = require "cjson"
local http = require "resty.http"

local DES_KEY = "des_key"
local DES_IV = "des_iv"

local HOLD_HEDADERS = {
    ['user-agent']="", ['content-type']="", ['connection']="", ['accept']="", ['etag']="",

    }
local NOT_ENCRYPT_HEDADERS = {
    ['host']="", ['user-agent']="", ['content-type']="", ['connection']="", ['accept']="",
    ['cache-control']="",['content-length']="",["accept-encoding"]="",['etag']="", ['postman-token']="",
}

local function des_encrypt(data)

    local ds, wk = des.new(DES_KEY,"cbc",DES_IV)
    local d = base64.encode(ds:encrypt(pkcs7.pad(data,8)))
    return d

end

local function des_decrypt(data)

    local ds, wk = des.new(DES_KEY,"cbc",DES_IV)
    local d = pkcs7.unpad(ds:decrypt(base64.decode(data)),8)
    return d

end

local function handle_headers(headers)
    local h = {}
    h["version"] = ngx.req.http_version()
    h["Host"] = "127.0.0.1"
    for k,v in pairs(headers) do
        headers[k] = ngx.unescape_uri(v)
        if not NOT_ENCRYPT_HEDADERS[k] then
            h[k] = des_encrypt(v)
        end

        if HOLD_HEDADERS[k] then
            h[k] = v
        end
    end
    return h
end

local function handle_body(body)
    local b = {}
    for k,v in pairs(body) do
        b[k] = des_encrypt(v)
    end

    b = ngx.encode_args(b)
    return b
end

ngx.req.read_body()
local source_request = {
    --request_id = ngx.var.request_id,
    method = ngx.req.get_method(),
    headers = ngx.req.get_headers(20),
    path = ngx.var.uri,
    query = ngx.req.get_uri_args(20),
    body = ngx.req.get_post_args(20),
}

local handled_request = {
    --request_id = source_request.request_id,
    method = source_request.method,
    headers = handle_headers(source_request.headers),
    path = source_request.path,
    query = ngx.encode_args(source_request.query),
    body = handle_body(source_request.body)
}

local function save_2_redis(response)

    local id = resty_uuid:generate_time_safe()
    local redis_conn = redis:new()
    local status, err = redis_conn:set_keepalive(10000, 500)
    local status, err = redis_conn:connect("redis", 6379)
    redis_conn:init_pipeline()
    redis_conn:set("requests:"..id, cjson.encode(response))
    redis_conn:expire("requests:"..id, 86400)
    redis_conn:lpush(ngx.var.remote_addr,id)
    redis_conn:expire(ngx.var.remote_addr, 86400)
    redis_conn:commit_pipeline()
    local status,err = redis_conn:close()
end

local function send_request()
    local http_conn = http.new()
    http_conn:set_timeout(2000)
    http_conn:connect("127.0.0.1",80)
    local response, err = http_conn:request{
        method = handled_request.method,
        --path = handled_request.path,
        path = "/test",
        headers = handled_request.headers,
        body = handled_request.body,
        query = handled_request.query,
    }

    return response,err
end

local function handle_response(response)
    local r = {}
    local b = response:read_body()
    local status, body = pcall(des_decrypt,b)

    if status then
        status, body = pcall(cjson.decode,body)
    end


    if not status then
        body = b
    end
    
    r["source_request"] = source_request
    r["handled_request"] = handled_request
    r["response"] = {
        status = response.status,
        headers = response.headers,
        body = body
    }
    
    return r
end

local response,err = send_request()

if response then
    finally_response = handle_response(response)
    save_2_redis(finally_response)
    ngx.print(cjson.encode(finally_response))
else
    ngx.print(cjson.encode({
        message= "Fail To Request",
        status = err}))
end