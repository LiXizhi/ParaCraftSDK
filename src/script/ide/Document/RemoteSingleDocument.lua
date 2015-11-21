--[[
Title: RemoteSingleDocument
Author(s): Leio
Date: 2009/2/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Document/RemoteSingleDocument.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Document/LocalSingleDocument.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
local RemoteSingleDocument = commonlib.inherit(CommonCtrl.LocalSingleDocument,{
	loadFunc = nil,
	saveFunc = nil,
	startPosition = nil,
});  
commonlib.setfield("CommonCtrl.RemoteSingleDocument",RemoteSingleDocument);
function RemoteSingleDocument:SetCanvas(canvas)
	self.canvas = canvas;
	Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas = canvas;
end
function RemoteSingleDocument:GetCanvas()
	return self.canvas;
end
function RemoteSingleDocument:SetStartPosition(pos)
	self.startPosition = pos;
end
function RemoteSingleDocument:GetStartPosition()
	return self.startPosition;
end
function RemoteSingleDocument:SetStaticCanvas(canvas)
	self.static_canvas = canvas;
end
function RemoteSingleDocument:GetStaticCanvas()
	return self.static_canvas;
end
function RemoteSingleDocument:Load(uid)
	Map3DSystem.App.HomeZone.app:GetMCML(uid, function(uid, app_key, bSucceed, profile)
			if(bSucceed) then
				--_guihelper.MessageBox("加载成功！");
				local data = profile.data;
				self:SetData(data);
			else
				--_guihelper.MessageBox("加载失败！");
			end
			if(self.loadFunc)then
				self.loadFunc(bSucceed);
			end
		end,Map3DSystem.localserver.CachePolicies["never"])
end
function RemoteSingleDocument:Save()
	local static_canvas_str =  self:GetStr(self.static_canvas);
	local canvas_str =  self:GetStr(self.canvas);

	local result = string.format('<Room><StaticValue>%s</StaticValue><CustomValue>%s</CustomValue></Room>',static_canvas_str,canvas_str);
	local profile = {};
	profile.data = result;
	Map3DSystem.App.HomeZone.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				--_guihelper.MessageBox("保存成功！");
			else
				--_guihelper.MessageBox("保存失败！");
			end	
			if(self.saveFunc)then
				self.saveFunc(bSucceed);
			end
		end)
end
function RemoteSingleDocument:GetStr(canvas)
	if(not canvas)then return "" end
	local canvas_str = "";
	canvas_str = canvas:ToMcml();
	local __,__,__,canvas_str = string.find(canvas_str,"<Room(.-)>(.-)</Room>")
	canvas_str = canvas_str or "";
	
	return canvas_str;
end
function RemoteSingleDocument:Clear()
	if(self.static_canvas)then
		self.static_canvas:Clear();
	end
	if(self.canvas)then
		self.canvas:Clear();
	end
end
function RemoteSingleDocument:DoParse(s)
	if(not s)then return end;
	local xmlRoot = ParaXML.LuaXML_ParseString(s);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");		
		-- root: pe:storyboards
		local rootNode;
		for rootNode in commonlib.XPath.eachNode(xmlRoot, "//CustomValue") do
			if(rootNode) then
				local child;
				for child in rootNode:next() do
					if(child)then
						NPL.load("(gl)script/ide/Display/Util/ObjectsMcmlParser.lua");
						local lite3DCanvas = CommonCtrl.Display.Util.ObjectsMcmlParser.create(child);
						self:SetCanvas(lite3DCanvas);	
						end
					break;		
				end	
			end
			break;	
		end		
		for rootNode in commonlib.XPath.eachNode(xmlRoot, "//StaticValue") do
			if(rootNode) then
				local child;
				for child in rootNode:next() do
					if(child)then
						NPL.load("(gl)script/ide/Display/Util/ObjectsMcmlParser.lua");
						local lite3DCanvas = CommonCtrl.Display.Util.ObjectsMcmlParser.create(child);
						self:SetStaticCanvas(lite3DCanvas);	
						end
					break;		
				end	
			end
			break;	
		end			
	end
end
