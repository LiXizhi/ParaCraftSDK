# Example Web Site

### Install Dependencies
Run following to install all required NPL packages
```
./update_packages.bat
```

### Start Server
To start the server at [[http://localhost:8099]], run
```
./run.bat
```
Or one can start with following under linux
```
npl "script/apps/WebServer/WebServer.lua"  port="80" root="www/"
```

Web server root directory is `www/` 

### Server Log
- error log is at `./log.txt`
- access log is at `./log/access.log`
- database files are at `/Database/npl/` folder

### Links
- Testing page is at: [[http://localhost:8099/dev/test.page]]
- Debugger page is at: [[http://127.0.0.1:8099/]]
- Learning NPL: [[https://github.com/LiXizhi/NPLRuntime/wiki]]
