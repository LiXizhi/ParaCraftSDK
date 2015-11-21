--[[
Title: Registrations for applications. 
Author(s): LiXizhi
Date: 2007/12/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/AppRegistration.lua");
------------------------------------------------------------
]]

-- requires
NPL.load("(gl)script/kids/3DMapSystemApp/appkeys.lua");
NPL.load("(gl)script/sqlite/sqlite3.lua");
----------------------------------------
-- app client database 
----------------------------------------
if(not Map3DSystem.App.Registration) then Map3DSystem.App.Registration={}; end

-- default app database path
Map3DSystem.App.Registration._AppDBFilePath = "Database/apps.db";

-- UNTESTED: connect to the client's application database. It is a database stored at Database/apps.db
-- it is safe to call this function as many times as you like, since it will maintain the database connection. 
-- it will return the application database object. 
function Map3DSystem.App.Registration.ConnectToAppDB()
	if(Map3DSystem.App.Registration._AppDB == nil) then
		if( ParaIO.DoesFileExist( Map3DSystem.App.Registration._AppDBFilePath,true))then
			local err;
			Map3DSystem.App.Registration._AppDB, err = sqlite3.open( Map3DSystem.App.Registration._AppDBFilePath);
			if( Map3DSystem.App.Registration._AppDB == nil)then
				log("error: failed connecting to application db\n");
				if( err ~= nil)then
					log(err.."\n");
				end
				commonlib.log("application db may be corrupted, we will regenerate it\n")
				ParaIO.DeleteFile(Map3DSystem.App.Registration._AppDBFilePath);
				Map3DSystem.App.Registration.RecreateAppDB();
			end
		else
			log("warning: app database file does not exist, we will now try to create a new one.\n");
			Map3DSystem.App.Registration.RecreateAppDB();
		end
		
		local db = Map3DSystem.App.Registration._AppDB;
		if(db) then
			local app_count;
			local stmt, error = db:prepare([[select count(*) from apps]]);
			if(stmt) then
				app_count = stmt:first_cols()
				stmt:close();
			end
			if(not app_count or app_count<=0) then
				log("error: errors found in application db\n");
				ParaIO.DeleteFile(Map3DSystem.App.Registration._AppDBFilePath);
				Map3DSystem.App.Registration.RecreateAppDB();
			else
				commonlib.log("application database has %d installed apps\n", app_count)	;
			end
		end	
	end	
	return Map3DSystem.App.Registration._AppDB;
end

-- recreate app database file. 
function Map3DSystem.App.Registration.RecreateAppDB()
	local err;
	Map3DSystem.App.Registration._AppDB, err = sqlite3.open( Map3DSystem.App.Registration._AppDBFilePath);
	if( Map3DSystem.App.Registration._AppDB ~= nil)then
		Map3DSystem.App.Registration._AppDB:exec([[
CREATE TABLE [apps] (
[listorder] INTEGER DEFAULT 0, 
[app_key] VARCHAR(128) NOT NULL, 
[name] VARCHAR, 
[version] VARCHAR, 
[url] VARCHAR, 
[author] VARCHAR, 
[lang] VARCHAR, 
[IP] VARCHAR, 
[packageList] VARCHAR, 
[onloadscript] VARCHAR, 
[callbackfunction] VARCHAR,
[UserAdded] INTEGER);

]])	

--[[
INSERT INTO apps VALUES (NULL, 'EditApps_GUID', 'EditApps', '1.0.0', 'http://www.paraengine.com/apps/EditApps_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/EditApps/IP.xml', '', 'script/kids/3DMapSystemApp/EditApps/app_main.lua', 'Map3DSystem.App.EditApps.MSGProc', 1);				  
INSERT INTO apps VALUES (NULL, 'Map_GUID', 'Map', '1.0.0', 'http://www.paraengine.com/apps/Map_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Map/IP.xml', '', 'script/kids/3DMapSystemUI/Map/app_main.lua', 'Map3DSystem.App.Map.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'EBook_GUID', 'EBook', '1.0.0', 'http://www.paraengine.com/apps/EBook_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/EBook/IP.xml', '', 'script/kids/3DMapSystemUI/EBook/app_main.lua', 'MyCompany.Apps.EBook.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'BCS_GUID', 'BCS', '1.0.0', 'http://www.paraengine.com/apps/BCS_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/BCS/IP.xml', '', 'script/kids/3DMapSystemUI/BCS/app_main.lua', 'Map3DSystem.App.BCS.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'CCS_GUID', 'CCS', '1.0.0', 'http://www.paraengine.com/apps/CCS_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/CCS/IP.xml', '', 'script/kids/3DMapSystemUI/CCS/app_main.lua', 'Map3DSystem.App.CCS.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Chat_GUID', 'Chat', '1.0.0', 'http://www.paraengine.com/apps/Chat_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Chat/IP.xml', '', 'script/kids/3DMapSystemUI/Chat/app_main.lua', 'Map3DSystem.App.Chat.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Env_GUID', 'Env', '1.0.0', 'http://www.paraengine.com/apps/Env_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Env/IP.xml', '', 'script/kids/3DMapSystemUI/Env/app_main.lua', 'Map3DSystem.App.Env.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Blueprint_GUID', 'Blueprint', '1.0.0', 'http://www.paraengine.com/apps/Blueprint_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/BlueprintApp/IP.xml', '', 'script/kids/3DMapSystemApp/BlueprintApp/app_main.lua', 'Map3DSystem.App.Blueprint.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'RoomHostApp_GUID', 'RoomHostApp', '1.0.0', 'http://www.paraengine.com/apps/RoomHostApp_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/RoomHostApp/IP.xml', '', 'script/kids/3DMapSystemApp/RoomHostApp/app_main.lua', 'Map3DSystem.App.RoomHostApp.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Inventory_GUID', 'Inventory', '1.0.0', 'http://www.paraengine.com/apps/Inventory_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Inventory/IP.xml', '', 'script/kids/3DMapSystemApp/Inventory/app_main.lua', 'Map3DSystem.App.Inventory.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'ActionFeed_GUID', 'ActionFeed', '1.0.0', 'http://www.paraengine.com/apps/ActionFeed_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/ActionFeed/IP.xml', '', 'script/kids/3DMapSystemApp/ActionFeed/app_main.lua', 'Map3DSystem.App.ActionFeed.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'ScreenShot_GUID', 'ScreenShot', '1.0.0', 'http://www.paraengine.com/apps/ScreenShot_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/ScreenShot/IP.xml', '', 'script/kids/3DMapSystemUI/ScreenShot/app_main.lua', 'MyCompany.Apps.ScreenShot.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Login_GUID', 'Login', '1.0.0', 'http://www.paraengine.com/apps/Login_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Login/IP.xml', '', 'script/kids/3DMapSystemApp/Login/app_main.lua', 'Map3DSystem.App.Login.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'NewWorld_GUID', 'NewWorld', '1.0.0', 'http://www.paraengine.com/apps/NewWorld_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/NewWorld/IP.xml', '', 'script/kids/3DMapSystemUI/NewWorld/app_main.lua', 'Map3DSystem.App.NewWorld.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Settings_GUID', 'Settings', '1.0.0', 'http://www.paraengine.com/apps/Settings_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Settings/IP.xml', '', 'script/kids/3DMapSystemUI/Settings/app_main.lua', 'Map3DSystem.App.Settings.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'ParaWorldIntro_GUID', 'ParaWorldIntro', '1.0.0', 'http://www.paraengine.com/apps/ParaWorldIntro_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/ParaworldIntro/IP.xml', '', 'script/kids/3DMapSystemUI/ParaworldIntro/app_main.lua', 'Map3DSystem.App.ParaWorldIntro.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'WebBrowser_GUID', 'WebBrowser', '1.0.0', 'http://www.paraengine.com/apps/WebBrowser_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/WebBrowser/IP.xml', '', 'script/kids/3DMapSystemApp/WebBrowser/app_main.lua', 'Map3DSystem.App.WebBrowser.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Painter_GUID', 'Painter', '1.0.0', 'http://www.paraengine.com/apps/Painter_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Painter/IP.xml', '', 'script/kids/3DMapSystemUI/Painter/app_main.lua', 'Map3DSystem.App.Painter.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'MiniMap_GUID', 'MiniMap', '1.0.0', 'http://www.paraengine.com/apps/MiniMap_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/MiniMap/IP.xml', '', 'script/kids/3DMapSystemUI/MiniMap/app_main.lua', 'Map3DSystem.App.MiniMap.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Groups_GUID', 'Groups', '1.0.0', 'http://www.paraengine.com/apps/Groups_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Groups/IP.xml', '', 'script/kids/3DMapSystemApp/Groups/app_main.lua', 'Map3DSystem.App.Groups.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Discussion_GUID', 'Discussion', '1.0.0', 'http://www.paraengine.com/apps/Discussion_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Discussion/IP.xml', '', 'script/kids/3DMapSystemApp/Discussion/app_main.lua', 'Map3DSystem.App.Discussion.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Homepage_GUID', 'Homepage', '1.0.0', 'http://www.paraengine.com/apps/Homepage_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Homepage/IP.xml', '', 'script/kids/3DMapSystemApp/Homepage/app_main.lua', 'Map3DSystem.App.Homepage.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Assets_GUID', 'Assets', '1.0.0', 'http://www.paraengine.com/apps/Assets_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Assets/IP.xml', '', 'script/kids/3DMapSystemApp/Assets/app_main.lua', 'Map3DSystem.App.Assets.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'tasks_GUID', 'tasks', '1.0.0', 'http://www.paraengine.com/apps/tasks_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/tasks/IP.xml', '', 'script/kids/3DMapSystemApp/tasks/app_main.lua', 'Map3DSystem.App.tasks.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'worlds_GUID', 'worlds', '1.0.0', 'http://www.paraengine.com/apps/worlds_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/worlds/IP.xml', '', 'script/kids/3DMapSystemApp/worlds/app_main.lua', 'Map3DSystem.App.worlds.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'profiles_GUID', 'profiles', '1.0.0', 'http://www.paraengine.com/apps/profiles_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/profiles/IP.xml', '', 'script/kids/3DMapSystemApp/profiles/app_main.lua', 'Map3DSystem.App.profiles.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'MyDesktop_GUID', 'MyDesktop', '1.0.0', 'http://www.paraengine.com/apps/MyDesktop_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/MyDesktop/IP.xml', '', 'script/kids/3DMapSystemUI/MyDesktop/app_main.lua', 'Map3DSystem.App.MyDesktop.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Creator_GUID', 'Creator', '1.0.0', 'http://www.paraengine.com/apps/Creator_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Creator/IP.xml', '', 'script/kids/3DMapSystemUI/Creator/app_main.lua', 'Map3DSystem.App.Creator.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'VideoRecorder_GUID', 'VideoRecorder', '1.0.0', 'http://www.paraengine.com/apps/VideoRecorder_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Movie/IP.xml', '', 'script/kids/3DMapSystemUI/Movie/app_main.lua', 'MyCompany.Apps.VideoRecorder.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'Inventor_GUID', 'Inventor', '1.0.0', 'http://www.paraengine.com/apps/Iventor_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Inventor/IP.xml', '', 'script/kids/3DMapSystemUI/Inventor/app_main.lua', 'MyCompany.Apps.Inventor.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'HomeZone_GUID', 'HomeZone', '1.0.0', 'http://www.paraengine.com/apps/HomeZone_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/HomeZone/IP.xml', '', 'script/kids/3DMapSystemUI/HomeZone/app_main.lua', 'Map3DSystem.App.HomeZone.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'HomeLand_GUID', 'HomeLand', '1.0.0', 'http://www.paraengine.com/apps/HomeLand_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/HomeLand/IP.xml', '', 'script/kids/3DMapSystemUI/HomeLand/app_main.lua', 'Map3DSystem.App.HomeLand.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'FireMaster_GUID', 'FireMaster', '1.0.0', 'http://www.paraengine.com/apps/FireMaster_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/FireMaster/IP.xml', '', 'script/kids/3DMapSystemUI/FireMaster/app_main.lua', 'Map3DSystem.App.FireMaster.MSGProc', 1);
INSERT INTO apps VALUES (NULL, 'FreeGrab_GUID', 'FreeGrab', '1.0.0', 'http://www.paraengine.com/apps/FreeGrab_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/FreeGrab/IP.xml', '', 'script/kids/3DMapSystemUI/FreeGrab/app_main.lua', 'Map3DSystem.App.FreeGrab.MSGProc', 1);

INSERT INTO apps VALUES (NULL, 'Developers_GUID', 'Developers', '1.0.0', 'http://www.paraengine.com/apps/Developers_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Developers/IP.xml', '', 'script/kids/3DMapSystemApp/Developers/app_main.lua', 'Map3DSystem.App.Developers.MSGProc', 1);

INSERT INTO apps VALUES (NULL, 'Debug_GUID', 'Debug', '1.0.0', 'http://www.paraengine.com/apps/Debug_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/DebugApp/IP.xml', '', 'script/kids/3DMapSystemApp/DebugApp/app_main.lua', 'Map3DSystem.App.Debug.MSGProc', 1);

INSERT INTO apps VALUES (NULL, 'MiniGames_GUID', 'MiniGames', '1.0.0', 'http://www.paraengine.com/apps/MiniGames_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/MiniGames/IP.xml', '', 'script/kids/3DMapSystemUI/MiniGames/app_main.lua', 'Map3DSystem.App.MiniGames.MSGProc', 1);

]]

-- Debug_GUID app is removed from Aries build
--INSERT INTO apps VALUES (NULL, 'Debug_GUID', 'Debug', '1.0.0', 'http://www.paraengine.com/apps/Debug_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/DebugApp/IP.xml', '', 'script/kids/3DMapSystemApp/DebugApp/app_main.lua', 'Map3DSystem.App.Debug.MSGProc', 1);

--INSERT INTO apps VALUES (NULL, 'chat_guid', 'chat', '1.0.0', 'http://www.paraengine.com/apps/chat_v1.zip', 'paraengine', 'zhCN', 'script/kids/3DMapSystemApp/Chat/IP.xml', '', '', 'Map3DSystem.UI.Chat.MSGProc', 1);

		log("a new application database is created and populated with default application data\n");
	else
		log("error: failed creating application db\n");
	end
end

-- UNTESTED: check if an application is downloaded and installed on the client's computer's db. 
-- @param app_key: id of the application
-- @return bInstalled, version: boolean of whether the application is installed, if it is true, the version contains the application version installed; otherwise it is nil. 
function Map3DSystem.App.Registration.CheckApp(app_key)
	local bInstalled;
	local version;
	
	local db = Map3DSystem.App.Registration.ConnectToAppDB();
	if(db~=nil) then
		local cmd = string.format("select app_key, version from apps where app_key='%s'", app_key);
		local row;
		for row in db:rows(cmd) do
			bInstalled = true;
			version = row.version;
		end
	end
	return bInstalled, version;
end

-- get application data from the database. this is faster than parsing IP.xml each time. 
-- @return: app table or nil
function Map3DSystem.App.Registration.GetApp(app_key)
	local app;
	local db = Map3DSystem.App.Registration.ConnectToAppDB();
	if(db~=nil) then
		local cmd = string.format("select * from apps where app_key='%s'", app_key);
		local row;
		for row in db:rows(cmd) do
			app = {};
			app.app_key = row.app_key;
			app.name = row.name;
			app.version = row.version;
			app.onloadscript = row.onloadscript;
			app.callbackfunction = row.callbackfunction;
			app.lang = row.lang;
			app.packageList = row.packageList;
			app.UserAdded = row.UserAdded;
		end
	end
	return app;
end

-- NOT tested: add or remove a given app at startup time. 
-- Note:  it will only remove  if app is uninstallable. 
-- @param app_key: app key
-- @param UserAdded: boolean whether to load the app at startup time. 
-- @return true if succeed. 
function Map3DSystem.App.Registration.AddRemoveAppOnStartup(app_key, UserAdded)
	if(UserAdded or not Map3DSystem.App.Registration.IsAppUninstallable(app_key)) then
		local app = Map3DSystem.App.Registration.GetApp(app_key); 
			
		if(app~=nil) then
			local db = Map3DSystem.App.Registration.ConnectToAppDB();
			if(db~=nil) then
				local nUserAdded;
				if(not UserAdded) then
					nUserAdded = 0;
					log(app_key.." has been removed on startup\n");
				else
					nUserAdded = 1;
					log(app_key.." has been added on startup\n");
				end
				db:exec(string.format("UPDATE apps SET UserAdded = %d WHERE app_key='%s';", nUserAdded, app_key));
				return true;
			end
		end
	end	
end

-- return true if app must not be uninstalled. 
function Map3DSystem.App.Registration.IsAppUninstallable(app_key)
	if(Map3DSystem.App.UninstallableKeys~=nil) then
		return Map3DSystem.App.UninstallableKeys[app_key];
	end
end

-- uninstall an application permanently from the application registration database. 
-- Note:  it will only uninstall if app is uninstallable. 
-- @return true if successfully uninstalled. 
function Map3DSystem.App.Registration.UninstallApp(app_key)
	if(not Map3DSystem.App.Registration.IsAppUninstallable(app_key)) then
		local db = Map3DSystem.App.Registration.ConnectToAppDB();
		if(db~=nil) then
			db:exec(string.format("DELETE FROM apps WHERE app_key = '%s'", app_key));
			log(app_key.." has been uninstalled.\n");
			return true;
		end	
	end
end

-- get application data from the database. this is faster than parsing IP.xml each time. 
-- @param app: it should be a table containing {app_key="any GUID"}
-- @param IP_file: file path of the IP.xml in the file. 
-- @param bSkipInsertDB: default to nil. if true, we will not insert it to DB
-- @return: app table or nil
function Map3DSystem.App.Registration.InstallApp(app, IP_file, bSkipInsertDB)
	-- 1) parse xml IP_file in to a table. 
	NPL.load("(gl)script/ide/XPath.lua");
	local xmlDocIP = ParaXML.LuaXML_ParseFile(IP_file);
	local app_data = {app_key = app.app_key, IP = IP_file};
	if(xmlDocIP~=nil) then
		local xpath = "/mcml:mcml/mcml:app";
		local result = commonlib.XPath.selectNodes(xmlDocIP, xpath);
		if(result~=nil and result[1]~=nil) then
			-- the attributes of the app node
			local attr = result[1].attr;
			if(attr~=nil) then
				app_data.version = attr.version;
				app_data.name = attr.name;
				app_data.lang = attr.lang;
				app_data.onloadscript = attr.onloadscript;
				app_data.callbackfunction = attr.callbackfunction;
				app_data.UserAdded = true;
			end
		end
		-- TODO: get package list
		app_data.packageList = ""
	elseif(IP_file) then
		LOG.std(nil, "warn", "App.Registration", "%s file not exist", IP_file);
	end
	
	if(not bSkipInsertDB) then
		-- 2) Insert or update entry in application database. 
		local db = Map3DSystem.App.Registration.ConnectToAppDB();
		if(db~=nil) then
			local app = Map3DSystem.App.Registration.GetApp(app_data.app_key); 
			
			if(app~=nil) then
				-- Not tested: 
				-- TODO: db:exec(string.format("UPDATE apps SET UserAdded = %d WHERE app_key='%s'", app_data.UserAdded, app_data.app_key));
				log("application already installed. Uninstall it first.\n\n");
				return app;
			else
				db:exec(string.format("INSERT INTO apps VALUES (NULL, '%s', '%s', '%s', '%s', 'YourCompany', '%s', '%s', '', '%s', '%s', 1);", 
					app_data.app_key, app_data.name, app_data.version, app_data.packageList, app_data.lang, app_data.IP, app_data.onloadscript, app_data.callbackfunction));
				
				log("A new application is installed. \n")
				log(commonlib.serialize(app_data))
			end
		end
	end	
	-- start up the app. 
	return Map3DSystem.App.AppManager.StartupApp(app_data);
end

-- install applications only if they are not installed
-- e.g. Map3DSystem.App.Registration.CheckInstallApps({ {app={app_key="Aries_GUID"}, IP_file="script/apps/Aries/IP.xml"}, })
-- @param apps: an array of {app, IP_file, bSkipInsertDB} to be passed to InstallApp
function Map3DSystem.App.Registration.CheckInstallApps(apps)
	local _, app_table
	for _, app_table in ipairs(apps) do
		if(app_table.app and app_table.app.app_key) then
			local app = System.App.AppManager.GetApp(app_table.app.app_key)
			if(not app) then
				Map3DSystem.App.Registration.InstallApp(app_table.app, app_table.IP_file, app_table.bSkipInsertDB);
			end
		end
	end
end