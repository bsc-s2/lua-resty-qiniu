local _M = {}

function _M.calc_mgr(uri, body, content_type, ak, sk)
    if ak == nil or sk == nil then
        return nil
    end

    local str = uri .. '\n'
    if body ~= nil and content_type == 'application/x-www-form-urlencoded' then
        str = str .. body
    end

    local auth = ngx.encode_base64(ngx.hmac_sha1(sk, str))

    auth = auth:gsub("[+/]", function(c)
        if c == '+' then
            return '-'
        else
            return '_'
        end
    end)

    return 'QBox '.. ak .. ':' .. auth
end

return _M

