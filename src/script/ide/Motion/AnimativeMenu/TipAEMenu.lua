--[[
Title: 
Author(s): Leio Zhang
Date: 2008/6/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/AnimativeMenu/TipAEMenu.lua");
	local tipAEMenu = CommonCtrl.Motion.AnimativeMenu.TipAEMenu:new{
		alignment = "_lt",
		left = 0,
		top = 0,
		width = 550,
		height = 400, 
		parent = nil,
	}
	tipAEMenu:Show();

local rootnode = tipAEMenu.RootNode;
local node = CommonCtrl.TreeNode:new({Text = "Node1"});
rootnode:AddChild(node);
tipAEMenu:BoundMotion(node);

node = CommonCtrl.TreeNode:new({Text = "Node2"});
rootnode:AddChild(node);
tipAEMenu:BoundMotion(node);

node = CommonCtrl.TreeNode:new({Text = "Node3"});
rootnode:AddChild(node);
tipAEMenu:BoundMotion(node);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Motion/AnimativeMenu/AnimativeMenu.lua");
NPL.load("(gl)script/ide/common_control.lua");

--------------------------------------------------------------------------------------------------------------
local TipAEMenu = commonlib.inherit(CommonCtrl.Motion.AnimativeMenu.AnimativeMenuView, {
	name = "TipAEMenu_1",
	DefaultNodeHeight = 64,
	DefaultNodeWidth = 512,
	showType = "push", -- only "push"
	}
)
commonlib.setfield("CommonCtrl.Motion.AnimativeMenu.TipAEMenu",TipAEMenu);
function TipAEMenu:BuildMovieClip()
	local mc = CommonCtrl.Motion.AnimativeMenu.TipMenuMovieClip:new();
	return mc;
end
function TipAEMenu:NodeAlive(node)
	local alive , findNode= false,nil;
	local k,len = 1,self.RootNode:GetChildCount();
	for k=1,len do
		local child = self.RootNode:GetChild(k);
		if(child.Text == node.Text)then
			alive = true;
			findNode = child;
			break;
		end	
	end
	return alive,findNode;
end

--------------------------------------------------------------------------------------------------------------
local TipMenuMovieClip = commonlib.inherit(CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip, {
	name = "TipMenuMovieClip_1",
}
)
commonlib.setfield("CommonCtrl.Motion.AnimativeMenu.TipMenuMovieClip",TipMenuMovieClip);

function TipMenuMovieClip:BuildUI()
	local animativeMenuView = self.node.TreeView;
	local _parent = ParaUI.GetUIObject(animativeMenuView.name);

	local _this;
	--commonlib.echo({self.x,self.y,self.node.index});
	_this = ParaUI.CreateUIObject("container", self.name, "_lt", self.x,self.y,self.width,self.height)	
	_this.background = "";
	_this.visible = false;
	_parent:AddChild(_this);
	_parent = _this;	
	----bg
	--left,top,width,height=0,0,512,64;
	--_this = ParaUI.CreateUIObject("container", self.name.."bg", "_lt", left,top,width,height)
	--_this.background = "Texture/whitedot.png;";
	----_this.enabled = false;
	----_guihelper.SetUIColor(_this, "255 255 255 0");
	--_parent:AddChild(_this);	
	--text
	left,top,width,height=0,0,512,64;
	_this = ParaUI.CreateUIObject("text", self.name.."text", "_lt", left,top,width,height)
	_this.text = self.node.Text;
	_this.font="System;17;bold;true";
	_guihelper.SetFontColor(_this, "#606060");
	_this.shadow = true;
	_this:GetFont("text").format = 1+256; -- center and no clip
	_parent:AddChild(_this);
	
	--_this:SetScript("onmouseenter",
		--function(obj,self)	
			--local tipMenu = self.node.TreeView;		
			--tipMenu:RebornMotion(self.node);
		--end,self);	
	----close
	--left,top,width,height=470,16,32,32;
	--_this = ParaUI.CreateUIObject("button", self.name.."close", "_lt", left,top,width,height)
	--_this.background = "Texture/3DMapSystem/Chat/Delete.png";
	--local tieMenu_name = self.node.TreeView.name;
	--_parent:AddChild(_this);
	--
	--_this:SetScript("onclick",
		--function(obj,self)	
			--local tipMenu = self.node.TreeView;		
			--tipMenu:UnBoundMotion(self.node);
		--end,self);	
	
		
end

function TipMenuMovieClip:BuildEngine()
	-----engine
	local engine = CommonCtrl.Motion.AnimatorEngine:new();
	local animatorManager = CommonCtrl.Motion.AnimatorManager:new();
	
	local animator,layerManager;
		  ---- bg
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/AnimativeMenu/MotionLib/tipmenu_bg.xml", self.name.."bg");
		  --layerManager = CommonCtrl.Motion.LayerManager:new();	 		  
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		  -- text
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/AnimativeMenu/MotionLib/tipmenu_bg.xml", self.name.."text");
		  layerManager = CommonCtrl.Motion.LayerManager:new();	 		  
		  layerManager:AddChild(animator);
		  animatorManager:AddChild(layerManager);
		  ---- close
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/AnimativeMenu/MotionLib/tipmenu_bg.xml", self.name.."close");
		  --layerManager = CommonCtrl.Motion.LayerManager:new();	 		  
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		  
		  --set AnimatorManager value must be at last 
		  engine:SetAnimatorManager(animatorManager);
		  
		  engine.OnMotionEnd = CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip.OnMotionEnd;
          engine.OnTimeChange =CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip.OnTimeChange;
          engine.node = self.node;
          self.animatorEngine = engine;	  
end
function TipMenuMovieClip:SetPosition()
	if(self.node)then
		local menuView = self.node.TreeView;
		local showType = menuView.showType;
		self.width = menuView.DefaultNodeWidth;
		self.height = menuView.DefaultNodeHeight;
		local index = self.node.index;
		if(showType =="unpush" and index > 1)then
			local index = index - 1;
			local pnode = self.node.parent:GetChild(index);
			local preMc = pnode.mc;
			if(menuView.showDirection =="down")then
				self.y = self.height + preMc.y;
				
			elseif(menuView.showDirection =="up")then
				self.y = -self.height + preMc.y;
			elseif(menuView.showDirection =="left")then
				self.x = -self.width + preMc.x;
			elseif(menuView.showDirection =="right")then
				self.x = self.width + preMc.x;
			end		
		end
		if(showType =="push" )then
			
			local rootnode = menuView.RootNode;
			local len = rootnode:GetChildCount();
			local index = len - index;
			if(menuView.showDirection =="down")then
				self.y = self.height * (index);
			elseif(menuView.showDirection =="up")then
				self.y = -self.height * (index);
			elseif(menuView.showDirection =="left")then
				self.x = -self.width * (index);
			elseif(menuView.showDirection =="right")then
				self.x = self.width * (index);
			end		
		end
	end
end



	
	
