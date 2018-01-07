--
-- User: tomczhen
-- DateTime: 2018-01-07
--
local config = ngx.shared.config
local backend = os.getenv("BACKEND") or "ip.taobao.com"

config:set("BACKEND", backend)
