--[[
Title: 
Author(s): Leio Zhang
Date: 2008/6/26
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/AnimativeMenu/AnimativeMenu.lua");
local animativeMenu =CommonCtrl.Motion.AnimativeMenu.AnimativeMenuController:new();
animativeMenu:Init(_parent);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/TreeView.lua");
NPL.load("(gl)script/ide/Transitions/Tween.lua");
NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
NPL.load("(gl)script/ide/common_control.lua");


local AnimativeMenuView = {
	name = "AnimativeMenuView_1",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 400, 
	parent = nil,
	container_bg = nil, -- the background of container
	
	showDirection = "down", -- four directions:left right up down
	showType = "push", -- push or unpush,
	afterCreateNodeTweenPool = nil,
	afterDeadNodeTweenPool = nil,
	DefaultNodeHeight = 128,
	DefaultNodeWidth = 256,
	-- The root tree node. containing all tree node data
	RootNode = nil, 
	aliveNode = nil,
	insertIndex = nil,
	--event
	DeleteNodeEvent = nil,
}
commonlib.setfield("CommonCtrl.Motion.AnimativeMenu.AnimativeMenuView",AnimativeMenuView);
-- constructor
function AnimativeMenuView:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	-- create the root node
	o.RootNode = CommonCtrl.TreeNode:new({TreeView = o, Name = "RootNode", 
		NodeHeight = 0, -- so that root node is not drawn
	})	
	o.name = ParaGlobal.GenerateUniqueID();	
	o:Init()
	--CommonCtrl.AddControl(o.name, o);
	return o
end
-- get a string containing the node path. such as "0/1/1/3"
-- as long as the TreeNode does not change, the node path uniquely identifies a TreeNode.
function AnimativeMenuView:GetNodeByPath(path)
	local index; 
	local node = self.RootNode;
	for index in string.gfind(path, "(%d+)") do
		--log("ByPath:"..index.."\n")
		index = tonumber(index);
		if(index>0) then
			node = node.Nodes[index];
		end
		if(node == nil) then
			return
		end
	end
	return node;
end
function AnimativeMenuView:Init()
	self.afterCreateNodeTweenPool = CommonCtrl.Motion.AnimativeMenu.MenuViewTweenPool:new();	
end
function AnimativeMenuView.DeleteNodeEvent(node)

end
function AnimativeMenuView:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("AnimativeMenuView instance name can not be nil\r\n");
		return
	end
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		else
			_this.background="";
		end	
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		_this = _parent;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	
end
function AnimativeMenuView:BuildMovieClip()
	local mc = CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip:new();
	return mc;
end
function AnimativeMenuView:BoundMotion(node)
	--node:AddChild(CommonCtrl.TreeNode:new({Text = "Node2", mc = ""}));
		local mc = self:BuildMovieClip();
		node.mc = mc;
		mc:SetNode(node);
		self.insertIndex = node.index;
		local nodePath = node:GetNodePath();
		if( nodePath ~= "0/1" )then
			local tween = self:CreateNodeTween(node,1);
			tween.poolType = "add"
			self.afterCreateNodeTweenPool:Push(tween);
		else
			mc:DoPlay();
		end
end
function AnimativeMenuView:BoundMotionByNodePath(nodePath)
	local node = self:GetNodeByPath(nodePath);
	if(node)then
		self:BoundMotion(node);
	end
end
function AnimativeMenuView:UnBoundMotion(node)	
	local mc = node.mc;
	if(mc)then
		if(not mc:isPlaying())then
			mc:DoPlay();
		end
		mc:DoEnd();	
	end
end
function AnimativeMenuView:UnBoundMotionByNodePath(nodePath)
	local node = self:GetNodeByPath(nodePath);
	if(node)then
		self:UnBoundMotion(node);
	end
end
function AnimativeMenuView:DetachNode(node)
	local mc = node.mc;
	if(mc)then	
		node:Detach();
		mc:Destroy();
		node.mc = nil;
		local tween;
		tween = node.tween;
		if(tween)then
			-- tween is moving
			if(self.afterCreateNodeTweenPool.curTween)then
				if(self.afterCreateNodeTweenPool.curTween == tween)then
					tween:YoYo();
					tween:End()
					tween.poolType = "remove";
				else
					self.afterCreateNodeTweenPool:removeTween(tween);
				end	
			else
			-- all tween is stop 
				tween:YoYo();
				tween:End()
				tween.poolType = "remove";
			end
		end
		self.DeleteNodeEvent(node);
	end
end
function AnimativeMenuView:RebornMotion(node)
	local mc = node.mc;
	if(mc)then
		mc:DoPlay();
	end
end
function AnimativeMenuView:RebornMotionByNodePath(nodePath)
	local node = self:GetNodeByPath(nodePath);
	if(node)then
		self:RebornMotion(node);
	end
end
function AnimativeMenuView:SnapLiveNodes(position,node,poolType)
	local index = node.index;
	if(self.showType =="push")then
		if(index > 1)then
			for k = 1,index-1 do				
				local childNode = node.parent:GetChild(k);
				-- added by LXZ 2008.7.12. why childNode can be nil?
				if(childNode) then
					local mc = childNode.mc;
					self:SetMovieClipProperty(mc,position);
				end	
			end
		end
	else
		if(poolType =="remove")then
			local len = self.insertIndex or node.parent:GetChildCount();	
			for k = index,len do				
				local childNode = node.parent:GetChild(k);
				local mc = childNode.mc;
				self:SetMovieClipProperty(mc,position);		
			end
		end

	end
end
function AnimativeMenuView:SetMovieClipProperty(mc,position)
	local x_position = 0;
	local y_position = 0;
	if(mc.x_lastvalue)then
		x_position = position - mc.x_lastvalue;
	end
	if(mc.y_lastvalue)then
		y_position = position - mc.y_lastvalue;
	end
	if(self.showDirection =="down")then
		mc.y = mc.y + y_position;
		mc.y_lastvalue = position;
	elseif(self.showDirection =="up")then
		mc.y = mc.y - y_position;
		mc.y_lastvalue = position;
	elseif(self.showDirection =="left")then
		mc.x = mc.x + x_position;
		mc.x_lastvalue = position;
	elseif(self.showDirection =="right")then
		mc.x = mc.x - x_position;
		mc.x_lastvalue = position;
	end
		mc:Update();
		
end
-- 控制已经存在的nodes移动
-- @param node: 增加或者删除的一个node
function AnimativeMenuView:CreateNodeTween(node,direction)
	local temp_obj={property = nil};
	local _prop,_change;
	if(self.showDirection =="down" or self.showDirection =="up")then
		_change = self.DefaultNodeHeight * direction;
	elseif(self.showDirection =="left" or self.showDirection =="right")then
		_change =  self.DefaultNodeWidth * direction;
	end
	local tween=CommonCtrl.Tween:new{
						obj = temp_obj,
						prop= "property",
						begin = 0,
						change = _change,
						duration =0.2,
							}
	tween.func=CommonCtrl.TweenEquations.easeInQuad;
	tween.animativeMenuView = self;
	tween.node = node;
	node.tween = tween;
	return tween;
end
function AnimativeMenuView:ClearTempValue(node)
	local k,len = 1,node.parent:GetChildCount();
	for k = 1,len do
		local child = node.parent:GetChild(k);
			local mc = child.mc
			mc.x_lastvalue = nil;
			mc.y_lastvalue = nil;
	end
end
function AnimativeMenuView:SetAliveNode(node)
	self.aliveNode = node;
end
function AnimativeMenuView:DoPause()
	local aliveNode = self.aliveNode
	if(not aliveNode) then return; end
	local aliveMc = aliveNode.mc;
	if(aliveMc)then
		aliveMc:DoPause();
	end
end
function AnimativeMenuView:DoResume()
	local aliveNode = self.aliveNode
	if(not aliveNode) then return; end
	local aliveMc = aliveNode.mc;
	if(aliveMc)then
		aliveMc:DoResume();
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
local MenuViewMovieClip = {
	name = "",
	node = nil,
	animatorEngine = nil,
	x = 0,
	y = 0,
	width = 0,
	height = 0,
}
commonlib.setfield("CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip",MenuViewMovieClip);
-- constructor
function MenuViewMovieClip:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.name  = ParaGlobal.GenerateUniqueID();
	return o
end
function MenuViewMovieClip:SetNode(node)
	if(not node)then return ; end
	self.node = node;
	self:SetPosition();
	self:BuildUI();
	self:BuildEngine();
end
function MenuViewMovieClip:SetPosition()
	--if(self.node)then
		--local menuView = self.node.TreeView;
		--local showType = menuView.showType;
		--self.width = menuView.DefaultNodeWidth;
		--self.height = menuView.DefaultNodeHeight;
		--local index = self.node.index;
		--if(showType =="unpush" and index > 1)then
			--local index = index - 1;
			--local pnode = self.node.parent:GetChild(index);
			--local preMc = pnode.mc;
			--if(menuView.showDirection =="down")then
				--self.y = self.height + preMc.y;
			--elseif(menuView.showDirection =="up")then
				--self.y = -self.height + preMc.y;
			--elseif(menuView.showDirection =="left")then
				--self.x = -self.width + preMc.x;
			--elseif(menuView.showDirection =="right")then
				--self.x = self.width + preMc.x;
			--end		
		--end
		--if(showType =="push" and index > 1)then
			--local index = index - 1;
			--local pnode = self.node.parent:GetChild(index);
			--local preMc = pnode.mc;
			--self.y = preMc.y;
			--self.x = preMc.x;
		--end
	--end
end
function MenuViewMovieClip:DoPlay()
	if(not self.animatorEngine)then return; end
	self.animatorEngine:doPlay();
	self:SetVisible(true)
end
function MenuViewMovieClip:DoEnd()
	if(not self.animatorEngine)then return; end
	self.animatorEngine:doEnd();
end
function MenuViewMovieClip:DoPause()
	if(not self.animatorEngine)then return; end
	self.animatorEngine:doPause();
end
function MenuViewMovieClip:DoResume()
	if(not self.animatorEngine)then return; end
	self.animatorEngine:doResume();
end
function MenuViewMovieClip:SetVisible(bool)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.visible = bool;
	end
end
function MenuViewMovieClip:GotoAndPlay(keyFrame)
	if(not self.animatorEngine)then return; end
	self.animatorEngine:gotoAndPlay(keyFrame);
end
function MenuViewMovieClip:isPlaying()
	if(not self.animatorEngine)then return; end
	self.animatorEngine:isPlaying();
end
function MenuViewMovieClip:BuildUI()
	--local animativeMenuView = self.node.TreeView;
	--local _parent = ParaUI.GetUIObject(animativeMenuView.name);
--
	--local _this;
	----commonlib.echo({self.x,self.y,self.node.index});
	--_this = ParaUI.CreateUIObject("container", self.name, "_lt", self.x,self.y,self.width,self.height)	
	--_this.background = "";
	--_this.visible = false;
	--_parent:AddChild(_this);
	--_parent = _this;
	----side
	--local left,top,width,height=0,0,256,128;
	--_this = ParaUI.CreateUIObject("container", self.name.."side", "_lt", left,top,width,height)
	--_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png;";
	--_parent:AddChild(_this);
	----bg
	--left,top,width,height=0,0,256,128;
	--_this = ParaUI.CreateUIObject("container", self.name.."bg", "_lt", left,top,width,height)
	--_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png;";
	--_parent:AddChild(_this);
	----text
	--left,top,width,height=0,0,256,128;
	--_this = ParaUI.CreateUIObject("text", self.name.."text", "_lt", left,top,width,height)
	--_this.text = self.node.Text;
	--_parent:AddChild(_this);
	
	
end
function MenuViewMovieClip:BuildEngine()
	-------engine
	--local engine = CommonCtrl.Motion.AnimatorEngine:new();
	--local animatorManager = CommonCtrl.Motion.AnimatorManager:new();
	--
	--local animator,layerManager;
		  ----layer 1 : side
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/test/motionData_2.xml", self.name.."side");
		  --layerManager = CommonCtrl.Motion.LayerManager:new();	 		  
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		  ----layer 2 : bg
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/test/motionData_2.xml", self.name.."bg");
		  --layerManager = CommonCtrl.Motion.LayerManager:new();	 		  
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		  ----layer 3 : text
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/test/motionData_2.xml", self.name.."text");
		  --layerManager = CommonCtrl.Motion.LayerManager:new();	 		  
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		  	  --
		  ----set AnimatorManager value must be at last 
		  --engine:SetAnimatorManager(animatorManager);
		  --
		  --engine.OnMotionEnd = CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip.OnMotionEnd;
          --engine.OnTimeChange =CommonCtrl.Motion.AnimativeMenu.MenuViewMovieClip.OnTimeChange;
          --engine.node = self.node;
          --self.animatorEngine = engine;	  
end
function MenuViewMovieClip:Update()
	local _this = ParaUI.GetUIObject(self.name);
	_this.x = self.x;
	_this.y = self.y;
end
function MenuViewMovieClip:Destroy()
	ParaUI.Destroy(self.name);
end
function MenuViewMovieClip.OnMotionEnd(sControl)
	local engine = sControl;
	if(not engine)then  return ; end
	local node = engine.node;
	local animativeMenuView = node.TreeView;
	animativeMenuView:DetachNode(node);
end
function MenuViewMovieClip:Reset()
	local _this = ParaUI.GetUIObject(self.name);
	_this.x = self.x;
	_this.y = self.y;
	_this = ParaUI.GetUIObject(self.name.."text");
	_this.text = self.node.Text;
end
-----------------------------------------------------------------------------------------------------------------------------------
local MenuViewTweenPool = {
	data = {},
	isStart = false,
	--event
	IsEmptyEvent = nil, 
	curTween = nil,
}
commonlib.setfield("CommonCtrl.Motion.AnimativeMenu.MenuViewTweenPool",MenuViewTweenPool);
-- constructor
function MenuViewTweenPool:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.data = {};
	return o
end
function MenuViewTweenPool:Push(tween)
	tween.MotionChange = MenuViewTweenPool.tweenChange;
	tween.MotionFinish = MenuViewTweenPool.tweenFinish;
	tween.TweenPool = self;
	table.insert(self.data,tween);
	if(self.isStart == false)then
		self.isStart = true;
		tween:Start();
		self.curTween = tween;	
	end	
end
function MenuViewTweenPool.tweenChange(time,position,tween)
	local animativeMenuView = tween.animativeMenuView;
	local node = tween.node;
	local poolType = tween.poolType;
	animativeMenuView:SnapLiveNodes(position,node,poolType);
end
function MenuViewTweenPool.tweenFinish(time,position,tween)
	if(not tween)then return ; end
	local self = tween.TweenPool;
	local mc = tween.node.mc;
	
	local animativeMenuView = tween.animativeMenuView;
	
	table.remove(self.data,1);
	local len = table.getn(self.data);
	animativeMenuView:ClearTempValue(tween.node);
	if(mc)then
		mc:DoPlay();
		animativeMenuView:SetAliveNode(tween.node);
	end
	if(len>0)then				
		tween = self.data[1];
		tween:Start();	
		self.curTween = tween;	
	else
		self.IsEmptyEvent(self);
	end
end
function MenuViewTweenPool.IsEmptyEvent(self)
	if(not self)then return; end
	self.isStart = false;
	self.curTween = nil;
end
function MenuViewTweenPool:removeTween(tween)
	if(not tween)then return; end
	local k,v;
	for k,v in ipairs(self.data) do
		if(v==tween)then
			table.remove(self.data,k);
		end
	end
end


