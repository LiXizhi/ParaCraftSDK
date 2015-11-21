--[[
Title: A helper class for applications. 
Author(s): LiXizhi
Date: 2007/12/28
Desc: Such as cross application messaging, integration points, etc
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/AppHelper.lua");
------------------------------------------------------------
]]

-- requires

if(not Map3DSystem.App.AppHelper) then Map3DSystem.App.AppHelper={}; end

----------------------------------------
-- integration points related. 
----------------------------------------
if(not Map3DSystem.App.IP) then Map3DSystem.App.IP={}; end

-- add an application action feed to ActionFeedBar. More info please see the ActionFeedBar doc. 
function Map3DSystem.App.IP.AddActionFeed(msg)
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/ActionFeedBar.lua");
	Map3DSystem.UI.ActionFeedBar.AddFeed(msg);
end

-------------------------------------------
-- client world database related. 
-------------------------------------------

if(not Map3DSystem.App.worlddb) then Map3DSystem.App.worlddb={}; end

-- UNTESTED: install an application to the current world's attribute table. 
-- This will ensure the app is downloaded and installed before the world can be loaded. 
-- it basically add an entry in the apps table of the clientworld.attribute.db
function Map3DSystem.App.worlddb.InstallApp(app_key)

	local db = ParaWorld.GetAttributeProvider();
	db:SetTableName("WorldInfo");
	local AppList = db:GetAttribute("AppList", "");
	
	local key;
	local alreadyexist;
	for key in string.gfind(AppList, "(.*);") do
		if(key == app_key) then
			alreadyexist = true;
			break;
		end
	end
	
	if(not alreadyexist) then
		AppList = AppList..app_key..";"
		db:SetAttribute("AppList", AppList);
	end
end

-- UNTESTED: remove an application from the current world's attribute table
-- this will not make the app a prerequisites to run the world
function Map3DSystem.App.worlddb.RemoveApp(app_key)
	local db = ParaWorld.GetAttributeProvider();
	db:SetTableName("WorldInfo");
	local AppList = db:GetAttribute("AppList", "");
	
	local key;
	local alreadyexist;
	local NewAppList = "";
	local exist;
	for key in string.gfind(AppList, "(.*);") do
		if(key ~= app_key) then
			NewAppList = NewAppList..key..";";
		else
			exist = true;
		end
	end
	if(exist) then
		db:SetAttribute("AppList", NewAppList);
	end	
end

-- UNTESTED: load all attributes of a given application that is stored in the current world's attribute table
-- Note1:  application attributes can be loaded or saved to the current world even when the application is not installed in the world. 
-- Note2:  this function will check the database each time. So call this once at application render box function. 
-- return the application attribute table or nil
function Map3DSystem.App.worlddb.LoadAppAttributes(app_key)
	local db = ParaWorld.GetAttributeProvider();
	db:SetTableName("WorldInfo");
	local atts_string = db:GetAttribute(app_key, "");
	local atts = commonlib.LoadTableFromString(atts_string);
end

-- UNTESTED: save all attributes of a given application to the current world's attribute table
-- Note1:  application attributes can be loaded or saved to the current world even when the application is not installed in the world. 
-- Note2:  this function will write to the database each time. So call this once at world saving time for each application. 
function Map3DSystem.App.worlddb.SaveAppAttributes(app_key, atts)
	local db = ParaWorld.GetAttributeProvider();
	db:SetTableName("WorldInfo");
	local atts_string = commonlib.serialize(atts);
	db:SetAttribute(app_key, atts_string);
end
