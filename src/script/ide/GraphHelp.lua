--[[
Title: 
Author(s): Leio
Date: 2010/08/22
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/ide/Graph.lua");
local Graph = commonlib.gettable("commonlib.Graph");
local GraphNode = commonlib.gettable("commonlib.GraphNode");
local GraphArc = commonlib.gettable("commonlib.GraphArc");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
local graph = Graph:new{
}
local node1 = graph:AddNode();
node1.data = { graphNodeIndex = 1,};
local node2 = graph:AddNode();
node2.data = { graphNodeIndex = 2,};
local node3 = graph:AddNode();
node3.data = { graphNodeIndex = 3,};
local node4 = graph:AddNode();
node4.data = { graphNodeIndex = 4,};
local node5 = graph:AddNode();
node5.data = { graphNodeIndex = 5,};
local node6 = graph:AddNode();
node6.data = { graphNodeIndex = 6,};
local node7 = graph:AddNode();
node7.data = { graphNodeIndex = 7,};
local node8 = graph:AddNode();
node8.data = { graphNodeIndex = 8,};
--graph:AddArc(node1,node2);
--graph:AddArc(node1,node3);
--graph:AddArc(node1,node4);
--graph:AddArc(node1,node5);
--graph:AddArc(node2,node3);
--graph:AddArc(node2,node4);
--graph:AddArc(node2,node5);
--graph:AddArc(node3,node4);
--graph:AddArc(node3,node5);
--graph:AddArc(node4,node5);
--graph:AddArc(node5,node1);


graph:AddArc(node1,node2);
graph:AddArc(node1,node3);
graph:AddArc(node1,node4);
graph:AddArc(node3,node5);
graph:AddArc(node3,node6);
graph:AddArc(node6,node7);
graph:AddArc(node6,node8);

local function visit_fun(visited_node)
	if(visited_node)then
		commonlib.echo(visited_node.data);
	end
end
--GraphHelp.Search_DepthFirst(node1,visit_fun)
GraphHelp.Search_BreadthFirst(node1,visit_fun)
		1
2		3		4
	5		6
		7		8	


NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/ide/Graph.lua");
local Graph = commonlib.gettable("commonlib.Graph");
local GraphNode = commonlib.gettable("commonlib.GraphNode");
local GraphArc = commonlib.gettable("commonlib.GraphArc");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
local graph = Graph:new{
}
local node1 = graph:AddNode();
node1.data = { graphNodeIndex = 1, x = 0, y = 0, z = 0, distance = 0,};
local node2 = graph:AddNode();
node2.data = { graphNodeIndex = 2, x = 10, y = 0, z = 0, distance = 0,};
local node3 = graph:AddNode();
node3.data = { graphNodeIndex = 3, x = 10, y = 0, z = 0, distance = 0,};
local node4 = graph:AddNode();
node4.data = { graphNodeIndex = 4, x = 10, y = 0, z = 0, distance = 0,};
local node5 = graph:AddNode();
node5.data = { graphNodeIndex = 5, x = 20, y = 0, z = 0, distance = 0,};
local node6 = graph:AddNode();
node6.data = { graphNodeIndex = 6, x = 20, y = 0, z = 0, distance = 0,};
local node7 = graph:AddNode();
node7.data = { graphNodeIndex = 7, x = 30, y = 0, z = 0, distance = 0,};
local node8 = graph:AddNode();
node8.data = { graphNodeIndex = 8, x = 30, y = 0, z = 0, distance = 0,};

graph:AddArc(node1,node2);
graph:AddArc(node1,node3);
graph:AddArc(node1,node4);
graph:AddArc(node3,node5);
graph:AddArc(node3,node6);
graph:AddArc(node6,node7);
graph:AddArc(node6,node8);

local bFind,list = GraphHelp.Search_Astar(graph,node1,node8)
commonlib.echo(list);


NPL.load("(gl)script/ide/GraphHelp.lua");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
GraphHelp.Test(30042,30414)
--]]
----------------------------------------------
NPL.load("(gl)script/ide/ExternalInterface.lua");

local GraphHelp = commonlib.gettable("commonlib.GraphHelp");

NPL.load("(gl)script/ide/STL.lua");
local Queue = commonlib.gettable("commonlib.Queue");
--默认支持5个参数
function GraphHelp.DepathFirst(node,visit,...)
	if(not node)then return end
	local arg = {...};
	local marked_map = {};
	local stack = { node };
	local c = 2;
	local k,i;
	local arcs;
	local n;
	while(c > 1) do
		c = c - 1;
		n = stack[c];
		if(not n)then return end
		local marked = marked_map[n];
		if(not marked)then
			marked_map[n] = true;
			if(visit and type(visit) == "function")then
				if(arg)then
					visit(n,arg[1],arg[2],arg[3],arg[4],arg[5]);
				else
					visit(n,arg);
				end
			end
			k = n:GetNumArcs();
			arcs = n.arcs;

			local item = arcs:first();
			while (item) do
				c = c + 1;
				stack[c] = item.node;
				item = arcs:next(item)
			end
		end
	end
end
--深度优先 
function GraphHelp.Search_DepthFirst_FromRoot(graph,visit)
	if(not graph)then return end
	local marked_map = {};
	local node;
	for node in graph:Next() do
		GraphHelp.Search_DepthFirst(node,marked_map,visit);
	end
end
--深度优先 从指定node开始搜索
function GraphHelp.Search_DepthFirst(root_node,marked_map,visit)
	if(not root_node)then return end
	marked_map = marked_map or {};
	local function search(node)
		if(not node)then return end
		local arc;
		for arc in node:NextArc() do
			local _node = arc:GetNode();
			if(not marked_map[_node])then
				marked_map[_node] = true;
				if(visit and type(visit) == "function")then
					visit(_node);
				end
				search(_node);
			end
		end
	end
	if(not marked_map[root_node])then
		marked_map[root_node] = true;
		if(visit and type(visit) == "function")then
			visit(root_node);
		end
	end
	search(root_node);
end
--广度优先  深度优先 
function GraphHelp.Search_BreadthFirst_FromRoot(graph,visit)
	if(not graph)then return end
	local marked_map = {};
	local queue = commonlib.Queue:new(); 
	local node;
	for node in graph:Next() do
		if(not marked_map[node])then
			marked_map[node] = true;
			GraphHelp.Search_BreadthFirst(node,marked_map,queue,visit);
		end
	end
end
--广度优先 从指定node开始搜索
function GraphHelp.Search_BreadthFirst(root_node,marked_map,queue,visit)
	if(not root_node)then return end
	marked_map = marked_map or {};
	queue = queue or commonlib.Queue:new(); 
	if(visit and type(visit) == "function")then
		visit(root_node);
	end
	local arc;
	for arc in root_node:NextArc() do
		local _node = arc:GetNode();
		if(not marked_map[_node])then
			marked_map[_node] = true;
			queue:pushright(_node);
			if(visit and type(visit) == "function")then
				visit(_node);
			end
		end
	end
	while(queue.last > -1)do
		local node = queue:popright();
		if(node)then
			local arc;
			for arc in node:NextArc() do
				local _node = arc:GetNode();
				if(not marked_map[_node])then
					marked_map[_node] = true;
					queue:pushright(_node);
					if(visit and type(visit) == "function")then
						visit(_node);
					end
				end
			end
		end
	end
end
--优先队列
local PriorityQueue = commonlib.gettable("commonlib.PriorityQueue");
function PriorityQueue:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.Count = 0;
	o.map = {};
	o.max_priority = 1;
	return o
end
function PriorityQueue:IsEmpty()
	if(self.Count == 0)then
		return true;
	end
end
--@param node:任意数据结构
--@param priority: >=1 的整数
function PriorityQueue:Enqueue(node,priority)
	if(not node)then return end
	priority = priority or 1;
	if(priority < 1)then
		priority = 1;
	end
	self.Count = self.Count + 1;
	local queue = self.map[priority];
	if(not queue)then
		queue = commonlib.Queue:new(); 
		self.map[priority] = queue; 
	end
	queue:pushright(node);
	if(priority > self.max_priority)then
		self.max_priority = priority;
	end
end
function PriorityQueue:Dequeue()
	local k;
	for k = 1,self.max_priority do
		local queue = self.map[k];
		if(queue)then
			local node = queue:popright();
			if(queue.last == -1)then
				self.map[k] = nil;
			end
			self.Count = self.Count - 1;
			return node;
		end
	end
end
--[[
	local wp = {
		x = 0, y = 0, z = 0,
		distance = 0,
		prev = nil,
	}
--]]

function GraphHelp.Search_Astar(graph,start_node,goal_node)
	if(not graph or not start_node or not goal_node)then
		return
	end
	local marked_map = {};
	local linked_map = {};
	--两点之间的距离
	local function DistanceTo(wp1,wp2)
		if(not wp1 or not wp2)then
			return 0;
		end
		local dx = wp1.x - wp2.x;
		local dy = wp1.y - wp2.y;
		local dz = wp1.z - wp2.z;
		return math.sqrt(dx * dx + dy * dy + dz * dz);
	end
	--清空prev 
	local function ClearTemp()
		local wp,v;
		for wp,v in pairs(linked_map) do
			wp.prev = nil;
			wp.distance = 0;
		end
	end
	--获取路径
	local function GetPathList(wp)
		local list = {};
		while(wp) do
			table.insert(list,wp);
			wp = wp.prev;
		end
		return list;
	end
	local queue = commonlib.PriorityQueue:new();  
	queue:Enqueue(start_node,1);
	local cur_node;
	while(queue.Count > 0)do
		cur_node = queue:Dequeue();
		local cur_wp = cur_node:GetData();
		if(not cur_wp)then
			ClearTemp();
			return false;
		end
		if(not marked_map[cur_wp])then
			marked_map[cur_wp] = true;
			if(cur_node == goal_node)then
				local list = GetPathList(cur_wp);
				ClearTemp();
				return true,list;
			end
			local arc;
			for arc in cur_node:NextArc() do
				local next_node = arc:GetNode();
				local next_wp = next_node:GetData();
				if(not marked_map[next_wp])then
					local distance = cur_wp.distance + DistanceTo(cur_wp,next_wp);
					if(next_wp.prev ~= nil)then
						if(distance < next_wp.distance)then
							next_wp.distance = distance;
							next_wp.prev = cur_wp;
						else

						end
					else
						next_wp.distance = distance;
						next_wp.prev = cur_wp;

						linked_map[next_wp] = true;
					end
					local heuristics = DistanceTo(next_wp,goal_node:GetData()) + distance;
					heuristics = math.floor(heuristics);
					queue:Enqueue(next_node,heuristics);
				end
			end
		end
	end
	ClearTemp();
	return false;
end
--[[
NPL.load("(gl)script/ide/GraphHelp.lua");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
local start_id = "cf75e975-4bc3-4614-8836-f74ac3e9dfb3";
local goal_id = "39342212-f789-4bb3-9049-bc8a5ecade68";
GraphHelp.FindPath_Handle("config/Aries/WayPoints/61HaqiTown_teen.WayPoint.xml",start_id,goal_id);
--]]
--返回 graph,map_nodes
function GraphHelp.BuildGraph(path)
	if(not path)then return end
	local Graph = commonlib.gettable("commonlib.Graph");
	local graph = Graph:new()

	local map_nodes = {};
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "//items/nodes/node") do
		local id = node.attr.id;
		local position = node.attr.position;
		local tag = node.attr.tag;
		local radius = node.attr.radius;
		local isTranspotNode = (node.attr.can_transport == "true") or false;
		if(id and position)then
			local g_node = graph:AddNode();
			local x,y,z = string.match(position,"(.+),(.+),(.+)");
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
			g_node.data = { id = id, x = x, y = y, z = z, radius = radius, tag = tag, distance = 0,isTranspotNode = isTranspotNode};
			--map graph node
			map_nodes[id] = g_node;
		end
	end
	
	for node in commonlib.XPath.eachNode(xmlRoot, "//items/links/node") do
		local source = node.attr.source;
		local target = node.attr.target;
		if(source and target)then
			local s_node = map_nodes[source];
			local g_node = map_nodes[target];
			if(s_node and g_node)then
				graph:AddArc(s_node,g_node);
				graph:AddArc(g_node,s_node);
			else
				LOG.warn("can't find graph node " .. source .. " or " .. target);
			end
		end
	end
	return graph,map_nodes;
end
function GraphHelp.FindPath_Handle(waypoint_path,start_id,goal_id)
	commonlib.echo("========GraphHelp.FindPath_Handle");
	commonlib.echo(waypoint_path);
	commonlib.echo(start_id);
	commonlib.echo(goal_id);
	if(not waypoint_path or not start_id or not goal_id)then
		return
	end
	local graph,map_nodes = GraphHelp.BuildGraph(waypoint_path)
	if(graph and map_nodes)then
		local start_node,goal_node = map_nodes[start_id],map_nodes[goal_id];
		local bFind,list = GraphHelp.Search_Astar(graph,start_node,goal_node)
		commonlib.echo("============astar");
		commonlib.echo(start_node.data);
		commonlib.echo(goal_node.data);
		commonlib.echo(bFind);
		commonlib.echo(list);
		if(list)then
			local len = #list;
			local k;
			local result = {};
			local i;
			for k = 1, len do
				i = len - k + 1;
				table.insert(result,list[i]);
			end
			commonlib.echo(result);
			ExternalInterface.Call("GraphHelp.FindPath_Result",result);

		end
	end
end