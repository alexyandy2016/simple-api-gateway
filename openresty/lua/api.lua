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

local REDIS_HOST = "redis"

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
    local c = config or {}

    local conf = {
        ["host"] = c.host or REDIS_HOST,
        ["port"] = c.port or 6379,
        ["database"] = c.database or 0,
        ["timeout"] = c.timeout or 1000,
        ["max_idle_time"] = c.keepalive or 10000,
        ["pool_size"] = c.pool_size or 100
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
        return error
    end
end

local function query_clinets(client)
    local c = client or "*"
    local res = {}
    local regex = "(.*):(?<ip>.*):(?<date>.*)"
    local redis_conn = init_redis()
    local keys_pattern = "reqs:" .. c .. ":*"
    local keys, error = redis_conn:keys(keys_pattern)

    if not keys then
        return error
    end

    local tmp = {}
    for k, v in pairs(keys) do
        local m = ngx.re.match(v, regex, "jo")
        if not tmp[m.ip] then
            tmp[m.ip] = { ["client"] = m.ip, ["uri"] = "/api/requests/" .. m.ip, ["requests"] = {} }
        end
        table.insert(tmp[m.ip]["requests"], { ["date"] = m.date, ["uri"] = "/api/requests/" .. m.ip .. "/" .. m.date })
    end

    for k, v in pairs(tmp) do
        table.insert(res, v)
    end

    return res
end

local function query_requests(path_params, query_params)
    local res = {}
    local ip = path_params.ip
    local date = path_params.date
    local keys_pattern = "reqs:" .. ip .. ":" .. date
    local redis_conn = init_redis()
    local key, error = redis_conn:zrange(keys_pattern, 0, -1)

    if not key then
        return error
    end

    for k, v in pairs(key) do
        table.insert(res, cjson.decode(v))
    end

    return res
end

local urls = {
    ["/api/requests"] = {
        ["GET"] = function(query_params)
            local clients = query_clinets()
            --if #clients == 0 then
            --    return status_message.HTTP_NOT_FOUND()
            --else
            return clients
            --end
        end
    },
    ["/api/requests/<ip>"] = {
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
    ["/api/requests/<ip>/<date>"] = {
        ["GET"] = function(path_params, query_params)
            local requests = query_requests(path_params)
            if #requests == 0 then
                return status_message.HTTP_NOT_FOUND()
            else
                return requests
            end
        end
    },
    ["/api"] = {
        ["GET"] = function()
        end
    }
}

local is_format = {
    ["ip"] = function(value)
        return true
    end,
    ["date"] = function(value)
        return true
    end
}

local function match_path_params(p1, p2)

    local regex = string.format("(?%s.*)", p1)
    local m = ngx.re.match(p2, regex, "jo")
    local k = ngx.re.match(p1, "^<(.*)>$", "jo")
    if m and k then
        return k[1], m[1]
    end
end

local function simple_routes(uri)

    local m = {
        ["path"] = "",
        ["params"] = {}
    }

    local p = ngx_re.split(uri, "/", nil, { pos = 2 })


    if #p == 0 then
        m["path"] = "/"
    end

    for k in pairs(urls) do
        local tmp = ngx_re.split(k, "/", nil, { pos = 2 })
        if #tmp == #p then
            for i = 1, #p do
                if p[i] == tmp[i] then
                else
                    local k, v = match_path_params(tmp[i], p[i])
                    if k then
                        m["params"][k] = v
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

local match = simple_routes(ngx.var.uri)
local method = ngx.req.get_method()
local response = ""

if match then

    local path = urls[match.path]

    if not path then
        response = status_message.HTTP_NOT_FOUND()
    else
        local func = path[method]
        if not func then
            local msg = string.format("路径 %s 的 %s 方法未实现", match.path, method)
            response = status_message.HTTP_METHOD_NOT_IMPLEMENTED(msg)
        else
            response = func(match.params, ngx.req.get_uri_args(20))
        end
    end
else
    response = status_message.HTTP_NOT_FOUND()
end

ngx.print(serialize(response))