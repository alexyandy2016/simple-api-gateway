--
-- User: tomczhen
-- DateTime: 2018-01-10
--

local resp_headers = ngx.resp.get_headers()

ngx.ctx.log["respone_headers"] = resp_headers


