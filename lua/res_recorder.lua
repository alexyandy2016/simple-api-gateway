--
-- User: tomczhen
-- DateTime: 2018-01-07
-- 
local cjson = require "cjson"
local resp = string.sub(ngx.arg[1], 1, 2000)

ngx.log(ngx.ERR, resp or "")