-- a simple NPL web server 
-- root directory in `www/index.page`
-- in web browser: http://localhost:8099/index.page

NPL.load("(gl)script/apps/WebServer/WebServer.lua");
WebServer:Start("www", "0.0.0.0", 8099);

NPL.this(function() end);