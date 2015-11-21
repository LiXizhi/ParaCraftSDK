--[[
Title: for managing (texture) asset that is mostly used only once during the application, such as game front page, on_load movie, etc.
Author(s): LiXizhi
Date: 2007/4/26
Desc: for managing asset that is mostly used only once during the application, such as game front page, on_load movie, etc.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/OneTimeAsset.lua");
CommonCtrl.OneTimeAsset.Add("Logo", "page1.bmp")
...
CommonCtrl.OneTimeAsset.Add("Logo", "page2.bmp")
...
CommonCtrl.OneTimeAsset.Add("Logo", nil)
or one can use CommonCtrl.OneTimeAsset.Unload("page2.bmp;0 0 100 100")
-------------------------------------------------------
]]
-- common library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary
local OneTimeAsset = {
	registry = {}, 
	error = "",
	print_error = commonlib.error,  
}
CommonCtrl.OneTimeAsset = OneTimeAsset;

-- Only one item is loaded at a time. So if we add multiple asset files to the same item name, 
-- the previous ones will be unloaded if they are not identical. 
-- @param ItemName: 
-- @param assetFileName:
function OneTimeAsset.Add(ItemName, assetFileName)
	local olditem = OneTimeAsset.registry[ItemName];
	if(olditem~=nil and olditem~=OneTimeAsset.GetFileName(assetFileName)) then
		OneTimeAsset.Unload(olditem);
	end
	OneTimeAsset.registry[ItemName] = assetFileName;
end

-- this will remove the paramters after the semicolon
-- e.g. OneTimeAsset.GetFileName("aaa.bmp;0 0 11 11") == "aaa.bmp"
function OneTimeAsset.GetFileName(assetFileName)
	if(type(assetFileName) == "string") then
		return string.gsub(assetFileName, "[:;][^/]*$", "")
	else
		return assetFileName;
	end	
end

-- call this function to unload the given asset
function OneTimeAsset.Unload(assetFileName)
	if(type(assetFileName) == "string") then
		-- here I just assume it is a texture
		-- log(OneTimeAsset.GetFileName(assetFileName).." is unloaded\r\n");
		ParaAsset.LoadTexture("",OneTimeAsset.GetFileName(assetFileName),1):UnloadAsset();
	end
end

