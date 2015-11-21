--[[
Title: Web tutorials
Author(s): LiXizhi
Date: 2015/10/1
Desc: singleton class that hook to global user events and show relevant tutorials to the user. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/WebTutorials.lua");
local WebTutorials = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.WebTutorials");
WebTutorials:Show();
WebTutorials:Dismiss();
WebTutorials:Close();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Window.lua");
local Window = commonlib.gettable("System.Windows.Window")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local WebTutorials = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.WebTutorials"));
WebTutorials:Property("Name", "WebTutorials");
WebTutorials:Property({"filename", "config/Aries/creator/WebTutorials.xml"});
WebTutorials:Property({"CurrentTutorial", nil, auto=true});
-- whenever the current tutorial is changed
WebTutorials:Signal("tutorialChanged", function(tutorial) end)

function WebTutorials:ctor()
	-- key to tutorial map
	self.tutorial_keymap = {};
	-- list of all tutorials
	self.tutorials = {};
	
	self:LoadAllTutorials();
	self.window = Window:new();
	self.window:SetCanDrag(true);
end

function WebTutorials:Init()
	self:InitSingleton();
end

function WebTutorials:GetWindow()
	return self.window;
end

function WebTutorials:AutoSelectTutorial()
	if(not self:GetCurrent()) then
		-- use intruduction as the current tutorial 
		self:SetCurrentTutorial("introduction");
	end
end

function WebTutorials:Show()
	if(System.options.IsMobilePlatform) then
		return;
	end
	self:InitSingleton();
	self:AutoSelectTutorial();
	GameLogic:Connect("userActed", self, self.OnUserAction, "UniqueConnection");

	self.window:Show({
			url="script/apps/Aries/Creator/Game/Areas/WebTutorials.html", 
			zorder = 10,
			alignment="_lt", left = 5, top = 70, width = 400, height = 80,
		});
	self.window:SetSizeToUsedSize();
end

function WebTutorials:Hide()
	self:GetWindow():hide();
end

function WebTutorials:Dismiss()
	if(self:GetCurrent()) then
		self:GetCurrent():Dismiss();
	end
	self:Hide();
end

function WebTutorials:Close()
	GameLogic:Disconnect("userActed", self, self.OnUserAction);
	self:Hide();
end

function WebTutorials:LoadAllTutorials()
	
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.filename);
	if(not xmlRoot) then
		LOG.std(nil, "warn", "WebTutorials", "failed to open file %s", self.filename);
	end
	for node in commonlib.XPath.eachNode(xmlRoot, "/WebTutorials/tutorial") do
		local attr = node.attr;
		local url = attr.url;
		if(not url and node[1]) then
			url = node[1][1];
		end
		attr.title = L(attr.title);
		attr.difficulty = tonumber(attr.difficulty) or 0;
		attr.url = url;
		self:AddTutorial(attr);
	end
	LOG.std(nil, "info", "WebTutorials", "opened file %s, load %d tutorials", self.filename, #(self.tutorials));
end

local Tutorial = commonlib.inherit(nil);

function Tutorial:ctor()
	self.showcount = 0;
end

function Tutorial:init(title, difficulty, url)
	self.title = title or self.title;
	self.difficulty = difficulty or self.difficulty;
	self.url = url or self.url;
	return self;
end

function Tutorial:AddShowCount()
	self.showcount = self.showcount + 1;
end

function Tutorial:GetID()
	return self.title or "";
end

function Tutorial:GetTitle()
	return self.title or "";
end

function Tutorial:IsDismissed()
	return self.isDismissed;
end

function Tutorial:Dismiss()
	self.isDismissed = true;
end

function Tutorial:GetDifficultyText()
	if(self.difficulty>=4) then
		return L"困难";
	elseif(self.difficulty>=2) then
		return L"普通";
	else
		return L"容易";
	end
end

function Tutorial:GetTimeLengthText()
	return format(L"%s分钟", self.length or "5");
end

function Tutorial:Play()
	ParaGlobal.ShellExecute("open", self.url, "", "", 1);
end

function WebTutorials:GetTutorialByKey(keyname)
	return self.tutorial_keymap[keyname];
end

-- get array of all tutorials.
function WebTutorials:GetTutorialList()
	return self.tutorials;
end

function WebTutorials:AddTutorial(attr)
	local tutorial = Tutorial:new(attr):init();
	if(tutorial.keywords) then
		for keyword in tutorial.keywords:gmatch("%s*([^,;]+)") do
			self.tutorial_keymap[keyword] = tutorial;
		end
		self.tutorials[#(self.tutorials)+1] = tutorial;
	end
end

function WebTutorials:SetCurrentTutorial(name)
	if(self.currentTutorialName ~= name) then
		local tutorial;
		if(name) then
			tutorial = self:GetTutorialByKey(name);
		end
		if(tutorial and tutorial:IsDismissed()) then
			return;
		end
		self.currentTutorialName = name;
		self.currentTutorial = tutorial;

		if(tutorial) then
			tutorial:AddShowCount();
			self.window:resize(400, 80);
			self.window:RefreshUrlComponent();
			self.window:SetSizeToUsedSize();
			self.window:show();
		end
		
		self:tutorialChanged(tutorial); -- signal
	end
end

-- return current tutorial name
function WebTutorials:GetCurrentTutorial()
	return self.currentTutorialName;
end

function WebTutorials:GetCurrent()
	return self.currentTutorial;
end

-- user has just acted on a given action. 
function WebTutorials:OnUserAction(name)
	if(not self:GetTutorialByKey(name or "")) then
		name = nil;
	end
	
	self:SetCurrentTutorial(name);
end
