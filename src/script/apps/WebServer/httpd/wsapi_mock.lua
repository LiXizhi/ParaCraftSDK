--[[
Title: unit testing only
Author: ported by LiXizhi, most code is based on Xavante
Date: 2011-6-27
Desc: usually not needed at release time

make_handler(wsapi_app) - Creates a mock handler for testing the WSAPI application you pass in.

The resulting handler will be a table with three fields:

app - The app itself.

get - A function to perform GET requests.

post - A function to perform POST requests.

The get and post functions both accept the following arguments:

path (required) - The path to request. Do not include the query string, this is specified in params.

params (optional) - A table of query or form data parameters.

headers (optional) - Any request headers you wish to specify.

-----------------------------------------------
---+++ Testing WSAPI applications

WSAPI comes with a mock connector that can be used for testing. It provides methods to send requests to your application and format responses. 
Functionality such as assertions and validations is left entirely to the testing framework you choose to use. 
Here's a simple example of how to use the mock connector:

local connector = require "wsapi.mock"

function hello(wsapi_env)
  local headers = { ["Content-type"] = "text/html" }
  local function hello_text()
    coroutine.yield("hello world!")
  end
  return 200, headers, coroutine.wrap(hello_text)
end

local app = connector.make_handler(hello)

do
  local response, request = app:get("/", {hello = "world"})
  assert(response.code                    == 200)
  assert(request.request_method           == "GET")
  assert(request.query_string             == "?hello=world")
  assert(response.headers["Content-type"] == "text/html")
  assert(response.body                    == "hello world!")
end

-----------------------------------------------
]]

-----------------------------------------------------------------------------
-- Mock WSAPI handler for Unit testing
--
-- Author: Norman Clarke
-- Copyright (c) 2010 Kepler Project
--
-----------------------------------------------------------------------------

local mock = module("commonlib.wsapi.mock");

NPL.load("(gl)script/apps/WebServer/httpd/wsapi_common.lua");
local common = commonlib.gettable("commonlib.wsapi.common");

NPL.load("(gl)script/apps/WebServer/httpd/wsapi_request.lua");
local wsapi_request = commonlib.gettable("commonlib.wsapi.request");

-- Build a request that looks like something that would come from a real web
-- browser.
local function build_request(method, path, headers)
  local req = {
    GATEWAY_INTERFACE    = "CGI/1.1",
    HTTP_ACCEPT = "application/xml,application/xhtml+xml,text/html;q=0.9," ..
        "text/plain;q=0.8,image/png,*/*;q=0.5",
    HTTP_ACCEPT_CHARSET  = "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
    HTTP_ACCEPT_ENCODING = "gzip,deflate,sdch",
    HTTP_ACCEPT_LANGUAGE = "en-US,en;q=0.8",
    HTTP_CACHE_CONTROL   = "max-age=0",
    HTTP_CONNECTION      = "keep-alive",
    HTTP_HOST            = "127.0.0.1:80",
    HTTP_USER_AGENT      = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X " ..
        "10_6_4; en-US) AppleWebKit/534.3 (KHTML, like Gecko) " ..
        "Chrome/6.0.472.55",
    HTTP_VERSION         = "HTTP/1.1",
    REMOTE_ADDR          = "127.0.0.1",
    REMOTE_HOST          = "localhost",
    SCRIPT_NAME          = "wsapi_test",
    SERVER_NAME          = "localhost",
    SERVER_PORT          = "80",
    SERVER_PROTOCOL      = "HTTP/1.1"
  }

  req.PATH_INFO      = path
  req.REQUEST_METHOD = method:upper()
  req.METHOD         = req.REQUEST_METHOD
  req.REQUEST_PATH   = "/"

  if req.PATH_INFO == "" then req.PATH_INFO = "/" end

  for k, v in pairs(headers or {}) do req[k] = v end

  -- allow case-insensitive table key access
  setmetatable(req, {__index = function(t, k)
    return rawget(t, string.upper(k))
  end})
  return req
end

-- Override common's output handler to avoid writing headers
-- in the reponse body.
function common.send_output(out, status, headers, res_iter, write_method,res_line)
   common.send_content(out, res_iter, out:write())
end

-- Mock IO objects
local function make_io_object(content)
  local receiver = { buffer = content or "", bytes_read = 0 }

  function receiver:write(content)
    if content then
      self.buffer = self.buffer .. content
    end
  end

  function receiver:read(len)
    len = len or (#self.buffer - self.bytes_read)
    if self.bytes_read >= #self.buffer then return nil end
    local s = self.buffer:sub(self.bytes_read + 1, len)
    self.bytes_read = self.bytes_read + len
    if self.bytes_read > #self.buffer then self.bytes_read = #self.buffer end
    return s
  end

  function receiver:clear()
    self.buffer = ""
    self.bytes_read = 0
  end

  function receiver:reset()
    self.bytes_read = 0
  end

  return receiver
end

-- Build a GET request
local function build_get(path, params, headers)
  local req = build_request("GET", path, headers)
  req.QUERY_STRING = request.methods.qs_encode(nil, params)
  req.REQUEST_URI  = "http://" ..
      req.HTTP_HOST ..
      req.PATH_INFO ..
      req.QUERY_STRING

  return {
    env    = req,
    input  = make_io_object(),
    output = make_io_object(),
    error  = make_io_object()
  }
end

local function build_post(path, params, headers)
  local req          = build_request("POST", path, headers)
  local body         = request.methods.qs_encode(nil, params):gsub("^?", "")
  req.REQUEST_URI    = "http://" .. req.HTTP_HOST .. req.PATH_INFO
  req.CONTENT_TYPE   = "x-www-form-urlencoded"
  req.CONTENT_LENGTH = #body

  return {
    env    = req,
    input  = make_io_object(body),
    output = make_io_object(),
    error  = make_io_object()
  }
end

local function make_request(request_builder, app, path, params, headers)
  local wsapi_env = request_builder(path, params, headers)
  local response = {}
  response.code, response.headers = wsapi.common.run(app, wsapi_env)
  response.body = wsapi_env.output:read()
  response.wsapi_errors = wsapi_env.error:read()
  return response, wsapi_env.env
end

local function get(self, path, params, headers)
  return make_request(build_get, self.app, path, params, headers)
end

local function post(self, path, params, headers)
  return make_request(build_post, self.app, path, params, headers)
end

--- Creates a WSAPI handler for testing.
-- @param app The WSAPI application you want to test.
function make_handler(app)
  return {
    app  = app,
    get  = get,
    post = post
  }
end
