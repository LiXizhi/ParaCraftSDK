--[[
Title: MotionView
Author(s): Leio
Date: 2010/05/18
Desc:

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionView.lua");
local motionview = CommonCtrl.MotionView:new{
	FinishedCallback = function()
		commonlib.echo("===========motion finished");
	end,
	UpdateCallback = function(node)
		commonlib.echo(node);
	end,
}
local nodes = {
	{ x = 0, y = 0, z = 0, },
	{ x = 0, y = 100, z = 0, duration = 1000, },
	{ x = 0, y = 100, z = 100, duration = 1000, motiontype = "easeInQuad" }
}
motionview:AddNodes(nodes);
motionview:DoAnimation();
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
--node format
--local node  = { x = 0, y = 0, z = 0, duration = 10000, motiontype = ""}
local MotionView = commonlib.inherit(nil,{
	FinishedCallback = nil,--动画结束
	UpdateCallback = nil,--运行计算的结果
	nodes = nil,
	duration = 10,
	index = 1,
	len = 0,
})
commonlib.setfield("CommonCtrl.MotionView",MotionView);

function MotionView:ctor()
	if(not self.uid)then
		self.uid = ParaGlobal.GenerateUniqueID();
	end

	self.nodes = {};
	self.index = 1;
	self.timer = commonlib.Timer:new({callbackFunc = function(timer)
		self:Update();
	end})
end
function MotionView:ClearNodes()
	self.nodes = {};
end
function MotionView:AddNodes(nodes)
	if(not nodes)then return end
	local k,node;
	for k,node in ipairs(nodes) do
		self:AddNode(node);
	end
end
function MotionView:AddNode(node)
	if(not node)then return end
	node.duration = node.duration or 0;
	table.insert(self.nodes,node);
	self.len = #self.nodes;
end
function MotionView:Calculate()
	local new_nodes = {};
	local k,node;
	for k,node in ipairs(self.nodes) do
		--重置运行时间
		node["runtime"] = 0;
		table.insert(new_nodes,clone_node);
	end
	self.len = #self.nodes;
end
--默认是"easeNone"
function MotionView:GetMotionHandler(motiontype)
	if(not motiontype)then
		motiontype = "easeNone";
	end
	return MotionTypes[motiontype];
end
function MotionView:Update()
	local cur_node = self.nodes[self.index];
	local next_node =  self.nodes[self.index + 1];
	if(cur_node and next_node)then
		if(cur_node.runtime < next_node.duration)then
			cur_node.runtime = cur_node.runtime + self.duration;
			local prop,v;
			local runnode = {};
			local motiontype = next_node["motiontype"];
			local motion_handler = self:GetMotionHandler(motiontype)
			if(motion_handler)then
				for prop,v in pairs(next_node) do
					if(prop ~= "runtime" or prop ~= "duration" or prop ~= "motiontype")then
						--只支持数值转换
						v = tonumber(v);
						if(v)then
							local begin = cur_node[prop];
							if(begin)then
								local change = v - begin;
								local value = motion_handler( cur_node.runtime , begin , change , next_node.duration );	
								runnode[prop] = value;--保存计算结果
							end
						end
					end
				end
				
				if(self.UpdateCallback)then
					self.UpdateCallback(runnode);
				end
			end
		else
			self.index = self.index + 1;
		end
	end
	if(self.index >= self.len)then
		self:DoFinished();
	end
end
function MotionView:DoFinished()
	if(self.FinishedCallback)then
		self.FinishedCallback();
	end
	self.timer:Change();
end
function MotionView:DoAnimation()
	self:Calculate();
	commonlib.echo(self.nodes);
	self.index = 1;
	if(self.len < 2)then
		log("the length of motion nodes must > 2");
		return;
	end
	self.timer:Change(0,self.duration);
end
------------------------------------------------------------
--[[
CameraMotionView
NPL.load("(gl)script/ide/MotionView.lua");
CommonCtrl.CameraMotionView.Start(nodes,defaultCamera,updateFunc,finishedFunc)

NPL.load("(gl)script/ide/MotionView.lua");
local camera = { 8.857349395752, 0.59749203920364, -1.3111418485641 };
local firstnode = {
	CameraObjectDistance = att:GetField("CameraObjectDistance",5),
	CameraLiftupAngle = att:GetField("CameraLiftupAngle",0.4),
	CameraRotY = att:GetField("CameraRotY",0),
};
local nodes = {
	{ CameraObjectDistance = firstnode.CameraObjectDistance + 8, CameraLiftupAngle = firstnode.CameraLiftupAngle + 2, CameraRotY = firstnode.CameraRotY , duration = 500, motiontype = "easeInQuad"  },
	{ CameraObjectDistance = camera[1], CameraLiftupAngle = camera[2], CameraRotY = camera[3], duration = 500, motiontype = "easeOutQuad"  },
}

CommonCtrl.CameraMotionView.Start(nodes,true,function(node)
		if(node)then
			local att = ParaCamera.GetAttributeObject();
			if(node.CameraObjectDistance)then
				att:SetField("CameraObjectDistance", node.CameraObjectDistance);
			end
			if(node.CameraLiftupAngle)then
				att:SetField("CameraLiftupAngle", node.CameraLiftupAngle);
			end
			if(node.CameraRotY)then
				att:SetField("CameraRotY", node.CameraRotY);
			end
		end
	end,
	function()
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc()
		end
	end)
--]]
------------------------------------------------------------
--node format
--local node  = { CameraObjectDistance = 0, CameraLiftupAngle = 0, CameraRotY = 0, duration = 10000, motiontype = ""}
local CameraMotionView = {

}
commonlib.setfield("CommonCtrl.CameraMotionView",CameraMotionView);
function CameraMotionView.Start(nodes,defaultCamera,updateFunc,finishedFunc)
	if(not nodes)then return end
	if(not CameraMotionView.motionview)then
		CameraMotionView.motionview = CommonCtrl.MotionView:new();
	end
	local new_nodes = {};
	if(defaultCamera)then
		local node = {};
		local att = ParaCamera.GetAttributeObject();
		node.CameraObjectDistance = att:GetField("CameraObjectDistance",5);
		node.CameraLiftupAngle = att:GetField("CameraLiftupAngle",0.4);
		node.CameraRotY = att:GetField("CameraRotY",0);
		table.insert(new_nodes,node);
	end
	local k,node;
	for k,node in ipairs(nodes) do
		table.insert(new_nodes,node);	end
	local motionview = CameraMotionView.motionview;
	motionview:ClearNodes();
	motionview:AddNodes(new_nodes);
	motionview.UpdateCallback = updateFunc;
	motionview.FinishedCallback = finishedFunc;
	motionview:DoAnimation();
end