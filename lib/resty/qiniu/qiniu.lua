local netutil = require('netutil')
local net= require("acid.net")
local httpclient = require("acid.httpclient")
local auth = require("resty.qiniu.auth")

local _M = {
    __version = "0.01"
}

local mt = {__index = _M}
local default_timeout = 600000

local function send_http_request(self, host, uri, method, headers, body)
    local ip = host

    if not net.is_ip4(host) then
        local ips, err_code, err_msg = netutil.get_ips_from_domain(host)
        if err_code ~= nil then
            return nil, err_code, err_msg
        end

        ip = ips[1]
    end

    local httpc = httpclient:new(ip, 80, self.timeout)

    local h_opts = {
        method = method,
        headers = headers,
        body = body,
    }

    local _, err_code, err_msg = httpc:request(uri, h_opts)
    if err_code ~= nil then
        return nil, err_code, err_msg
    end

    local read_body = function(size)
        return httpc:read_body(size)
    end

    return {
        status  = httpc.status,
        headers = httpc.headers,
        read_body = read_body,
    }
end

function _M.new(bucket, accesskey, secretkey, opts)
    local obj = {
        bucket = bucket,
        accesskey = accesskey,
        secretkey = secretkey,
    }

    obj.endpoint = opts.endpoint or 'rs.qiniu.com'
    obj.timeout = opts.timeout or default_timeout

    return setmetatable(obj, mt)
end

function _M.delete_object(self, object_name)
    local uri = '/delete/' .. ngx.encode_base64(self.bucket .. ':' .. object_name)
    local ct = 'application/x-www-form-urlencoded'

    local headers = {
        ['Date']          = ngx.http_time(ngx.time()),
        ['Content-Type']  = ct,
        ['Host']          = self.endpoint,
        ['Authorization'] = auth.calc_mgr(uri, '', ct, self.accesskey, self.secretkey),
    }

    local resp, err_code, err_msg =
        send_http_request(self, self.endpoint, uri, "POST", headers)
    if err_code ~= nil then
        return nil, err_code, err_msg
    end

    if resp.status ~= 200 and resp.status ~= 612 then
        local body, err_code, err_msg = resp.read_body(1024 * 1024)
        if err_code ~= nil then
            ngx.log(ngx.ERR, err_code, ':', err_msg)
        else
            ngx.log(ngx.ERR, body)
        end

        return nil, 'DeleteQiniuFileError', 'response status:' .. tostring(resp.status)
    end

    return nil, nil, nil
end

return _M
