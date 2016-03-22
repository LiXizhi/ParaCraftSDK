--[[
Title: a simple NPL web server
Author: LiXizhi
Date: 2016/3/22 
Desc: start a web server from a local directory with build-in NPL web server module.
NPL web server supports php-like syntax, allowing you to create web applications easily.
Please install NPL language service for advanced page editing experience in visual studio. 

## Install Guide
* Install NPL runtime first.    
* local root directory in `www/index.page`
* Run `npl main.lua` 
* in web browser, visit: http://localhost:8099/index.page
]] 

NPL.load("(gl)script/apps/WebServer/WebServer.lua");
WebServer:Start("www", "0.0.0.0", 8099);

NPL.this(function() end);