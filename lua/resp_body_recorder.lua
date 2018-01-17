--
-- User: tomczhen
-- DateTime: 2018-01-07
-- 
local cjson = require "cjson"
local zlib = require "zlib"
local ngx_re = require "ngx.re"

local function compress_body(c_type)
    local stream = zlib.inflate()
    local encoding = ngx.ctx.log["respone_headers"]["content-encoding"]
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

local content_type = ngx.ctx.log["respone_headers"]["content-type"]
local resp_body = "Unsupport Content Type"
local configs = ngx.shared.configs
local RAW_HEADERS = cjson.decode(configs:get("RAW_HEADERS"))

for k, v in pairs(ngx_re.split(content_type, ";")) do
    if RAW_HEADERS[v] then
        resp_body = compress_body(v)
        break
    end
end

ngx.ctx.log["respone_status"] = ngx.var.upstream_status

if resp_body ~= "" then
    ngx.ctx.log["respone_body"] = resp_body
    ngx.var.response_body = cjson.encode(resp_body)
end