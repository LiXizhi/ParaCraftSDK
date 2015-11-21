--[[
Title: class for entity drawing 
Author(s): LiXizhi. Code is mostly refactored from HomeLandNodeProcessor.lua
Date: 2010/6/8
Desc: the drawing class used by entity editors. Internally it manages a group of editor visualizer objects 
in a mini-scenegraph called "ideEditors". 
It uses another mini-scenegraph ("ideEditorsDrag") for rendering the objects being dragged. 
The mouse logics is
   * left click to select object, left click twice to start dragging
   * left click again to confirm dragging, right click to cancel dragging. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityDesign.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneCanvas.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
local EntityDesign = commonlib.gettable("IPCBinding.EntityDesign");
local IPCBindingContext = commonlib.gettable("IPCBindingContext");

-- by default, it is edit mode. 
EntityDesign.editMode = "edit";
EntityDesign.clickNum = 0;

-- mapping from scene name to the {scene = scene_obj, rootNode=rootNode, scene_name=string} 
local mini_scenes = {};

-- get the mini scene root node by name
function EntityDesign:GetMiniSceneRootNode(scene_name)
	if(not scene_name) then return end
	local miniscene = mini_scenes[scene_name]
	if(miniscene) then
		return miniscene.rootNode;
	end
	miniscene = {};
	miniscene.scene = CommonCtrl.Display3D.SceneManager:new({uid=scene_name, type = "miniscene"});
	miniscene.rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = miniscene.scene,
			visible = true,
		};
	mini_scenes[scene_name] = miniscene;
	return miniscene.rootNode;
end

-- get the root scene node. 
-- @param scene_name: this is nil if it is the main game scene, otherwise it will be the miniscene graph name
function EntityDesign:GetRootNode(scene_name)
	if(scene_name) then
		-- currently all miniscenes matches to the "default_mini_scene", which can have only one parent container in it
		local rootNode = self:GetMiniSceneRootNode("default_mini_scene");
		return rootNode; 
	end
	if(not self.rootNode) then
		-- create the default scene manager. 
		self.scene = CommonCtrl.Display3D.SceneManager:new({uid="ideEditors", type = "miniscene"});
		-- self.scene:ShowHeadOnDisplay(true);

		self.rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = self.scene,
			visible = true,
		};

		-- bind a canvas to track mouse events. 
		local canvas = CommonCtrl.Display3D.SceneCanvas:new{
			rootNode = self.rootNode,
			sceneManager = self.scene,
		};
		self.canvas = canvas;

		-- only pick for the default physics group (0)
		canvas:SetPickingFilter("p:1");
		canvas:AddEventListener("mouse_over", EntityDesign.OnMouseOver, self);
		canvas:AddEventListener("mouse_out", EntityDesign.OnMouseOut, self);
		canvas:AddEventListener("mouse_down", EntityDesign.OnMouseDown, self);
		canvas:AddEventListener("mouse_up", EntityDesign.OnMouseUp, self);
		canvas:AddEventListener("mouse_move", EntityDesign.OnMouseMove, self);
		canvas:AddEventListener("stage_mouse_down", EntityDesign.OnMouseDown_Stage, self);
		canvas:AddEventListener("stage_mouse_up", EntityDesign.OnMouseUp_Stage, self);
		canvas:AddEventListener("stage_mouse_down_right", EntityDesign.OnMouseDown_Stage, self);
		canvas:AddEventListener("stage_mouse_up_right", EntityDesign.OnMouseUp_Stage, self);
		canvas:AddEventListener("stage_mouse_move", EntityDesign.OnMouseMove_Stage, self);
		canvas:AddEventListener("child_selected", EntityDesign.OnChildSelected_Stage, self);
		canvas:AddEventListener("child_unselected", EntityDesign.OnChildUnSelected_Stage, self);

		-- miniscenegraph for displaying the object during dragging and dropping 
		local scene = CommonCtrl.Display3D.SceneManager:new{
			uid="ideEditorsDrag", type = "miniscene",
		};
		local rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = scene,
		} 
		self.dragRootNode = rootNode;
	end
	return self.rootNode;
end

-- set the current design view edit mode. 
-- @param mode: can be "view" or "edit"
function EntityDesign:SetEditMode(mode)
	self.editMode = mode;
end

-- get editor mode
function EntityDesign:GetEditMode()
	return self.editMode;
end

-- return true if we can select object in the given mouse event. 
function EntityDesign:CanSelect(event)
	if(event and event.currentTarget)then
		local editor = event.currentTarget.tag;
		if(editor and editor:CanSelect())then
			return true;
		end	
	end
end

--[[
event.msg = {
  IsComboKeyPressed=false,
  IsMouseDown=false,
  MouseDragDist={ x=0, y=0 },
  dragDist=269,
  lastMouseDown={ x=782, y=488 },
  lastMouseUpButton="right",
  lastMouseUpTime=6699.6712684631,
  lastMouseUp_x=789,
  lastMouseUp_y=496,
  mouse_button="right",
  mouse_x=559,
  mouse_y=196,
  virtual_key=242,
  wndName="mouse_move" 
}
--]]
function EntityDesign:OnMouseOver(event)
	if(not self:CanSelect(event))then
		return
	end

	if(event and event.msg)then
		local msg = event.msg;
		--mouseover mouseout do not distinguish mouse key pressed. 
		if(not self.isDrag)then
			self:ShowTip(event);
		end
	end
end

function EntityDesign:OnMouseOut(event)
	if(not self:CanSelect(event))then
		return
	end
	if(event and event.msg)then
		local msg = event.msg;
		--mouseover mouseout do not distinguish mouse key pressed. 
		if(not self.isDrag)then
			self:HideTip(event);
		end
	end
end

function EntityDesign:OnMouseDown(event)
end

function EntityDesign:OnMouseUp(event)
end

function EntityDesign:OnMouseMove(event)
end

function EntityDesign:OnMouseDown_Stage(event)
end

function EntityDesign:OnMouseUp_Stage(event)
	if(event and event.msg)then
		local msg = event.msg;
		local currentTarget = event.currentTarget;
		if(msg.mouse_button == "left")then
			if(self.editMode == "edit")then
				if(not self.isDrag)then
					local selectedNode = self:GetSelectedNode();
					if(selectedNode)then
						-- the first time node is clicked
						if(self.clickNum == 0)then
							self.clickNum = self.clickNum + 1;
							-- remember the node 
							self.readyDragNode = selectedNode;
						elseif(self.clickNum == 1)then
							-- if the user clicks on the same object twice. 
							if(selectedNode == self.readyDragNode)then
								self.clickNum = 2;
								self:StartDrag();
							else
								self.readyDragNode = selectedNode;
							end
						end
						-- trap mouse event
						event.canReturn.value = false;
					else
						self.clickNum = 0;
						self.readyDragNode = nil;
						self:UnSelectNode();
						-- trap mouse event
						event.canReturn.value = false;
					end
				else
					-- trap mouse event
					event.canReturn.value = false;
					self:StopDrag();
					self.clickNum = 1;
				end
			else
				-- for non-edit mode. 
			end
		elseif(msg.mouse_button == "right")then
			if(self.editMode == "edit")then
				if(self.isDrag)then
					event.canReturn.value = false;
					-- cancel dragging 
					self:StopDrag(true);
					self.clickNum = 1;
				end
			else
			end
		end
	end
end

function EntityDesign:OnMouseMove_Stage(event)
	if(self.isDrag and self.dragContainer)then
		local pt = ParaScene.MousePick(70, "point");
		if(pt:IsValid())then
			local x,y,z = pt:GetPosition();
			local dx = x - self.dragLastX;
			local dy = y - self.dragLastY;
			local dz = z - self.dragLastZ;
			self:UpdateMirrorDragNodePos(dx,dy,dz);
			self.dragLastX,self.dragLastY,self.dragLastZ = x,y,z;
		end
	end
end

function EntityDesign:OnChildSelected_Stage(event)
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:SelectNode(event.currentTarget);
			end
		end
	end
end

function EntityDesign:OnChildUnSelected_Stage(event)
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:UnSelectNode(event.currentTarget);
			end
		end
	end
end


-- get the selected node. 
function EntityDesign:GetSelectedNode()
	return self.selectedNode;
end

-- remember the node selected and if node is nil, it means unselect the node. 
-- @param node: the scene node to select. if nil, it means unselect it. 
function EntityDesign:SetNodeSelected(node)
	local old = self.selectedNode;
	self.selectedNode = node;
	
	if(node) then
		local editor = node.tag;
		if(editor and editor.instance) then
			-- inform IDE to select object. 
			IPCBindingContext.SelectObject(editor.instance.uid);
		end
	end

	if(type(self.OnSelectedNodeFunc) == "function") then
		local msg = {
			oldnode = old,
			node = node,
			parent_canvas = self.parent_canvas,
		}
		self.OnSelectedNodeFunc(msg);
	end
end

-- set node selected. 
function EntityDesign:SelectNode(target)
	if(not target) then return end

	-- TODO: inform IDE that a new object is selected and show its property page

	-- high the node
	self:HighlightNode(target,true);
	-- mark selected
	self:SetNodeSelected(target);
end

-- set node unselected. 
-- @param target: if nil, it will be the current selected node. 
function EntityDesign:UnSelectNode(target)
	target = target or self.selectedNode;
	if(not target) then return end

	-- TODO: inform IDE that an object is object is deselected

	-- high the node
	self:HighlightNode(target,false);
	-- stop dragging
	self:DirectlyStopDragSelectedNode();
	-- mark selected
	self:SetNodeSelected(nil);
end

-- highlight a given scene node in appearance. 
function EntityDesign:HighlightNode(node,bShow)
	if(node)then
		local id = node:GetEntityID();
		local obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			if(bShow)then
				if(self.editMode == "edit")then
					obj:GetAttributeObject():SetField("showboundingbox", true);
					-- ParaSelection.AddObject(obj,1);
				end
			else
				obj:GetAttributeObject():SetField("showboundingbox", false);
				-- ParaSelection.AddObject(obj,-1);
			end
		end
	end
end

-- private: highlight the object in the mouse event and display corresponding mouseover tips. 
function EntityDesign:ShowTip(event)
	if(not event)then return end
	local target = event.currentTarget;
	local editor = target and target.tag;
	if(editor)then
		if(target ~= self.selectedNode)then
			self:HighlightNode(target,true);
		end
	end
end

-- private: un-highlight the object in the mouse event and hide any tips effect
function EntityDesign:HideTip(event)
	if(not event)then return end
	local target = event.currentTarget;
	local editor = target and target.tag;
	if(editor)then
		if(target ~= self.selectedNode)then
			self:HighlightNode(target,false);
		end
	end
end

-- start dragging even self.clickNum = 1
function EntityDesign:DirectlyDragSelectedNode()
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	if(self.clickNum == 1 and selectedNode == self.readyDragNode)then
		self.clickNum = 2;
		self:StartDrag();
	end
end

-- stop dragging
function EntityDesign:DirectlyStopDragSelectedNode()
	if(self.clickNum == 2)then
		self:StopDrag();
		self:Reset();
	end
end

-- start dragging
function EntityDesign:StartDrag()
	if(not self.dragRootNode)then return end
	self.dragRootNode:Detach();
	-- the parent container for all nodes to be dragged. 
	local container = CommonCtrl.Display3D.SceneNode:new{
		node_type = "container",
		x = 0,
		y = 0,
		z = 0,
		visible = true,
	};
	self.dragRootNode:AddChild(container);
	
	local mirror_1;
	local mirror_2;
	local selectedNode = self:GetSelectedNode();
	if(selectedNode)then
		local mirror_1 = selectedNode:Clone();
		container:AddChild(mirror_1);
		self:HighlightNode(selectedNode,false);
		selectedNode:SetVisible(false);
		
		-- from selectedNode's current position
		self.isDrag = true;
		self.dragLastX,self.dragLastY,self.dragLastZ = selectedNode:GetPosition();
	end
	
	-- remember the container of all dragging objects. 
	self.dragContainer = container;
end

-- stop dragging
-- @param bCanceled: if true, dragging will be canceled. otherwise the position is updated. 
function EntityDesign:StopDrag(bCanceled)
	if(not self.dragRootNode or not self.dragContainer)then return end
	local selectedNode = self:GetSelectedNode();
	if(selectedNode) then
		if(not bCanceled) then
			self:UpdateNodePosition(selectedNode,1);

			-- set editor's position modified 
			local editor = selectedNode.tag;
			local x,y,z = selectedNode:GetPosition();
			editor:SetPosition(x,y,z);
		else
			selectedNode:SetVisible(true);
		end
	end

	self.isDrag = false;
	self.dragRootNode:Detach();
	
	self.selectedNode = nil;
	if(self.canvas)then
		self.canvas:DirectDispatchChildSelectedEvent(selectedNode);
	end
end

-- update position of the object being dragged. 
function EntityDesign:UpdateMirrorDragNodePos(dx,dy,dz)
	if(self.dragContainer)then
		--dy = math.max(dy,0);
		local x,y,z = self.dragContainer:GetPosition();
		x = x + dx;
		y = y + dy;
		z = z + dz;
		self.dragContainer:SetPosition(x,y,z);
	end
end

function EntityDesign:Reset()
	self.clickNum = 0;
	self.readyDragNode = nil;
	self.selectedNode = nil;
end

-- Update node position according to mirrored dragging object. 
function EntityDesign:UpdateNodePosition(node,mirrorNodeIndex)
	if(not node or not mirrorNodeIndex or not self.dragContainer)then return end
	local mirror_node = self.dragContainer:GetChild(mirrorNodeIndex);
	if(mirror_node)then
		local renderParams = mirror_node:GetRenderParams();
		if(renderParams)then
			local x,y,z = renderParams.x,renderParams.y,renderParams.z;
			node:SetPosition(x,y,z);
			node:SetVisible(true);
		end
	end
end