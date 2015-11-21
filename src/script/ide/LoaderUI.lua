--[[
Title: Loader UI: animated when scene is loading.
Author(s): LiXizhi
Date: 2006/9/29
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/LoaderUI.lua");
CommonCtrl.LoaderUI.Start(100);
CommonCtrl.LoaderUI.SetProgress(40);
CommonCtrl.LoaderUI.SetProgress(90);
CommonCtrl.LoaderUI.SetProgress(100);
CommonCtrl.LoaderUI.End();
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");
--[[common control library]]
if(not CommonCtrl) then CommonCtrl={}; end
LoaderUI = {
	TotalSteps = 100,
	CurrentStep = 0,
	-- progress control position
	alignment = "_ct",
	left = -100,
	top = 150,
	width = 200,
	height = 70,
	-- background image and position
	Logo_Texture = nil,
	Logo_alignment = "_ct",
	Logo_left = -128,
	Logo_top = -128,
	Logo_width = 256,
	Logo_height = 256,
	-- parent name 
	parent = nil,
	name = "LoaderUI_progress";
};
CommonCtrl.LoaderUI = LoaderUI;

-- call this function to start the progress.
function LoaderUI.Start(nTotalSteps)
	local self = LoaderUI;
	if(nTotalSteps == nil) then
		nTotalSteps = 100;
	end
	self.TotalSteps = nTotalSteps;
	self.CurrentStep = 0;
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		_this=ParaUI.CreateUIObject("container",self.name, "_fi",0,0,0,0);
		_this.background="Texture/whitedot.png";
		_this:SetCurrentState("normal");
		_this:GetTexture("background").color="0 0 0";
		
		local _parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		if(self.Logo_Texture~=nil and self.Logo_Texture~="") then
			_this = ParaUI.CreateUIObject("button", "logo",self.Logo_alignment,self.Logo_left,self.Logo_top,self.Logo_width,self.Logo_height);
			_this.background = self.Logo_Texture;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		
		_this=ParaUI.CreateUIObject("container","bg", self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;
		
		_this=ParaUI.CreateUIObject("text","text", "_lt",0,0,120,20);
		_this.text = L"Loading ...";
		_this:GetFont("text").color = "255 255 0";
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button",self.name.."_btn", "_lt",0,30,20,7);
		_this.background="Texture/whitedot.png";
		_parent:AddChild(_this);
	end
end	

--[[ set the current progress
@param CurrentStep: current progress, such as 20, 40, 100,
@param disableRender: if nil, the GUI will be forced to render to reflect the changes.
]]
function LoaderUI.SetProgress(CurrentStep, disableRender)
	local self = LoaderUI;
	self.CurrentStep = CurrentStep;
	
	local _this = ParaUI.GetUIObject(self.name.."_btn");
	if(_this:IsValid() == true) then
		_this.width = self.width*self.CurrentStep/self.TotalSteps;
		if(not disableRender) then
			ParaEngine.ForceRender();
		end
	end		
end

function LoaderUI.End()
	local self = LoaderUI;
	ParaUI.Destroy(self.name);
end
