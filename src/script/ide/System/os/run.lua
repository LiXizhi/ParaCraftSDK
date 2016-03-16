--[[
Title: run command lines
Author(s): LiXizhi
Date: 2016/1/8
Desc: run command lines (batch commands). 
Currently only win32 is supported. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/os/run.lua");
local stdout = System.os("dir *.exe \n svn info");
commonlib.log(stdout);
------------------------------------------------------------
]]
local os = commonlib.gettable("System.os");

-- same as os.run(cmd);
setmetatable(os, { __call = function(self, ...) return os.run(...); end})

-- run command line using default OS shell script.
-- @param cmd: any command lines (can be multiple lines), such as "dir \n svn info"
-- @param bPrintToLog: true to print to log file, default to false
-- @param bDeleteTempFile: true to delete temp file, default to false
function os.run(cmd, bPrintToLog, bDeleteTempFile)
	if(os.GetPlatform()=="win32") then
		-- window 32 desktop platform
		-- write command script to a temp file and redirect all of its output to another temp file
		local cmd_filename = "temp.bat";
		local output_filename = "temp.txt";
		local cmd_fullpath = ParaIO.GetWritablePath()..cmd_filename;
		local output_fullpath = ParaIO.GetWritablePath()..output_filename;
		ParaIO.DeleteFile(output_filename)
		local file = ParaIO.open(cmd_filename, "w");
		if(file:IsValid()) then
			file:WriteString(format([[
@echo off
call :sub >"%%~dp0%s"
exit /b
:sub
]], output_filename));
			file:WriteString(cmd);
			file:close();
		end	
	
		local stdout_text = nil;
		-- we will use ShellExecuteEx to wait for the process to terminate and then retrieve output. 
		if(ParaGlobal.ShellExecute("wait", cmd_fullpath, cmd_fullpath, "", 1)) then
			-- get output
			local file = ParaIO.open(output_filename, "r");
			if(file:IsValid()) then
				stdout_text = file:GetText();
				file:close();
			end
			ParaIO.DeleteFile(output_filename);

			-- output to log.txt
			if(bPrintToLog and stdout_text and stdout_text~="") then
				commonlib.log(stdout_text);
			end
		end
		if(bDeleteTempFile) then
			ParaIO.DeleteFile(cmd_filename);
		end
		return stdout_text;
	else
		log("run shell script is not supported on this platform\n");
	end
end

-- run as administrator. only works on windows, tested on win10. 
-- it will pop up a dialog asking for permission. 
-- @return please note, since another process is created. this function does not return the output of the command
-- and this function may return before the command is finished. 
function os.runAsAdmin(cmd)
	return System.os([[
@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
IF '%PROCESSOR_ARCHITECTURE%' EQU 'amd64' (
	>nul 2>&1 "%SYSTEMROOT%\SysWOW64\icacls.exe" "%SYSTEMROOT%\SysWOW64\config"
	) ELSE (
	>nul 2>&1 "%SYSTEMROOT%\system32\icacls.exe" "%SYSTEMROOT%\system32\config"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
	echo Requesting administrative privileges...
	goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
	echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	set params = %*:"=""
	echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

	"%temp%\getadmin.vbs"
	del "%temp%\getadmin.vbs"
	exit /B

:gotAdmin
	pushd "%CD%"
	CD /D "%~dp0"
:--------------------------------------    
]]..cmd);
end