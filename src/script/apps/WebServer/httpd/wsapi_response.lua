--[[
Title: optional helper functions
Author: ported by LiXizhi, most code is based on Xavante
Date: 2011-6-27
Desc: wsapi.response offers a simpler interface (along with buffering) for output instead of 
the inversion of control of the iterator. It also lets you easily send cookies back to the browser.

wsapi.response.new([status, headers]) - creates a new response object, optionally setting an initial status code and header table. If a Content-Type was not passed in the initial header table then sets it as "text/html". The default status code is 200

res.status - status code to be returned to server

res.headers - table with headers to be returned to server

res:content_type(mime) - sets the Content-Type header to mime

res:write(...) - adds the arguments to the body, flattening an argument if it is a table

res:set_cookie(name, value) - sets the value of a cookie, value can be either a string or a table with fields value, expires (expiration date), domain, path, and secure. All fields except value are optional

res:delete_cookie(name, path) - tells the browser to erase a cookie, with an optional path

res:redirect(url) - sets status and headers for a redirect response to url, and returns a WSAPI response that does the redirect

res:forward(uri) - sets the PATH_INFO metavariable to uri (if not nil) and returns a mk FORWARD response to tell mk to keep trying to find a request handler

res:finish() - finishes response, returning status, headers and an iterator for the body

-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/httpd/wsapi_response.lua");
local response = commonlib.gettable("commonlib.wsapi.response");
-----------------------------------------------
]]
NPL.load("(gl)script/apps/WebServer/httpd/wsapi_util.lua");
local util = commonlib.gettable("commonlib.wsapi.util")

local date = os.date
local format = string.format

local response = commonlib.module("commonlib.wsapi.response")

methods = {}
methods.__index = methods

function methods:write(...)
  for _, s in ipairs{ ... } do
    if type(s) == "table" then
      self:write(unpack(s))
    elseif s then
      local s = tostring(s)
      self.body[#self.body+1] = s
      self.length = self.length + #s
    end
  end
end

function methods:forward(url)
  self.env.PATH_INFO = url or self.env.PATH_INFO
  return "MK_FORWARD"
end

function methods:finish()
  self.headers["Content-Length"] = self.length
  return self.status, self.headers, coroutine.wrap(function ()
    for _, s in ipairs(self.body) do
     coroutine.yield(s)
    end
  end)
end

local function optional (what, name)
  if name ~= nil and name ~= "" then
    return format("; %s=%s", what, name)
  else
    return ""
  end
end

local function make_cookie(name, value)
  local options = {}
  if type(value) == "table" then
    options = value
    value = value.value
  end
  local cookie = name .. "=" .. util.url_encode(value)
  if options.expires then
    local t = date("!%A, %d-%b-%Y %H:%M:%S GMT", options.expires)
    cookie = cookie .. optional("expires", t)
  end
  cookie = cookie .. optional("path", options.path)
  cookie = cookie .. optional("domain", options.domain)
  cookie = cookie .. optional("secure", options.secure)
  return cookie
end

function methods:set_cookie(name, value)
  local cookie = self.headers["Set-Cookie"]
  if type(cookie) == "table" then
    table.insert(self.headers["Set-Cookie"], make_cookie(name, value))
  elseif type(cookie) == "string" then
    self.headers["Set-Cookie"] = { cookie, make_cookie(name, value) }
  else
    self.headers["Set-Cookie"] = make_cookie(name, value)
  end
end

function methods:delete_cookie(name, path)
  self:set_cookie(name, { value =  "xxx", expires = 1, path = path })
end

function methods:redirect(url)
  self.status = 302
  self.headers["Location"] = url
  self.body = {}
  return self:finish()
end

function methods:content_type(type)
  self.headers["Content-Type"] = type
end

function new(status, headers)
  status = status or 200
  headers = headers or {}
  if not headers["Content-Type"] then
    headers["Content-Type"] = "text/html"
  end
  return setmetatable({ status = status, headers = headers, body = {}, length = 0 }, methods)
end
