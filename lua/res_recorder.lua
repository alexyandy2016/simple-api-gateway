--
-- User: tomczhen
-- DateTime: 2018-01-07
-- 
local cjson = require "cjson"
local zlib = require("zlib")

local response_body = ngx.arg[1]

local function compress_body(res)
    local stream = zlib.inflate()
    local encoding = ngx.var.upstream_http_content_encoding
    local body = ""

    if encoding == 'gzip' or encoding == 'deflate' or encoding == 'deflate-raw' then
        body = stream(res)
    else
        body = res
    end

    return body
end

ngx.log(ngx.ERR, compress_body(response_body))