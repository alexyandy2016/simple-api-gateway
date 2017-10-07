--
-- Created by IntelliJ IDEA.
-- User: tomczhen
-- Date: 17-10-4
-- Time: 下午7:04
-- To change this template use File | Settings | File Templates.
--
local ngx_re = require "ngx.re"
local redis = require "resty.redis"
local cjson = require "cjson"

local status_message = {
    ["HTTP_NOT_FOUND"] = function(message)
        local s = message or "Not Found"
        local msg = {
            ["message"] = string.format("%s", s)
        }
        ngx.status = ngx.HTTP_NOT_FOUND
        return msg
    end,
    ["HTTP_BAD_REQUEST"] = function(message)
        local s = message or "Bad Request"
        local msg = {
            ["message"] = string.format("%s", s)
        }
        ngx.status = ngx.HTTP_BAD_REQUEST
        return msg
    end,
    ["HTTP_METHOD_NOT_IMPLEMENTED"] = function(message)
        local s = message or "Method Not Implemented"
        local msg = {
            ["message"] = string.format("%s", s)
        }
        ngx.status = ngx.HTTP_METHOD_NOT_IMPLEMENTED
        return msg
    end
}

local function init_redis(config)
    local conf = {
        ["host"] = config.host or "127.0.0.1",
        ["port"] = config.port or 6379,
        ["database"] = config.database or 0,
        ["timeout"] = config.timeout or 1000,
        ["max_idle_time"] = config.keepalive or 10000,
        ["pool_size"] = config.pool_size or 100
    }
    local conn = redis:new()
    conn:set_timeout(conf.timeout)
    conn:set_keepalive(conf.max_idle_time, conf.pool_size)
    conn:connect(conf.host, conf.port)
    return conn
end

local function serialize(res, format)
    local serialize_format = format or "json"

    local fmt = {
        ["json"] = function()
            ngx.header["Content-Type"] = "application/json"
            return cjson.encode(res)
        end
    }

    local func = fmt[serialize_format] or fmt.json
    local response, error = func()

    if response then
        return response
    else
        return serialize(error)
    end
end

local function query_clinets(client)

    local c = client or "*"
    local redis_conn = init_redis({ host = "redis" })
    local keys_pattern = "reqs:" .. c .. ":*"
    local redis_keys, error = redis_conn:keys(keys_pattern)

    if not redis_keys then
        return error
    end

    if #redis_keys == 0 then
        local msg = string.format("Client : %s Not Found Any Requests", client)
        return status_message.HTTP_NOT_FOUND(msg)
    else
        return redis_keys
    end
end

local function query_requests(path_params, query_params)
    local ip = path_params[2] or "*"
    local time_stamp = params["time"] or ""

    local redis_conn = init_redis()
    local res, err = redis_conn:zrange("172.18.0.1:171011", 0, -1)

    if not res then
        return err
    end
    return res
end

local function is_format_ip(param)
    return false
end

local function is_format_date(param)
    return true
end

local query_params = ngx.req.get_uri_args(20)

local urls = {
    ["/clients"] = {
        ["GET"] = function(query_params)
            local clients = query_clinets()
            if #clients == 0 then
                return status_message.HTTP_NOT_FOUND()
            else
                return clients
            end
        end
    },
    ["/clients/<ip>"] = {
        ["GET"] = function(path_params, query_params)
            local client_ip = path_params.ip
            local clients = query_clinets(client_ip)

            if #clients == 0 then
                return status_message.HTTP_NOT_FOUND()
            else
                return clients
            end
        end
    },
    ["/requests"] = {
        ["GET"] = function(query_params)
            return query_requests()
        end
    },
    ["/requests/<ip>"] = {
        ["GET"] = function()
        end
    },
    ["/requests/<ip>/<date>"] = {
        ["GET"] = function()
        end
    },
    ["/"] = {
        ["GET"] = function()
        end
    }
}

local format = {
    ["ip"] = function(value)
        return true
    end,
    ["date"] = function(value)
        return true
    end,
    [""] = function(value)
        return true
    end,
    ["default"] = function(p1, p2)
        return p1 == p2
    end
}

local function split_uri(uri)
    return ngx_re.split(uri, "/", nil, { pos = 2 })
end

local function match_path_params(p1, p2)

    local regex = string.format("(?%s.*)$", p1)
    local m = ngx.re.match(p2, regex)

    return m
end

local function simple_router(uri)

    local m = {}
    local p = split_uri(uri)


    if #p == 0 then
        m["path"] = "/"
    end

    for k in pairs(urls) do
        local tmp = split_uri(k)
        if #tmp == #p then
            for i = 1, #p do
                if p[i] == tmp[i] then
                else
                    local n = match_path_params(tmp[i], p[i])
                    if n then
                        m["params"] = n
                    else
                        break
                    end
                end
                m["path"] = k
            end
        end
    end

    return m
end

local match = simple_router(ngx.var.uri)
local method = ngx.req.get_method()
local response = ""

if match then

    local path_func = urls[match.path]

    if not path_func then
        response = status_message.HTTP_NOT_FOUND()
    else
        local method_func = path_func[method]
        if not method_func then
            local msg = string.format("路径 %s 的 %s 方法未实现", match.path, method)
            response = status_message.HTTP_METHOD_NOT_IMPLEMENTED(msg)
        else
            response = func[method](match.params, ngx.req.get_uri_args(20))
        end
    end
else
    response = status_message.HTTP_NOT_FOUND()
end

ngx.print(serialize(response))