--[[
Title: ObjectsCreator
Author(s): Leio
Date: 2009/1/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
local ObjectsCreator = {
}
commonlib.setfield("CommonCtrl.Display.Util.ObjectsCreator",ObjectsCreator);
function ObjectsCreator.CreateObjectByParams(classType,params)
	local obj;
	if(classType == "ZoneNode" or classType == "PortalNode")then
		local name = params.name;
		local w,h,d,facing = params.width,params.height,params.depth,params.facing;
		if(classType == "ZoneNode")then
			local zoneplanes = params.zoneplanes;
			obj = ParaScene.CreateZone(name,zoneplanes,w,h,d,facing);
		else
			local homezone = params.homezone;
			local targetzone = params.targetzone;
			local portalpoints = params.portalpoints;
			obj = ParaScene.CreatePortal(name,homezone,targetzone,portalpoints,w,h,d,facing);
		end
	else
		obj = ObjEditor.CreateObjectByParams(params)	
	end
	
	--if(classType == "Actor3D" or classType == "Building3D" or classType == "Flower")then
		--obj = ObjEditor.CreateObjectByParams(params)	
	--elseif(classType == "ZoneNode" or classType == "PortalNode")then
		--local name = params.name;
		--local w,h,d,facing = params.width,params.height,params.depth,params.facing;
		--if(classType == "ZoneNode")then
			--local zoneplanes = params.zoneplanes;
			--obj = ParaScene.CreateZone(name,zoneplanes,w,h,d,facing);
		--else
			--local homezone = params.homezone;
			--local targetzone = params.targetzone;
			--local portalpoints = params.portalpoints;
			--obj = ParaScene.CreatePortal(name,homezone,targetzone,portalpoints,w,h,d,facing);
		--end
	--end
	return obj;
end
-- pos_x, pos_y,pos_z: is the point at the bottom center of the box. 
-- obb_x,obb_y,obb_z: is the size of the box. 
-- column:true ¼ì²âÈıÎ¬ false ¼ì²â¶şÎ¬£¬Ä¬ÈÏÎªfalse
function ObjectsCreator.Contains(point,box,column)
	if(not point or not box)then return end
	local dx =  box.obb_x/2;
	local dy =  box.obb_y;
	local dz =  box.obb_z/2;
	local min_x = box.pos_x - dx;
	local min_y = box.pos_y - dy;
	local min_z = box.pos_z - dz;
	
	local max_x = box.pos_x + dx;
	local max_y = box.pos_y + dy;
	local max_z = box.pos_z + dz;
	if(column)then
		if(point.x >= min_x and point.y >= min_y  and point.z >= min_z and point.x <= max_x and point.y <= max_y  and point.z <= max_z)then
			return true;
		end
	else
		if(point.x >= min_x and  point.z >= min_z and point.x <= max_x  and point.z <= max_z)then
			return true;
		end
	end
end
function ObjectsCreator.HitTest(box1,box2,column)
	if(not box1 or not box2)then return end
	box1 = ObjectsCreator.GetRect(box1);
	box2 = ObjectsCreator.GetRect(box2);
	if(math.abs(box1.min_x + box1.max_x - box2.min_x - box2.max_x) < (box1.max_x - box1.min_x + box2.max_x - box2.min_x))then
		if(math.abs(box1.min_z + box1.max_z - box2.min_z - box2.max_z) < (box1.max_z - box1.min_z + box2.max_z - box2.min_z))then
			if(column)then
				if(math.abs(box1.min_y + box1.max_y - box2.min_y - box2.max_y) < (box1.max_y - box1.min_y + box2.max_y - box2.min_y))then
					return true;
				end
			else
				return true;
			end
		end
	end
end
function ObjectsCreator.GetRect(box)
	if(not box)then return end
	local dx =  box.obb_x/2;
	local dy =  box.obb_y;
	local dz =  box.obb_z/2;
	local min_x = box.pos_x - dx;
	local min_y = box.pos_y;
	local min_z = box.pos_z - dz;
	
	local max_x = box.pos_x + dx;
	local max_y = box.pos_y + dy;
	local max_z = box.pos_z + dz;
	return {
		min_x = min_x,
		min_y = min_y,
		min_z = min_z,
		max_x = max_x,
		max_y = max_y,
		max_z = max_z,
	}
end


