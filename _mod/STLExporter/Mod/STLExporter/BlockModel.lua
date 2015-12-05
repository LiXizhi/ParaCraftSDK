--[[
Title: block model
Author(s): LiXizhi
Date: 2015/12/4
Desc: a single cube block model containing all vertices
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/STLExporter/BlockModel.lua");
local BlockModel = commonlib.gettable("Mod.STLExporter.BlockModel");
local node = BlockModel:new();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local BlockModel = commonlib.inherit(nil,commonlib.gettable("Mod.STLExporter.BlockModel"));

function BlockModel:ctor()
	self.m_vertices = {};
end

-- init the model as a cube
function BlockModel:InitCube()
	self:MakeCube();
	return self;
end

-- make this block model as a cube 
function BlockModel:MakeCube()
	local vertices = self.m_vertices;

	for i=1, 24 do
		vertices[i] = {};
	end
	--top face
	vertices[1].position = vector3d:new({0,1,0});
	vertices[2].position = vector3d:new({0,1,1});
	vertices[3].position = vector3d:new({1,1,1});
	vertices[4].position = vector3d:new({1,1,0});

	vertices[1].normal = vector3d:new({0,1,0});
	vertices[2].normal = vector3d:new({0,1,0});
	vertices[3].normal = vector3d:new({0,1,0});
	vertices[4].normal = vector3d:new({0,1,0});

	--front face
	vertices[5].position = vector3d:new({0,0,0});
	vertices[6].position = vector3d:new({0,1,0});
	vertices[7].position = vector3d:new({1,1,0});
	vertices[8].position = vector3d:new({1,0,0});

	vertices[5].normal = vector3d:new({0,0,-1});
	vertices[6].normal = vector3d:new({0,0,-1});
	vertices[7].normal = vector3d:new({0,0,-1});
	vertices[8].normal = vector3d:new({0,0,-1});

	--bottom face
	vertices[9].position = vector3d:new({0,0,1});
	vertices[10].position = vector3d:new({0,0,0});
	vertices[11].position = vector3d:new({1,0,0});
	vertices[12].position = vector3d:new({1,0,1});

	vertices[9].normal = vector3d:new({0,-1,0});
	vertices[10].normal = vector3d:new({0,-1,0});
	vertices[11].normal = vector3d:new({0,-1,0});
	vertices[12].normal = vector3d:new({0,-1,0});

	--left face
	vertices[13].position = vector3d:new({0,0,1});
	vertices[14].position = vector3d:new({0,1,1});
	vertices[15].position = vector3d:new({0,1,0});
	vertices[16].position = vector3d:new({0,0,0});

	vertices[13].normal = vector3d:new({-1,0,0});
	vertices[14].normal = vector3d:new({-1,0,0});
	vertices[15].normal = vector3d:new({-1,0,0});
	vertices[16].normal = vector3d:new({-1,0,0});

	--right face
	vertices[17].position = vector3d:new({1,0,0});
	vertices[18].position = vector3d:new({1,1,0});
	vertices[19].position = vector3d:new({1,1,1});
	vertices[20].position = vector3d:new({1,0,1});

	vertices[17].normal = vector3d:new({1,0,0});
	vertices[18].normal = vector3d:new({1,0,0});
	vertices[19].normal = vector3d:new({1,0,0});
	vertices[20].normal = vector3d:new({1,0,0});

	--back face
	vertices[21].position = vector3d:new({1,0,1});
	vertices[22].position = vector3d:new({1,1,1});
	vertices[23].position = vector3d:new({0,1,1});
	vertices[24].position = vector3d:new({0,0,1});

	vertices[21].normal = vector3d:new({0,0,1});
	vertices[22].normal = vector3d:new({0,0,1});
	vertices[23].normal = vector3d:new({0,0,1});
	vertices[24].normal = vector3d:new({0,0,1});
end

function BlockModel:OffsetPosition(dx, dy, dz)
	for _, vertice in pairs(self.m_vertices) do
		if(vertice.position)then
			vertice.position:add(dx, dy, dz);
		end
	end
end

-- TODO: please note it does not clone the vertex
-- @param nVertexIndex: 0 based index
function BlockModel:AddVertex(from_block, nVertexIndex)
	table.insert(self.m_vertices, from_block.m_vertices[nVertexIndex+1]);
end

function BlockModel:AddFace(from_block, nFaceIndex)
	local nFirstVertex = nFaceIndex * 4;
	for v = 0,3 do
		local i = nFirstVertex + v;
		self:AddVertex(from_block, i);
	end
end

function BlockModel:GetVertices()
	return self.m_vertices;
end

-- each rectangle face has two triangles, and 4 vertices
function BlockModel:GetFaceCount()
	return (self:GetVerticesCount()) / 4;
end

function BlockModel:GetVerticesCount()
	return #(self.m_vertices);
end

function BlockModel:GetVertex(nIndex)
	return self.m_vertices[nIndex+1];
end

-- @param nFaceIndex: 0 based index
-- @param nTriangleIndex: 0 for first, 1 for second
-- @return v1,v2,v3 on the face
function BlockModel:GetFaceTriangle(nFaceIndex, nTriangleIndex)
	local nFirstVertexIndex = nFaceIndex*4+1;
	local vertices = self.m_vertices;
	if(nTriangleIndex == 0) then
		return vertices[nFirstVertexIndex].position, vertices[nFirstVertexIndex+1].position, vertices[nFirstVertexIndex+2].position;
	else
		return vertices[nFirstVertexIndex].position, vertices[nFirstVertexIndex+2].position, vertices[nFirstVertexIndex+3].position;
	end
end