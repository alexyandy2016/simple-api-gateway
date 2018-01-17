local zlib = require("zlib")
local cjson = require "cjson"
local ngx_re = require "ngx.re"

local request_headers = ngx.req.get_headers(20)

local log = {
    client_ip = ngx.var.remote_addr,
    request_id = ngx.var.request_id,
    http_version = ngx.req.http_version(),
    method = ngx.req.get_method(),
    request_headers = request_headers,
    path = ngx.var.request_uri,
    query = ngx.req.get_uri_args(20),
}

local function compress_body(c_type)
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    local stream = zlib.inflate()
    local encoding = request_headers["content-encoding"]
    local data = ""

    if encoding == 'gzip' or encoding == 'deflate' or encoding == 'deflate-raw' then
        data = stream(body)
    else
        data = body
    end

    if c_type == "application/json" and data ~= nil then
        data = cjson.decode(data)
    end

    return data
end

local content_type = request_headers["content-type"]
local request_body = "Unsupport Content Type"
local configs = ngx.shared.configs
local RAW_HEADERS = cjson.decode(configs:get("RAW_HEADERS"))

if content_type then
    for k, v in pairs(ngx_re.split(content_type, ";")) do
        if RAW_HEADERS[v] then
            request_body = compress_body(v)
            break
        end
    end
    log["request_body"] = request_body
end

ngx.ctx.log = log