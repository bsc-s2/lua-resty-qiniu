#   Name

lua-resty-qiniu

#   Status

This library is in alpha phase.

It is deployed in a test envinroment, after add completely test case,
production environment in the movement

#   Description

Lua implementation sdk of qiniu oss

# API

* [new](#new)
* [delete_object](#delete_object)

#   Synopsis

```lua

local resty_qiniu = require "resty.qiniu.qiniu"

local accessKey	  =   "your accessKey"
local secretKey	  =   "your secretKey"
local bucket      =   "your bucket"

local opts = {
    endpoint = 'your qiniu endpoint',
    timeout  = 'request timeout',
}

local key_name = 'your key name'

local client, err_code, err_msg = resty_qiniu.new(
    bucket, accessKey, secretKey, opts)
if err_code == nil then
     _, err_code, err_msg = client:delete_object(key_name)
end

if err_code ~= nil then
    ngx.log(ngx.ERR, 'delete qiniu file error. key_name:',
        key_name, ', err_code:', err_code, ', err_msg:', err_msg)

    return nil, 'DeleteQiniuError', err_msg
end

```

## new

`syntax: client, err_code, err_msg = new(bucket, accessKey, secretKey, opts)`

instantiate qiniu client, In case of failures, returns `nil` , `err_code` and a string describing the error.

An optional Lua table can be specified as the last argument to this method to specify various options:
* `endpoint`: Specifies http request domain
* `timeout`: Specifies http request timeout(in seconds), default 600s

## delete_object

`syntax: rst, err_code, err_msg = delete_object(key_name)`

delete object of qiniu , In case of failures, returns `nil` , `err_code` and a string describing the error.

#   Author

Wu Yipu (Œ‚“Â∆◊) <pengsven@gmail.com>

#   Copyright and License

The MIT License (MIT)

Copyright (c) 2017 Wu Yipu (Œ‚“Â∆◊) <pengsven@gmail.com>


