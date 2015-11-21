--[[
Title: DisplayObjectContainer
Author(s): Leio
Date: 2009/1/13
Desc: 
DisplayObjectContainer --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/DisplayObjectContainer.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
local DisplayObjectContainer = commonlib.inherit(CommonCtrl.Display.InteractiveObject,{
	CLASSTYPE = "DisplayObjectContainer",
});  
commonlib.setfield("CommonCtrl.Display.DisplayObjectContainer",DisplayObjectContainer);
------------------------------------------------------------
-- override methods
------------------------------------------------------------
------------------------------------------------------------
-- public methods
------------------------------------------------------------
function DisplayObjectContainer:ClearChildren()
	self.Nodes = {};
end
function DisplayObjectContainer:GetNumChildren()
	if(not self.Nodes)then return end;
	return table.getn(self.Nodes);
end

function DisplayObjectContainer:AreInaccessibleObjectsUnderPoint(point)

end
function DisplayObjectContainer:Contains(child)
	if(not child)then return end;
	if(not self.Nodes)then return end;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil and child == node) then
			return true;
		end
	end
end
function DisplayObjectContainer:GetChildAt(index)
	if(not self.Nodes)then return end;
	return self.Nodes[index];
end
function DisplayObjectContainer:GetChildByUID(id)
	if(not self.Nodes)then return end;
	if(not id)then return end
	id = tostring(id);
	local result;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node) then
			
			if(node:GetUID() == id)then
				result = node;
				break;
			else
				if(node.GetChildByUID)then
					result = node:GetChildByUID(id)
				end			
			end
		end
	end
	return result;
end
function DisplayObjectContainer:GetChildByEntityID(id)
	if(not self.Nodes)then return end;
	if(not id)then return end
	id = tostring(id);
	local result;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node) then
			if(node:GetEntityID() == id)then
				result = node;
				break;
			else
				if(node.GetChildByEntityID)then
					result = node:GetChildByEntityID(id)
					if(result)then
						break;
					end
				end			
			end
		end
	end
	return result;
end
function DisplayObjectContainer:GetChildIndex(child)
	return child.index;
end
function DisplayObjectContainer:GetObjectsUnderPoint(point)

end
function DisplayObjectContainer:RemoveChildByUID(uid)
	if(not uid)then return end
	local child = self:GetChildByUID(uid)
	self:RemoveChild(child);
end

function DisplayObjectContainer:SetChildIndex(child,index)
	if(not child or not index)then return end
	local child_1 = self:getChildAt(index);
	if(child_1)then
		local contain = self:Contains(child);
		if(contain)then
			self:SwapChildren(child_1,child)
		end
	end
end
function DisplayObjectContainer:SwapChildren(child_1,child_2)
	if(not child_1 or not child_2)then return end
	local index1 = child_1.index;
	local index2 = child_2.index;
	self:SwapChildrenAt(index1,index2)
end
function DisplayObjectContainer:SwapChildrenAt(index1,index2)
	if(not self.Nodes)then return end;
	if(not index1 or not index2)then return end
	local node1 = self.Nodes[index1]
	local node2 = self.Nodes[index2]
	if(index1 ~= index2 and node1~=nil and node2~=nil) then
		node1.index, node2.index = index2, index1;
		self.Nodes[index1], self.Nodes[index2] = node2, node1;
	end
end
function DisplayObjectContainer:AttachChild(child)
	if(not child)then return end
	local child = self:AttachChildAt(child,nil)
	return child;
end
function DisplayObjectContainer:AttachChildAt(child,index)
	----local parent = child:GetParent();
	--if(parent)then
		--log(child:GetUID().." has in a container which parent type is " .. parent.CLASSTYPE .."\r\n");
		--return;
	--end
	local o = self:__AddChildAt(child,index)	
	if(o)then
		o:SetParent(self);
	end
	return o;
end
function DisplayObjectContainer:DetachChild(child)
	if(not child)then return end
	local index = child.index;
	self:DetachChildAt(index)
end
function DisplayObjectContainer:DetachChildAt(index)
	local removedNode = self:__RemoveChildAt(index);
	if(removedNode)then	
		removedNode:SetParent(nil);
	end
	return removedNode;
end
function DisplayObjectContainer:__AddChildAt(child,index)
	if(not child)then return end
	if(not self.Nodes)then return end;
	local o = child;
	local nSize = table.getn(self.Nodes);
	if(index == nil or index>nSize or index<=0) then
			-- add to the end
			self.Nodes[nSize+1] = o;
			o.index = nSize+1;
	else
			-- insert to the mid
		local i=nSize+1;
		while (i>index) do 
				self.Nodes[i] = self.Nodes[i-1];
				self.Nodes[i].index = i;
				i = i - 1;
		end
			self.Nodes[index] = o;
			o.index = index;
	end	
	return o;
end
function DisplayObjectContainer:__RemoveChildAt(index)
	if(not self.Nodes)then return end;
	if(not index)then return end;
	local nSize = table.getn(self.Nodes);
	local i, node;
	local removedNode = nil;
	if(nSize == 1) then
		removedNode = self.Nodes[1] ;
		self.Nodes[1] = nil;
		return removedNode;
	end
	
	if(index < nSize) then
		local k;
		removedNode = self.Nodes[index] ;
		for k = index + 1, nSize do
			node = self.Nodes[k];
			self.Nodes[k-1] = node;
			if(node ~= nil) then
				node.index = k - 1;			
				self.Nodes[k] = nil;
				
			end	
		end
		return removedNode;
	else
		removedNode = self.Nodes[index] ;
		self.Nodes[index] = nil;
		return removedNode;
	end	
end
function DisplayObjectContainer:AddChild(child)
	if(not child)then return end
	local child = self:AttachChild(child)
	self:__BuildEntity(child);
end
function DisplayObjectContainer:AddChildAt(child,index)
	self:AttachChildAt(child,index);
	self:__BuildEntity(child);
end
function DisplayObjectContainer:__BuildEntity(child)

end
function DisplayObjectContainer:RemoveChild(child)
	if(not child)then return end
	local index = child.index;
	self:RemoveChildAt(index)
end
function DisplayObjectContainer:RemoveChildAt(index)
	local removedNode = self:__RemoveChildAt(index);
	if(removedNode)then		
		self:__DestroyEntity(removedNode);
		removedNode:SetParent(nil); -- after __DestroyEntity
	end
	return removedNode;
end

function DisplayObjectContainer:__DestroyEntity(removedNode)

end

function DisplayObjectContainer:Clear()
	self:__Clear(self)
end 
function DisplayObjectContainer:__Clear(parent)
	if(not parent or not parent.GetNumChildren)then return end
	local len = parent:GetNumChildren();
	while(len>0)do
		local node = parent:GetChildAt(len);
		parent:RemoveChild(node);
		self:__Clear(node)
		len = len - 1;
	end
end 