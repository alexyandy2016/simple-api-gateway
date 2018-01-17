--
-- User: tomczhen
-- DateTime: 2018-01-07
--
local cjson = require "cjson"
local configs = ngx.shared.configs
local backend = os.getenv("BACKEND") or "ip.taobao.com"
local raw_headers = {
    ['text/html'] = "",
    ['text/plain'] = "",
    ['text/xml'] = "",
    ['application/x-www-form-urlencoded'] = "",
    ['application/json'] = "",
    ['application/xml'] = "",
    ['application/javascript'] = "",
}

configs:set("BACKEND", backend)
configs:set("RAW_HEADERS", cjson.encode(raw_headers))