--[[
Title: Sprite2D
Author(s): Leio
Date: 2009/7/28
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/Sprite2D.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/DisplayObject2D.lua");
local Sprite2D = commonlib.inherit(CommonCtrl.Display2D.DisplayObject2D,{
	type = CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D,
});  
commonlib.setfield("CommonCtrl.Display2D.Sprite2D",Sprite2D);
function Sprite2D:OnInit()
	self.nodes = {};
	self:OnAppendInit();
end
function Sprite2D:OnAppendInit()
end
function Sprite2D:SetParent(parent)
	local node;
	for node in self:Next() do
		if(node)then
			node:SetParent(self);
		end
	end
	self.parent = parent;
end
function Sprite2D:Clear()
	self.nodes = {};
end
function Sprite2D:GetNumChildren()
	if(not self.nodes)then return end;
	return table.getn(self.nodes);
end
--获取point下面所有的child,不包括它自己
--从显示的最上层开始找,它自己在最下层
--事件冒泡的规则是：child_index_max,child_index_max-1,...child_parent
-- 返回一个列表，
function Sprite2D:GetObjectsUnderPoint(point,result)
	if(not point or not result)then return end
	local node;
	for node in self:Previous() do
		if(node)then
			local type = node.type;
				
			if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			)then
				node:GetObjectsUnderPoint(point,result)
			else
				local rect = node:GetRect();
				if(rect:ContainsPoint(point))then
					table.insert(result,node);
				end	
			end
		end
	end
	local rect = self:GetRect();
	if(rect:ContainsPoint(point))then
		table.insert(result,self);
	end	
end
function Sprite2D:AddChild(child)
	if(not child)then return end
	table.insert(self.nodes,child);
	child:SetParent(self);
	child:SetIndex(#self.nodes);
	child:BeBuilded();
end
function Sprite2D:RemoveChild(node)
	if(not node)then return end
	local nSize = table.getn(self.nodes);
	local k = nSize;
	while(k > 0) do
		local child = self.nodes[k];
		if(child == node)then
			local type = child.type;
			table.remove(self.nodes,k);
			child:SetParent(nil);
			child:SetIndex(0);
			if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D)then
				child:Clear();
			else
				child:BeDestroy();
			end
		end
		k = k - 1;
	end
			
end
function Sprite2D:Clear()
	local nSize = table.getn(self.nodes);
	local k = nSize;
	while(k > 0) do
		local child = self.nodes[k];
		local type = child.type;
		table.remove(self.nodes,k);
		child:SetParent(nil);
		child:SetIndex(0);
		if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D)then
			child:Clear();
		else
			child:BeDestroy();
		end
		k = k - 1;
	end
end
function Sprite2D:BeBuilded()
	local node;
	for node in self:Next() do
		if(node)then
			node:BeBuilded();
		end
	end
end
function Sprite2D:BeDestroy()
	local node;
	for node in self:Next() do
		if(node)then
			node:BeDestroy();
		end
	end
end
--返回一个区域，它的参照坐标是targetCoordinateSpace = {x = x,y = y}
function Sprite2D:GetRect(targetCoordinateSpace)
	local pt;
	if(targetCoordinateSpace)then
		pt = targetCoordinateSpace;
	else
		pt = {x = 0,y = 0};
	end
	local point = self:LocalToGlobal(pt);
	local rect = CommonCtrl.Display2D.Rectangle2D:new{
		x = point.x,
		y = point.y,
		width = self.width,
		height = self.height,
	}
	local result = rect;
	local node;
	for node in self:Previous() do
		if(node)then
			local r = node:GetRect(pt);
			result = CommonCtrl.Display2D.Rectangle2D.Union(result,r);
		end
	end
	return result;
end
function Sprite2D:Next()
	local nSize = table.getn(self.nodes);
	local i = 1;
	return function ()
		local node;
		while i <= nSize do
			node = self.nodes[i];
			i = i+1;
			return node;
		end
	end	
end
function Sprite2D:Previous()
	local nSize = table.getn(self.nodes);
	local i = nSize;
	return function ()
		local node;
		while i >=1 do
			node = self.nodes[i];
			i = i-1;
			return node;
		end
	end	
end
--function Sprite2D:OnMouseOver(args)
	--local node;
	--for node in self:Next() do
		--if(node)then
			--local type = node.type;
			--if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				--or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			--)then
				--node:OnMouseOver(args)
			--else
				--node:DispatchEvent("MouseOver",args);
			--end
		--end
	--end
	--self:DispatchEvent("MouseOver",args);
--end
--function Sprite2D:OnMouseOut(args)
	--local node;
	--for node in self:Next() do
		--if(node)then
			--local type = node.type;
			--if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				--or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			--)then
				--node:OnMouseOut(args)
			--else
				--node:DispatchEvent("MouseOut",args);
			--end
		--end
	--end
	--self:DispatchEvent("MouseOut",args);
--end
--function Sprite2D:OnMouseDown(args)
	--local node;
	--for node in self:Next() do
		--if(node)then
			--local type = node.type;
			--if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				--or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			--)then
				--node:OnMouseDown(args)
			--else
				--node:DispatchEvent("MouseDown",args);
			--end
		--end
	--end
	--self:DispatchEvent("MouseDown",args);
--end
--function Sprite2D:OnMouseUp(args)
	--local node;
	--for node in self:Next() do
		--if(node)then
			--local type = node.type;
			--if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				--or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			--)then
				--node:OnMouseUp(args)
			--else
				--node:DispatchEvent("MouseUp",args);
			--end
		--end
	--end
	--self:DispatchEvent("MouseUp",args);
--end
--function Sprite2D:OnMouseMove(args)
	--local node;
	--for node in self:Next() do
		--if(node)then
			--local type = node.type;
			--if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				--or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			--)then
				--node:OnMouseMove(args)
			--else
				--node:DispatchEvent("MouseMove",args);
			--end
		--end
	--end
	--self:DispatchEvent("MouseMove",args);
--end
function Sprite2D:OnEnterFrame(args)
	local node;
	for node in self:Next() do
		if(node)then
			local type = node.type;
			if(type == CommonCtrl.Display2D.DisplayObject2DEnums.Sprite2D
				or type == CommonCtrl.Display2D.DisplayObject2DEnums.Button2D
			)then
				node:OnEnterFrame(args)
			else
				node:DispatchEvent("EnterFrame",args);
			end
		end
	end
	self:DispatchEvent("EnterFrame",args);
end