--[[
Title: ShapesDrawer
Author(s): LiXizhi@yeah.net
Date: 2015/8/12
Desc: ShapesDrawer provides static functions to help drawing standard shapes like cube, circle, etc, 
inside Overlay's paintEvent. 
Note: Performance is optimized by caching triangle tables. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Overlays/ShapesDrawer.lua");
local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");
------------------------------------------------------------
]]

local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");

local cube_template = {
	{-1, -1, -1},	{-1, 1, -1},	{1, 1, -1},	{1, -1, -1},
	{-1, -1, 1},	{-1, 1, 1},		{1, 1, 1},	{1, -1, 1},
};
local cube_vertices = {	{},{},{},{},{},{},{},{},{},};
-- 8 triangles
local fake_cube_triangles = {
	cube_vertices[1],cube_vertices[2],cube_vertices[3],	cube_vertices[1],cube_vertices[3],cube_vertices[4],
	cube_vertices[5],cube_vertices[6],cube_vertices[7],	cube_vertices[5],cube_vertices[7],cube_vertices[8],
	cube_vertices[2],cube_vertices[6],cube_vertices[8],	cube_vertices[2],cube_vertices[8],cube_vertices[4],
	cube_vertices[1],cube_vertices[5],cube_vertices[7],	cube_vertices[1],cube_vertices[7],cube_vertices[3],
};
-- 12 triangles
local cube_triangles = {
	cube_vertices[1],cube_vertices[2],cube_vertices[3],	cube_vertices[1],cube_vertices[3],cube_vertices[4],
	cube_vertices[5],cube_vertices[6],cube_vertices[7],	cube_vertices[5],cube_vertices[7],cube_vertices[8],
	cube_vertices[1],cube_vertices[2],cube_vertices[6],	cube_vertices[1],cube_vertices[6],cube_vertices[5],
	cube_vertices[4],cube_vertices[3],cube_vertices[7],	cube_vertices[4],cube_vertices[7],cube_vertices[8],
	cube_vertices[2],cube_vertices[6],cube_vertices[7],	cube_vertices[2],cube_vertices[7],cube_vertices[3],
	cube_vertices[1],cube_vertices[5],cube_vertices[8],	cube_vertices[1],cube_vertices[8],cube_vertices[4],
}
-- draw a cube by specifying its center and radius(half length)
-- @param bFakeCube: if true (default), we will emulate a cube by drawing only 8 triangles, instead of 12. when no shading
function ShapesDrawer.DrawCube(painter, x,y,z, radius, bFakeCube)
	for i=1,8 do
		local to = cube_vertices[i] 
		local from = cube_template[i] 
		to[1], to[2], to[3] = x+from[1]*radius, y+from[2]*radius, z+from[3]*radius;
	end	
	if(bFakeCube~=true) then
		painter:DrawTriangleList(fake_cube_triangles);
	else
		painter:DrawTriangleList(cube_triangles);
	end
end

local lineList = {{0,0,0}, {1,0,0}};

-- draw a line
function ShapesDrawer.DrawLine(painter, from_x,from_y,from_z, to_x, to_y, to_z)
	local from = lineList[1];
	from[1], from[2], from[3] = from_x,from_y,from_z or 0;
	local to = lineList[2];
	to[1], to[2], to[3] = to_x, to_y, to_z or 0;
	painter:DrawLineList(lineList);
end

local ring_triangles = {};
local circle_triangles = {};

local function GetVertice(triangles, nIndex)
	local v = triangles[nIndex]
	if(not v) then
		v = {}
		triangles[nIndex] = v;
	end
	return v;
end

local two_pi = 3.14159265359 * 2;
local axis_index = {x=1, y=2, z=3};
-- draw a circle perpendicular to a specified axis with center and radius
-- @param axis: "x", "y", "z". perpendicular to which axis
-- @param bFill: if true (default to nil), we will fill the circle with current brush 
-- @param segment: if nil, we will automatically determine segment by radius. 
-- @param fromAngle: default to 0;
-- @param toAngle: default to 2*math.pi;
-- @param center_offset: default to 0.
function ShapesDrawer.DrawCircle(painter, cx,cy,cz, radius, axis, bFill, segment, fromAngle, toAngle, center_offset)
	fromAngle = fromAngle or 0;
	toAngle = toAngle or two_pi;
	if(toAngle<fromAngle) then
		toAngle = toAngle + two_pi;
	end
	if(not segment) then
		segment = math.max(5, math.min(100, radius*(toAngle - fromAngle)/0.05));
	end
	segment = math.floor(segment);
	local delta_angle = (toAngle - fromAngle) / segment;

	local last_x, last_y = math.cos(fromAngle)*radius, math.sin(fromAngle)*radius;
	local nIndex = 1;
	local triangles = if_else(bFill, circle_triangles, ring_triangles);
	for i=1, segment do
		local angle = fromAngle+delta_angle*i;	
		local x, y = math.cos(angle)*radius, math.sin(angle)*radius;
		local v1 = GetVertice(triangles, nIndex);
		local v2 = GetVertice(triangles, nIndex+1);
		if(axis == "x") then
			v1[1], v1[2], v1[3] = cx, cy + last_x, cz + last_y;
			v2[1], v2[2], v2[3] = cx, cy + x, cz + y;
		elseif(axis == "y") then
			v1[1], v1[2], v1[3] = cx + last_y, cy, cz + last_x;
			v2[1], v2[2], v2[3] = cx + y, cy, cz + x;
		else -- "z"
			v1[1], v1[2], v1[3] = cx + last_x, cy + last_y, cz;
			v2[1], v2[2], v2[3] = cx + x, cy + y, cz;
		end
		if(bFill) then
			local v3 = GetVertice(triangles, nIndex+2);
			v3[1], v3[2], v3[3] = cx, cy, cz; 
			if(center_offset and center_offset~=0) then
				v3[axis_index[axis]] = v3[axis_index[axis]] + center_offset;
			end
			nIndex = nIndex + 3;
		else
			nIndex = nIndex + 2;
		end
		last_x, last_y = x, y;
	end
	if(bFill) then
		painter:DrawTriangleList(triangles, segment);
	else
		painter:DrawLineList(triangles, segment);
	end
end

-- draw arrow head 
function ShapesDrawer.DrawArrowHead(painter, cx,cy,cz, axis, radius, length, segment)
	if(not segment) then
		segment = math.max(3, math.min(100, radius*(two_pi)/0.03));
	end
	segment = math.floor(segment);
	length = length or radius*2.5;
	ShapesDrawer.DrawCircle(painter, cx,cy,cz, radius, axis, true, segment, 0, two_pi);
	ShapesDrawer.DrawCircle(painter, cx,cy,cz, radius, axis, true, segment, 0, two_pi, length);
end