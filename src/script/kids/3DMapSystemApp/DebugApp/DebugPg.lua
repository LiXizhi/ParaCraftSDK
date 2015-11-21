--[[
Title: code behind page for DebugPg.html
Author(s): CYF
Date: 2010年12月31日
Desc: Debug Page
use the lib:
------------------------------------------------------------
script/kids/3DMapSystemApp/DebugApp/DebugPg.html
-------------------------------------------------------
]]

local DebugPg = {};
commonlib.setfield("Map3DSystem.App.DebugApp.DebugPg", DebugPg);

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function DebugPg.OnInit()
	--local touid = document:GetPageCtrl():GetRequestParam("uid");
    --if(touid and touid~="") then
        --document:GetPageCtrl():SetNodeValue("receiver", "uid");
    --end
    --
    --local content = document:GetPageCtrl():GetRequestParam("content");
    --if(content and content~="") then
		--document:GetPageCtrl():SetNodeValue("content", content);
    --end
end

function DebugPg.OnClose()
	document:GetPageCtrl():CloseWindow();
end

-- user clicks to send the feed. 
function DebugPg.SendFeed(btnName, values)
	--local pageCtrl = document:GetPageCtrl();
	--local content = values["content"];
	--if(content and content~="") then
		--values["content"] = string.gsub(content, "[\r\n]" , "") -- remove return letters. 
		--
		--NPL.load("(gl)script/ide/XPath.lua");
		---- encode the content string
		--values["content"] = commonlib.XPath.XMLEncodeString(values["content"]);
--
		--pageCtrl:SetUIValue("result", "正在发送, 请稍候...");
		--local to_uids;
		--if(values["receiver"]~="all") then
			--values.uid = pageCtrl:GetRequestParam("uid")
		--end
		--
		--values.silentMode = true;
		--values.callbackFunc = function(issuccess)
			--if(issuccess) then
				--pageCtrl:SetUIValue("result", "发送成功");
			--else
				--pageCtrl:SetUIValue("result", "无法发送");
			--end	
		--end
		--Map3DSystem.App.Commands.Call("Profile.ActionFeed.Add", values)
	--else
		--pageCtrl:SetUIValue("result", "请输入正文");	
	--end	
end

-- open a dialog to select to which friends we will send the message. 
function DebugPg.SelectFriends(btnName)
	_guihelper.MessageBox("此功能稍后可用");
end