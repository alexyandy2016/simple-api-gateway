local zlib = require("zlib")
local cjson = require "cjson"
local ngx_re = require "ngx.re"

local RAW_HEADERS = {
    ['text/html'] = "",
    ['text/plain'] = "",
    ['text/xml'] = "",
    ['application/x-www-form-urlencoded'] = "",
    ['application/json'] = "",
    ['application/xml'] = "",
    ['application/javascript'] = "",
}

local request_headers = ngx.req.get_headers(20)

local request = {
    request_id = ngx.var.request_id,
    http_version = ngx.req.http_version(),
    method = ngx.req.get_method(),
    headers = request_headers,
    path = ngx.var.request_uri,
    query = ngx.req.get_uri_args(20),
}

local function compress_body()
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

    return data
end

local content_type = request_headers["content-type"]
local request_body = "Binary Body"

for k, v in pairs(ngx_re.split(content_type, ";")) do
    if RAW_HEADERS[v] then
        request_body = compress_body()
        break
    end
end

request["body"] = request_body

ngx.ctx.request = request
ngx.log(ngx.ERR, cjson.encode(request))