--
-- User: tomczhen
-- DateTime: 2018-01-07
-- 
local cjson = require "cjson"
local zlib = require "zlib"
local ngx_re = require "ngx.re"

local configs = ngx.shared.configs
local RAW_HEADERS = cjson.decode(configs:get("RAW_HEADERS"))
local response_headers = ngx.ctx.response_headers
local content_type = response_headers["content-type"]
local content_encoding = response_headers["content-encoding"]
local resp_body = "Unsupport Content Type"

local function compress_body(c_type)
    local stream = zlib.inflate()
    local encoding = content_encoding
    local body = ngx.arg[1]
    local data = ""

    if encoding == 'gzip' or encoding == 'deflate' or encoding == 'deflate-raw' then
        data = stream(body)
    else
        data = body
    end

    if c_type == "application/json" and data ~= nil then
        data = cjson.encode(data)
    end

    return data
end

for k, v in pairs(ngx_re.split(content_type, ";")) do
    if RAW_HEADERS[v] then
        resp_body = compress_body(v)
        break
    end
end

if resp_body ~= "" then
    ngx.var.response_body = resp_body
end