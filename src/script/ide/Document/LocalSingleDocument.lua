--[[
Title: LocalSingleDocument
Author(s): Leio
Date: 2009/2/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Document/LocalSingleDocument.lua");
------------------------------------------------------------
]]
local LocalSingleDocument = {
	state = "new_noSaved", -- "new_noSaved" or "open_noChanged" or "open_changed"
}
commonlib.setfield("CommonCtrl.LocalSingleDocument",LocalSingleDocument);
function LocalSingleDocument:new(o)
	o = o or {};
	setmetatable(o, self)
	self.__index = self
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end
function LocalSingleDocument:SetCanvas(canvas)
	self.canvas = canvas;
end
function LocalSingleDocument:GetCanvas()
	return self.canvas;
end
function LocalSingleDocument:__DoParse(s)
	if(not s)then return end;
	local xmlRoot = ParaXML.LuaXML_ParseString(s);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");		
		-- root: pe:storyboards
		local rootNode;
		for rootNode in commonlib.XPath.eachNode(xmlRoot, "//LiteCanvas") do
			if(rootNode) then
				NPL.load("(gl)script/ide/Display/Util/ObjectsMcmlParser.lua");
				local lite3DCanvas = CommonCtrl.Display.Util.ObjectsMcmlParser.create(rootNode);
				self:SetCanvas(lite3DCanvas);
				return lite3DCanvas;
			end
		end			
	end
end
function LocalSingleDocument:Load()
	local file = ParaIO.open(self.filepath, "r");
	if(file:IsValid()) then
		local s = file:GetText();
		self:SetData(s);
		self:__DoParse(s)
		file:close();
		self.state = "open_noChanged";-- set the state of file	
	end	
	file:close();	
end
function LocalSingleDocument:Save()
	local file = ParaIO.open(self.filepath, "w");
	local result;
	if(self.canvas)then
		result =  self.canvas:ToMcml();
	end	
	if(file:IsValid()) then
		file:WriteString(result);
		file:close();
		self.state = "open_noChanged";-- set the state of file	
	end	
	file:close();	
end
function LocalSingleDocument:GetFilePath()
	return self.filepath;
end
function LocalSingleDocument:SetFilePath(path)
	self.filepath = path;
end
-- creat a new file in memory but not saved
function LocalSingleDocument:IsNew()
	if(self.state == "new_noSaved")then
		return true;
	end
end
-- return true if a existed file is just has been opened or a new file is just has been saved
function LocalSingleDocument:IsOpened()
	if(self.state == "open_noChanged")then
		return true;
	end
end
-- return true if a file changed the state of itself after opened
function LocalSingleDocument:IsChanged()
	if(self.state == "open_changed")then
		return true;
	end
end
-- a serialization value of this file
function LocalSingleDocument:SetData(s)
	self.data = s;
end
function LocalSingleDocument:GetData()
	return self.data;
end
function LocalSingleDocument:SetOpened()
	self.state = "open_noChanged"
end
function LocalSingleDocument:SetChanged()
	self.state = "open_changed"
end