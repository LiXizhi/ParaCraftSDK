--[[
Title: 
Author(s): Leio
Date: 2010/08/21
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/Graph.lua");
-------------------------------------------------------
--]]
NPL.load("(gl)script/ide/STL.lua");
local Graph = commonlib.gettable("commonlib.Graph");
local GraphNode = commonlib.gettable("commonlib.GraphNode");
local GraphArc = commonlib.gettable("commonlib.GraphArc");
local List = commonlib.gettable("commonlib.List");
Graph.nodes = nil;
Graph.nodes_map = nil;
function Graph:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	o.nodes = List:new();
	o.nodes_map = {};
	return o
end
function Graph:ContainsNode(node)
	if(not node)then return end
	if(self.nodes_map[node])then
		return true;
	end
end
function Graph:AddNode()
	local node = GraphNode:new{
	};
	self.nodes:add(node);
	self.nodes_map[node] = node;
	return node;
end
function Graph:RemoveNode(node)
	if(not self:ContainsNode(node))then return end
	local list = self.nodes;
	local item = list:first();
	while (item) do
		if(item:GetArc(node))then
			self:RemoveArc(item,node);
		end
		item = list:next(item)
	end
	self.nodes:remove(node);
	self.nodes_map[node] = nil;
	
end
function Graph:AddArc(source,target,tag)
	if(not source or not target)then return end
	if(source:GetArc(target))then
		return
	end
	source:AddArc(target,tag);
end
function Graph:RemoveArc(source,target)
	if(not source or not target)then return end
	source:RemoveArc(target);
end
function Graph:Size()
	return self.nodes:size();
end
function Graph:Clear()
	self.nodes = List:new{
	};
	self.nodes_map = {};
end
function Graph:Next()
	local list = self.nodes;
	local item = list:first();
	return function()
		while (item) do
			local p = item;
			item = list:next(item)
			return p;
		end
	end
end
----------------------------------------------
--GraphNode
----------------------------------------------
GraphNode.data = nil;--挂的数据
GraphNode.arcs = nil;--node关联的弧
GraphNode.uid = nil;
function GraphNode:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	o.arcs = List:new();
	o.uid = ParaGlobal.GenerateUniqueID();
	return o
end
function GraphNode:AddArc(target,tag)
	if(not target)then return end
	local arc = GraphArc:new{
		node = target,
		tag = tag,
	}
	self.arcs:add(arc);
end
function GraphNode:RemoveArc(target)
	if(not target)then return end
	local list = self.arcs;
	local arc = list:first();
	while (arc) do
		local node = arc:GetNode();
		if(node and node == target)then
			self.arcs:remove(arc);
			return true;
		end
		arc = list:next(arc)
	end
	return false;
end
function GraphNode:GetArc(target)
	if(not target)then return end
	--local list = self.arcs;
	--local arc = list:first();
	--while (arc) do
		--local node = arc:GetNode();
		--if(node and node == target)then
			--return arc;
		--end
		--arc = list:next(arc)
	--end
	local arc;
	for arc in self:NextArc() do
		local node = arc:GetNode();
		if(node and node == target)then
			return arc;
		end
	end
end
function GraphNode:GetNumArcs()
	return self.arcs:size();
end
function GraphNode:GetData()
	return self.data;
end
function GraphNode:NextArc()
	local list = self.arcs;
	local item = list:first();
	return function()
		while (item) do
			local p = item;
			item = list:next(item)
			return p;
		end
	end
end
----------------------------------------------
--GraphArc
----------------------------------------------
GraphArc.node = nil;
--弧的额外信息
GraphArc.tag = nil;
function GraphArc:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function GraphArc:GetNode()
	return self.node;
end
function GraphArc:GetTag()
	return self.tag;
end
