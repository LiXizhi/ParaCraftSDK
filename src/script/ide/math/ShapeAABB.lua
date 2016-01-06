--[[
Title: Shape AABB in 3d space
Author(s): LiXizhi
Date: 2013/2/8
Desc: AABB-related code. (axis-aligned bounding box). Use CShapeBox, if one wants min, max box.*/
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
NPL.load("(gl)script/ide/math/ShapeAABB.lua");
local ShapeAABB = commonlib.gettable("mathlib.ShapeAABB");
local aabb = ShapeAABB:new();
aabb:SetPointAABB(vector3d:new({1,1,1}))
aabb:SetMinMax(vector3d:new({1,1,1}), vector3d:new({2,2,2}))
aabb:Extend(vector3d:new({14,1,1}))
echo({aabb:GetMin(), aabb:GetMax()})
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
NPL.load("(gl)script/ide/math/AABBPool.lua");
local AABBPool = commonlib.gettable("mathlib.AABBPool");

local ShapeAABB = commonlib.gettable("mathlib.ShapeAABB");
ShapeAABB.__index = ShapeAABB;

local math_abs = math.abs;

-- create a new shape
function ShapeAABB:new(o)
	o = o or {};
	setmetatable(o, self);

	o.mCenter = vector3d:new({0,0,0});
	o.mExtents = vector3d:new({-999999999,-999999999,-999999999});

	return o;
end

-- Creates a new AABB, or reuses one that's no longer in use. 
-- @param minX, minY, minZ, maxX, maxY, maxZ:
-- @param isInputCenterExtent: if true, above params is regarded as center and extent
-- returns from this function should only be used for one frame or tick, as after that they will be reused.
function ShapeAABB:new_from_pool(minX, minY, minZ, maxX, maxY, maxZ, isInputCenterExtent)
	return AABBPool.GetSingleton():GetAABB(minX, minY, minZ, maxX, maxY, maxZ, isInputCenterExtent);
end

-- make a clone 
function ShapeAABB:clone()
    local o = ShapeAABB:new();
	o.mCenter = self.mCenter:clone();
	o.mExtents = self.mExtents:clone();
	return o;
end

function ShapeAABB:clone_from_pool()
	return AABBPool.GetSingleton():GetAABB(self.mCenter[1], self.mCenter[2], self.mCenter[3], self.mExtents[1], self.mExtents[2], self.mExtents[3], true);
end

function ShapeAABB:equals(aabb)
	return (aabb and self.mCenter:equals(aabb.mCenter) and self.mExtents:equals(aabb.mExtents));
end

-- Sets the bounding box to the same bounds as the bounding box passed in
function ShapeAABB:SetBB(aabb)
	self.mCenter[1] = aabb.mCenter[1];
	self.mCenter[2] = aabb.mCenter[2];
	self.mCenter[3] = aabb.mCenter[3];
	self.mExtents[1] = aabb.mExtents[1];
	self.mExtents[2] = aabb.mExtents[2];
	self.mExtents[3] = aabb.mExtents[3];
	return self;
end

function ShapeAABB:SetCenterExtentValues(centerX, centerY, centerZ, extentX, extentY, extentZ)
	self.mCenter[1] = centerX;
	self.mCenter[2] = centerY;
	self.mCenter[3] = centerZ;
	self.mExtents[1] = extentX;
	self.mExtents[2] = extentY;
	self.mExtents[3] = extentZ;
	return self;
end

function ShapeAABB:SetMinMaxValues(minX, minY, minZ, maxX, maxY, maxZ)
	self.mCenter[1] = (maxX + minX)*0.5;
	self.mExtents[1] = (maxX - minX)*0.5;
	self.mCenter[2] = (maxY + minY)*0.5;
	self.mExtents[2] = (maxY - minY)*0.5;
	self.mCenter[3] = (maxZ + minZ)*0.5;
	self.mExtents[3] = (maxZ - minZ)*0.5;
	return self;
end

function ShapeAABB:SetMinMax(min, max)
	self.mCenter = (max + min)*0.5; 
	self.mExtents = (max - min)*0.5;	
end

function ShapeAABB:dump()
	echo({self.mCenter[1], self.mCenter[2], self.mCenter[3], self.mExtents[1], self.mExtents[2], self.mExtents[3]});
end

function ShapeAABB:SetCenterExtend(center, extents)
	self.mCenter = center; 
	self.mExtents = extents;	
end

-- set the position at the bottom center of the aabb
function ShapeAABB:SetBottomPosition(x, y, z)
	self.mCenter[1] = x;
	self.mCenter[2] = y + self.mExtents[2];
	self.mCenter[3] = z;
end

-- Get the position at the bottom center of the aabb
-- @return x,y,z;
function ShapeAABB:GetBottomPosition()
	return self.mCenter[1],  self.mCenter[2] - self.mExtents[2], self.mCenter[3];
end

function ShapeAABB:SetPointAABB(pt)
	self.mCenter = pt; 
	self.mExtents = vector3d:new({0,0,0});
end

function ShapeAABB:Offset(dx, dy, dz)
	self.mCenter[1] = self.mCenter[1] + (dx or 0);
	self.mCenter[2] = self.mCenter[2] + (dy or 0);
	self.mCenter[3] = self.mCenter[3] + (dz or 0);
	return self;
end

-- expand the extend in all directions by this amount
-- @return self;
function ShapeAABB:Expand(dx, dy, dz)
	self.mExtents[1] = self.mExtents[1] + (dx or 0);
	self.mExtents[2] = self.mExtents[2] + (dy or 0);
	self.mExtents[3] = self.mExtents[3] + (dz or 0);
	return self;
end

-- Adds the coordinates to the bounding box extending
function ShapeAABB:AddCoord(x, y, z)
    if (x < 0) then
		x = x * 0.5;
		self.mCenter[1] = self.mCenter[1] + x;
        self.mExtents[1] = self.mExtents[1] - x;
    elseif (x > 0) then
        x = x * 0.5;
		self.mCenter[1] = self.mCenter[1] + x;
        self.mExtents[1] = self.mExtents[1] + x;
    end

	if (y < 0) then
		y = y * 0.5;
		self.mCenter[2] = self.mCenter[2] + y;
        self.mExtents[2] = self.mExtents[2] - y;
    elseif (y > 0) then
        y = y * 0.5;
		self.mCenter[2] = self.mCenter[2] + y;
        self.mExtents[2] = self.mExtents[2] + y;
    end

    if (z < 0) then
		z = z * 0.5;
		self.mCenter[3] = self.mCenter[3] + z;
        self.mExtents[3] = self.mExtents[3] - z;
    elseif (z > 0) then
        z = z * 0.5;
		self.mCenter[3] = self.mCenter[3] + z;
        self.mExtents[3] = self.mExtents[3] + z;
    end

    return self;
end

-- Extends the AABB.
-- @param vector_or_x: a vector or x
-- @param y,z: should be nil if vector_or_x is a vector3.
-- @return hasModified if the AABB is modified. 
function ShapeAABB:Extend(vector_or_x, y, z)
	local x;
	if(y and z) then
		x = vector_or_x
	else
		x,y,z = vector_or_x[1], vector_or_x[2], vector_or_x[3];
	end

	local Max = self.mCenter + self.mExtents;
	local Min = self.mCenter - self.mExtents;
	local hasModified;
	if(x > Max[1]) then	
		Max[1] = x; 
		hasModified = true;
	end
	if(x < Min[1]) then	
		Min[1] = x; 
		hasModified = true;
	end

	if(y > Max[2]) then	
		Max[2] = y; 
		hasModified = true;
	end
	if(y < Min[2]) then	
		Min[2] = y; 
		hasModified = true;
	end

	if(z > Max[3]) then	
		Max[3] = z; 
		hasModified = true;
	end
	if(z < Min[3]) then	
		Min[3] = z; 
		hasModified = true;
	end

	if(hasModified) then
		self:SetMinMax(Min, Max);
	end
	return hasModified;
end

-- Get min point of the box
function ShapeAABB:GetMin()
	return  self.mCenter - self.mExtents;
end

-- Get min point of the box
function ShapeAABB:GetMinValues()
	return  self.mCenter[1] - self.mExtents[1], self.mCenter[2] - self.mExtents[2], self.mCenter[3] - self.mExtents[3];
end

-- Get max point of the box
function ShapeAABB:GetMax()
	return self.mCenter + self.mExtents;
end

-- Get max point of the box
function ShapeAABB:GetMaxValues()
	return self.mCenter[1] + self.mExtents[1], self.mCenter[2] + self.mExtents[2], self.mCenter[3] + self.mExtents[3];
end

function ShapeAABB:GetExtendValues()
	return self.mExtents[1], self.mExtents[2], self.mExtents[3];
end

function ShapeAABB:GetCenter()
	return self.mCenter:clone();
end

function ShapeAABB:SetInvalid()
	local mExtents = self.mExtents;
	mExtents[1] = -1;
	mExtents[2] = -1;
	mExtents[3] = -1;
end

-- return true if two aabb collides
-- @param a: another aabb 
-- @param axis: 1,2,3 stands for x,y,z. if nil, all three direction is checked.  
function ShapeAABB:Intersect(a, axis)
	if(not axis) then
		local mExtents = self.mExtents;
		local T = self.mCenter - a.mCenter;	 -- Vector from A to B
		return	((math_abs(T[1]) <= (a.mExtents[1] + mExtents[1]))
			and (math_abs(T[2]) <= (a.mExtents[2] + mExtents[2]))
			and (math_abs(T[3]) <= (a.mExtents[3] + mExtents[3])));
	else
		-- Vector from A to B	
		local t = self.mCenter[axis] - a.mCenter[axis];
		return (math_abs(t[axis]) <= (a.mExtents[axis] + self.mExtents[axis]));
	end
end

function ShapeAABB:IsValid()
	local mExtents = self.mExtents;
	--  Consistency condition for (Center, Extents) boxes: Extents >= 0
	if(mExtents[1] < 0 or mExtents[2] < 0 or mExtents[3] < 0) then	
		return false; 
	else
		return true;
	end
end

-- if aabb and the argument bounding boxes overlap in the Y and Z dimensions, calculate the offset between them in the X dimension.  
-- This function is used for discrete entity movement physics based on aabb to avoid collision. 
-- @param dx: delta value to try to add to self
-- @return dx if the bounding boxes do not overlap or if dy is closer to 0 then the offset between this and aabb.
function ShapeAABB:CalculateXOffset(aabb, dx)
	local self_minX, self_minY, self_minZ = self:GetMinValues();
	local self_maxX, self_maxY, self_maxZ = self:GetMaxValues();
	local aabb_minX, aabb_minY, aabb_minZ = aabb:GetMinValues();
	local aabb_maxX, aabb_maxY, aabb_maxZ = aabb:GetMaxValues();

    if (aabb_maxY > self_minY+0.0000001 and aabb_minY < self_maxY-0.0000001) then
        if (aabb_maxZ > self_minZ+0.0000001 and aabb_minZ < self_maxZ-0.0000001) then
            local deltaX;

            if (dx > 0 and aabb_maxX <= (self_minX+0.0000001)) then
                deltaX = self_minX - aabb_maxX;

                if (deltaX < dx) then
                    dx = deltaX;
                end
            end

            if (dx < 0 and aabb_minX >= (self_maxX-0.0000001)) then
                deltaX = self_maxX - aabb_minX;
				if (deltaX > dx) then
                    dx = deltaX;
                end
            end
            return dx;
        else
            return dx;
        end
    else
        return dx;
    end
end


-- if aabb and the argument bounding boxes overlap in the X and Z dimensions, calculate the offset between them in the Y dimension.  
-- This function is used for discrete entity movement physics based on aabb to avoid collision. 
-- @param dy: delta value to try to add to self
-- @return dy if the bounding boxes do not overlap or if dy is closer to 0 then the offset between this and aabb.
function ShapeAABB:CalculateYOffset(aabb, dy)
	local self_minX, self_minY, self_minZ = self:GetMinValues();
	local self_maxX, self_maxY, self_maxZ = self:GetMaxValues();
	local aabb_minX, aabb_minY, aabb_minZ = aabb:GetMinValues();
	local aabb_maxX, aabb_maxY, aabb_maxZ = aabb:GetMaxValues();

    if (aabb_maxX > self_minX+0.0000001 and aabb_minX < self_maxX-0.0000001) then
        if (aabb_maxZ > self_minZ+0.0000001 and aabb_minZ < self_maxZ-0.0000001) then
            local deltaY;

            if (dy > 0 and aabb_maxY <= (self_minY+0.0000001)) then
                deltaY = self_minY - aabb_maxY;

                if (deltaY < dy) then
                    dy = deltaY;
                end
            end

            if (dy < 0 and aabb_minY >= (self_maxY-0.0000001)) then
                deltaY = self_maxY - aabb_minY;

                if (deltaY > dy) then
                    dy = deltaY;
                end
            end

            return dy;
        else
            return dy;
        end
    else
        return dy;
    end
end

-- if aabb and the argument bounding boxes overlap in the Y and X dimensions, calculate the offset between them in the Z dimension.  
-- This function is used for discrete entity movement physics based on aabb to avoid collision. 
-- @param dz: delta value to try to add to self
-- @return dz if the bounding boxes do not overlap or if dz is closer to 0 then the offset between this and aabb.
function ShapeAABB:CalculateZOffset(aabb, dz)
	local self_minX, self_minY, self_minZ = self:GetMinValues();
	local self_maxX, self_maxY, self_maxZ = self:GetMaxValues();
	local aabb_minX, aabb_minY, aabb_minZ = aabb:GetMinValues();
	local aabb_maxX, aabb_maxY, aabb_maxZ = aabb:GetMaxValues();

    if (aabb_maxX > self_minX+0.0000001 and aabb_minX < self_maxX-0.0000001) then
        if (aabb_maxY > self_minY+0.0000001 and aabb_minY < self_maxY-0.0000001) then
            local deltaZ;

            if (dz > 0 and aabb_maxZ <= (self_minZ+0.0000001) ) then
                deltaZ = self_minZ - aabb_maxZ;

                if (deltaZ < dz) then
                    dz = deltaZ;
                end
            end

            if (dz < 0 and aabb_minZ >= (self_maxZ-0.0000001) ) then
                deltaZ = self_maxZ - aabb_minZ;

                if (deltaZ > dz) then
                    dz = deltaZ;
                end
            end

            return dz;
        else
            return dz;
        end
    else
        return dz;
    end
end