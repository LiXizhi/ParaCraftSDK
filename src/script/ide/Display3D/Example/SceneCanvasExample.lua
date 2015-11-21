--[[
Title: 
Author(s): Leio
Date: 2009/11/4
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/Example/SceneCanvasExample.lua");
CommonCtrl.Display3D.SceneCanvasExample.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneCanvas.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");
NPL.load("(gl)script/ide/Display3D/SeedGridNode.lua");
NPL.load("(gl)script/ide/Display3D/Example/SceneNodeProcessorExample.lua");
local SceneCanvasExample = {
	sceneManager = nil,
	rootNode = nil,
	canvas = nil,
	nodeProcessor = nil,
	
	gridNode = nil,
	plantNode = nil,
	page = nil,
	global_instance = nil,--测试用的实例
}
commonlib.setfield("CommonCtrl.Display3D.SceneCanvasExample",SceneCanvasExample);
function SceneCanvasExample:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end

function SceneCanvasExample:Init()
	local sceneManager = CommonCtrl.Display3D.SceneManager:new();
	local rootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = sceneManager,
	}
	local canvas = CommonCtrl.Display3D.SceneCanvas:new{
		rootNode = rootNode,
		sceneManager = sceneManager,
	}
	local nodeProcessor = CommonCtrl.Display3D.SceneNodeProcessorExample:new{
		canvas = canvas
	};
	self.sceneManager = sceneManager;
	self.rootNode = rootNode;
	self.canvas = canvas;
	self.nodeProcessor = nodeProcessor;
	self:createChildren3();
	canvas:AddEventListener("mouse_over",SceneCanvasExample.DoMouseOver,self);
	canvas:AddEventListener("mouse_out",SceneCanvasExample.DoMouseOut,self);
	canvas:AddEventListener("mouse_down",SceneCanvasExample.DoMouseDown,self);
	canvas:AddEventListener("mouse_up",SceneCanvasExample.DoMouseUp,self);
	canvas:AddEventListener("mouse_move",SceneCanvasExample.DoMouseMove,self);
	canvas:AddEventListener("stage_mouse_down",SceneCanvasExample.DoMouseDown_Stage,self);
	canvas:AddEventListener("stage_mouse_up",SceneCanvasExample.DoMouseUp_Stage,self);
	canvas:AddEventListener("stage_mouse_move",SceneCanvasExample.DoMouseMove_Stage,self);
	canvas:AddEventListener("child_selected",SceneCanvasExample.DoChildSelected,self);
	canvas:AddEventListener("child_unselected",SceneCanvasExample.DoChildUnSelected,self);
	
	
end
function SceneCanvasExample:clear()
	if(self.canvas)then
		self.canvas:ClearAll()
	end
end
function SceneCanvasExample:createChildren3()
	local node = CommonCtrl.Display3D.HomeLandCommonNode:new{
		x = 255,
		y = 0,
		z = 260,
		assetfile = "model/06props/shared/pops/muzhuang.x",
		--type = "PlantE",
	};
	self.rootNode:AddChild(node);
	self.plantNode = node;
	node = CommonCtrl.Display3D.SeedGridNode:new{
		x = 255,
		y = 0,
		z = 255,
		assetfile = "model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x",
		
	};
	self.rootNode:AddChild(node);
	self.gridNode = node;
	
	node = CommonCtrl.Display3D.HomeLandCommonNode:new{
		x = 255,
		y = 0,
		z = 265,
		assetfile = "model/06props/shared/pops/muzhuang.x",
		--type = "PlantE",
	};
	self.rootNode:AddChild(node);
	node = CommonCtrl.Display3D.HomeLandCommonNode:new{
		x = 255,
		y = 0,
		z = 270,
		assetfile = "model/06props/shared/pops/muzhuang.x",
		--type = "PlantE",
	};
	self.rootNode:AddChild(node);
end
function SceneCanvasExample:showSelected(event,bShow)
	if(event and event.currentTarget)then
		local currentTarget = event.currentTarget;
		local id = currentTarget:GetEntityID();
		local obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			if(bShow)then
				ParaSelection.AddObject(obj,1);
			else
				ParaSelection.AddObject(obj,-1);
			end
		end
	end
end
function SceneCanvasExample:dragNode(canvas,node,bDrag)
	if(canvas and node)then
		if(bDrag)then
			canvas:StartDrag(node);
		else
			canvas:StopDrag(node);
		end
	end
end
function SceneCanvasExample.DoMouseOver(self,event)
	--self:showSelected(event,true);
	self.UpdatePageText(event)
	self.nodeProcessor:DoMouseOver(event);
end
function SceneCanvasExample.DoMouseOut(self,event)
	--self:showSelected(event,false);
	self.UpdatePageText(event)
	self.nodeProcessor:DoMouseOut(event);
end
function SceneCanvasExample.DoMouseDown(self,event)
	--self:dragNode(canvas,node_2,true);
	self.UpdatePageText(event)
	self.nodeProcessor:DoMouseDown(event);
end
function SceneCanvasExample.DoMouseUp(self,event)
	self.UpdatePageText(event)
	self.nodeProcessor:DoMouseUp(event);
end
function SceneCanvasExample.DoMouseMove(self,event)
	self.UpdatePageText(event)
	self.nodeProcessor:DoMouseMove(event);
end
function SceneCanvasExample.DoChildSelected(self,event)
	--self:showSelected(event,true);
	self.UpdatePageText_Selected(event)
	self.nodeProcessor:DoChildSelected(event);
end
function SceneCanvasExample.DoChildUnSelected(self,event)
	--self:showSelected(event,false);
	self.UpdatePageText_UnSelected(event)
	self.nodeProcessor:DoChildUnSelected(event);
end
function SceneCanvasExample.DoMouseDown_Stage(self,event)
	--dragNode(canvas,node_2,true);
	self.UpdatePageText_Stage(event);
	self.nodeProcessor:DoMouseDown_Stage(event);
end
function SceneCanvasExample.DoMouseUp_Stage(self,event)
	--self:dragNode(canvas,node_2,false);
	self.UpdatePageText_Stage(event);
	self.nodeProcessor:DoMouseUp_Stage(event);
end
function SceneCanvasExample.DoMouseMove_Stage(self,event)
	self.UpdatePageText_Stage(event);
	self.nodeProcessor:DoMouseMove_Stage(event);
	self.UpdatePageText_PickObj();
end
------------------------------------------------------------------------------------------------------
--page control
------------------------------------------------------------------------------------------------------
function SceneCanvasExample.ShowPage()
	local self = SceneCanvasExample;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/ide/Display3D/Example/SceneCanvasExample.html", 
			name = "SceneCanvasExample.ShowPage", 
			--app_key=MyCompany.Aries.app.app_key, 
			app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			--isTopLevel = true,
			allowDrag = true,
			directPosition = true,
				align = "_lt",
				x = 0,
				y = 0,
				width = 300,
				height = 600,
		});
	if(self.global_instance)then
		self.global_instance:clear();
	end
	self.global_instance = CommonCtrl.Display3D.SceneCanvasExample:new();
	
	self.DoViewState("view")
end
function SceneCanvasExample.SetPage()
	local self = SceneCanvasExample;
	self.page = document:GetPageCtrl();
	self.page.OnClose = CommonCtrl.Display3D.SceneCanvasExample.ClosePage;
end
function SceneCanvasExample.ClosePage()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		self.global_instance:clear();
	end
end
function SceneCanvasExample.UpdatePageText(event)
	local self = SceneCanvasExample;
	if(self.page)then
		if(not event)then 
			self.page:SetUIValue("txt_info","空");
		else
			local type = event.type;
			local currentTarget = event.currentTarget;
			local id = -1;
			if(currentTarget)then
				id = currentTarget:GetEntityID();
			end
			local s = string.format("事件：%s,实体id：%d",type,id);
			self.page:SetUIValue("txt_info",s);
		end
	end
end
function SceneCanvasExample.UpdatePageText_Stage(event)
	local self = SceneCanvasExample;
	if(self.page)then
		if(not event)then 
			self.page:SetUIValue("stage_txt_info","空");
		else
			local type = event.type;
			local currentTarget = event.currentTarget;
			local id = -1;
			if(currentTarget)then
				id = currentTarget:GetEntityID();
			end
			local s = string.format("事件：%s,实体id：%d",type,id);
			self.page:SetUIValue("stage_txt_info",s);
		end
	end
end
function SceneCanvasExample.UpdatePageText_Selected(event)
	local self = SceneCanvasExample;
	if(self.page)then
		if(not event)then 
			self.page:SetUIValue("selected_txt_info","空");
		else
			local type = event.type;
			local currentTarget = event.currentTarget;
			local id = -1;
			if(currentTarget)then
				id = currentTarget:GetEntityID();
			end
			local s = string.format("事件：%s,实体id：%d",type,id);
			self.page:SetUIValue("selected_txt_info",s);
		end
	end
end
function SceneCanvasExample.UpdatePageText_UnSelected(event)
	local self = SceneCanvasExample;
	if(self.page)then
		if(not event)then 
			self.page:SetUIValue("unselected_txt_info","空");
		else
			local type = event.type;
			local currentTarget = event.currentTarget;
			local id = -1;
			if(currentTarget)then
				id = currentTarget:GetEntityID();
			end
			local s = string.format("事件：%s,实体id：%d",type,id);
			self.page:SetUIValue("unselected_txt_info",s);
		end
	end
end
function SceneCanvasExample.UpdatePageText_EditMode(mode)
	local self = SceneCanvasExample;
	if(self.page)then
		self.page:SetUIValue("mode_txt_info",mode);
	end
end
function SceneCanvasExample.UpdatePageText_PickObj()
	local self = SceneCanvasExample;
	if(self.page)then
		local obj = ParaScene.MousePick(70, "4294967295");
		if(obj:IsValid())then
			local x,y,z = obj:GetPosition();
			local id = obj:GetID();
			local s = string.format("id:%d,x=%f,y=%f,z=%f",id,x,y,z);
			self.page:SetUIValue("pickobj_txt_info",s);
		end
	end
end
--浏览状态
function SceneCanvasExample.DoViewState()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		self.global_instance.nodeProcessor:SetEditMode("view");
		self.UpdatePageText_EditMode("view")
		self.global_instance.nodeProcessor:UnSelected();
	end
end
--编辑状态
function SceneCanvasExample.DoEditState()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		self.global_instance.nodeProcessor:SetEditMode("edit");
		self.UpdatePageText_EditMode("edit")
		self.global_instance.nodeProcessor:UnSelected();
	end
end
--左旋转
function SceneCanvasExample.DoFacing_Left()
	local self = SceneCanvasExample;
	self.DoFacingDelta(-0.1);
end
--右旋转
function SceneCanvasExample.DoFacing_Right()
	local self = SceneCanvasExample;
	self.DoFacingDelta(0.1);
end
--旋转
function SceneCanvasExample.DoFacingDelta(facing)
	facing = tonumber(facing);
	local self = SceneCanvasExample;
	if(self.global_instance)then
		self.global_instance.nodeProcessor:SetFacingDelta(facing);
	end
end
--向上
function SceneCanvasExample.DoUp()
	local self = SceneCanvasExample;
	self.DoPositionDelta(0,0.1,0);
end
--向下
function SceneCanvasExample.DoDown()
	local self = SceneCanvasExample;
	self.DoPositionDelta(0,-0.1,0);
end
--
function SceneCanvasExample.DoPositionDelta(dx,dy,dz)
	local self = SceneCanvasExample;
	if(self.global_instance)then
		self.global_instance.nodeProcessor:SetPositionDelta(dx,dy,dz);
	end
end
--开始拖拽
function SceneCanvasExample.DoStartDrag()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		--自定义的拖拽
		self.global_instance.nodeProcessor:DirectlyDragSelectedNode()
	end
end
--创建普通物体
function SceneCanvasExample.DoBuildNode()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		local x,y,z = ParaScene.GetPlayer():GetPosition();
		local node = CommonCtrl.Display3D.HomeLandCommonNode:new{
			x = x,
			y = y,
			z = z,
			assetfile = "model/06props/shared/pops/muzhuang.x",
		};
		self.global_instance.rootNode:AddChild(node);
	end
end
--创建花圃
function SceneCanvasExample.DoBuildGridNode()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		local x,y,z = ParaScene.GetPlayer():GetPosition();
		local node = CommonCtrl.Display3D.SeedGridNode:new{
				x = x,
				y = y,
				z = z,
				assetfile = "model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x",
				
			};
		self.global_instance.rootNode:AddChild(node);
	end
end
--销毁
function SceneCanvasExample.DoDestroyNode()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		local selectedNode,linkedNode = self.global_instance.nodeProcessor:GetSelectedNodeAndLinkedNode();
		local mode = self.global_instance.nodeProcessor:GetEditMode();
		if(mode == "view")then
			
			if(selectedNode)then
				local type = selectedNode:GetType();
				if(type == "Grid")then
					_guihelper.MessageBox("花圃只能在编辑状态下回收！");
					return
				end
				--取消与花圃关联
				selectedNode:SetSeedGridNodeUID(nil);
				selectedNode:Detach();
				self.global_instance.nodeProcessor:UnSelected();
			end
			if(linkedNode)then
				local type = linkedNode:GetType();
				if(type == "Grid")then
					--取消绑定
					linkedNode:SetGridInfo(1,"");
				end
			end
		else
			if(linkedNode)then
				_guihelper.MessageBox("花圃上有物品，不能删除！");
				return
			else
				if(selectedNode)then
					selectedNode:Detach();
					self.global_instance.nodeProcessor:UnSelected();
				end
			end
		end
		
	end
end
--在花圃上放一个物体
function SceneCanvasExample.PutNodeInSeedGrid()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		local selectedNode,linkedNode = self.global_instance.nodeProcessor:GetSelectedNodeAndLinkedNode();
		local mode = self.global_instance.nodeProcessor:GetEditMode();
		if(mode == "view")then
			local type = selectedNode:GetType();
			if(type == "Grid")then
				if(not selectedNode:HasLinkedNode())then
					local x,y,z = ParaScene.GetPlayer():GetPosition();
					local node = CommonCtrl.Display3D.HomeLandCommonNode:new{
						x = x,
						y = y,
						z = z,
						assetfile = "model/06props/shared/pops/muzhuang.x",
					};
					self.global_instance.rootNode:AddChild(node);
					local uid = node:GetUID();
					selectedNode:SetGridInfo(1,uid);
					--node 与花圃关联
					node:SetSeedGridNodeUID(selectedNode:GetUID());
				else
					_guihelper.MessageBox("花圃上已经有物体了！");
				end
			end
		end
	end
end
--debug 清空拖拽的迷你场景
function SceneCanvasExample.DoClearMirrorNode()
	local self = SceneCanvasExample;
	if(self.global_instance)then
		self.global_instance.nodeProcessor.dragRootNode:Detach();
	end
end
--debug
function SceneCanvasExample.DoVisible()
	local self = SceneCanvasExample;
	local selectedNode,linkedNode = self.global_instance.nodeProcessor:GetSelectedNodeAndLinkedNode();
	if(selectedNode)then
		selectedNode:SetVisible(true);
	end
	if(linkedNode)then
		linkedNode:SetVisible(true);
	end
end
--debug
function SceneCanvasExample.DoUnVisible()
	local self = SceneCanvasExample;
	local selectedNode,linkedNode = self.global_instance.nodeProcessor:GetSelectedNodeAndLinkedNode();
	if(selectedNode)then
		selectedNode:SetVisible(false);
	end
	if(linkedNode)then
		linkedNode:SetVisible(false);
	end
end
function SceneCanvasExample.DoAllVisible()
	local self = SceneCanvasExample;
	if(self.global_instance.rootNode)then
		if(self.doAllVisible)then
			self.doAllVisible = false;
			self.global_instance.rootNode:SetVisible(false);
		else
			self.doAllVisible = true;
			self.global_instance.rootNode:SetVisible(true);
		end
	end
end