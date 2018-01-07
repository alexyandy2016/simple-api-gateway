local config = ngx.shared.config

ngx.req.read_body()

local request = {
    request_id = ngx.var.request_id,
    http_version = ngx.req.http_version(),
    time_stamp = ngx.localtime(),
    request = {
        method = ngx.req.get_method(),
        headers = ngx.req.get_headers(50),
        path = ngx.var.uri,
        query = ngx.req.get_uri_args(20),
        body = ngx.req.get_post_args(20),
    }
}

ngx.ctx.request = request