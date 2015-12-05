--[[
Title: common defines
Author(s): LiXizhi
Date: 2015/12/5
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/STLExporter/BlockCommon.lua");
local BlockCommon = commonlib.gettable("Mod.STLExporter.BlockCommon");
BlockCommon.NeighborOfsTable;
BlockCommon.RBP_SixNeighbors;
BlockCommon.rbp_center;
------------------------------------------------------------
]]
local BlockCommon = commonlib.gettable("Mod.STLExporter.BlockCommon");
local function Int16x3(x,y,z)
	return {x = x,y = y,z = z};
end

BlockCommon.NeighborOfsTable = {
	[0] = Int16x3(0,0,0),			--0	 rbp_center 
	[1] = Int16x3(1,0,0),			--1	 rbp_pX	
	[2] = Int16x3(-1,0,0),			--2	 rbp_nX	
	[3] = Int16x3(0,1,0),			--3	 rbp_pY	
	[4] = Int16x3(0,-1,0),			--4	 rbp_nY	
	[5] = Int16x3(0,0,1),			--5	 rbp_pZ	
	[6] = Int16x3(0,0,-1),			--6	 rbp_nz	
	[7] = Int16x3(1,1,0),			--7	 rbp_pXpY	
	[8] = Int16x3(1,-1,0),			--8	 rbp_pXnY	
	[9] = Int16x3(1,0,1),			--9	 rbp_pXpZ	
	[10] = Int16x3(1,0,-1),			--10 rbp_pXnZ	
	[11] = Int16x3(-1,1,0),			--11 rbp_nXpY	
	[12] = Int16x3(-1,-1,0),		--12 rbp_nXnY	
	[13] = Int16x3(-1,0,1),			--13 rbp_nXpZ	
	[14] = Int16x3(-1,0,-1),		--14 rbp_nXnZ	
	[15] = Int16x3(0,1,1),			--15 rbp_pYpZ	
	[16] = Int16x3(0,1,-1),			--16 rbp_pYnZ	
	[17] = Int16x3(0,-1,1),			--17 rbp_nYpZ	
	[18] = Int16x3(0,-1,-1),		--18 rbp_nYnZ	
	[19] = Int16x3(1,1,1),			--19 rbp_pXpYpZ 
	[20] = Int16x3(1,1,-1),			--20 rbp_pXpYnZ 
	[21] = Int16x3(1,-1,1),			--21 rbp_pXnYPz 
	[22] = Int16x3(1,-1,-1),		--22 rbp_pXnYnZ 
	[23] = Int16x3(-1,1,1),			--23 rbp_nXpYpZ 
	[24] = Int16x3(-1,1,-1),		--24 rbp_nXpYnZ 
	[25] = Int16x3(-1,-1,1),		--25 rbp_nXnYPz 
	[26] = Int16x3(-1,-1,-1),		--26 rbp_nXnYnZ 
};

local RelativeBlockPos_Start_Index = -1;
local function get_next()
	RelativeBlockPos_Start_Index = RelativeBlockPos_Start_Index + 1;
	return RelativeBlockPos_Start_Index;
end
BlockCommon.rbp_center	= get_next(); --0
BlockCommon.rbp_pX		= get_next();
BlockCommon.rbp_nX		= get_next();
BlockCommon.rbp_pY		= get_next();
BlockCommon.rbp_nY		= get_next();
BlockCommon.rbp_pZ		= get_next();
BlockCommon.rbp_nZ		= get_next();

BlockCommon.rbp_pXpY		= get_next();
BlockCommon.rbp_pXnY		= get_next();
BlockCommon.rbp_pXpZ		= get_next();
BlockCommon.rbp_pXnZ		= get_next();

BlockCommon.rbp_nXpY		= get_next();
BlockCommon.rbp_nXnY		= get_next();
BlockCommon.rbp_nXpZ		= get_next();
BlockCommon.rbp_nXnZ		= get_next();

BlockCommon.rbp_pYpZ		= get_next();
BlockCommon.rbp_pYnZ		= get_next();
BlockCommon.rbp_nYpZ		= get_next();
BlockCommon.rbp_nYnZ		= get_next();

BlockCommon.rbp_pXpYpZ	= get_next();
BlockCommon.rbp_pXpYnZ	= get_next();
BlockCommon.rbp_pXnYPz	= get_next();
BlockCommon.rbp_pXnYnZ	= get_next();
BlockCommon.rbp_nXpYpZ	= get_next();
BlockCommon.rbp_nXpYnZ	= get_next();
BlockCommon.rbp_nXnYPz	= get_next();
BlockCommon.rbp_nXnYnZ	= get_next();

BlockCommon.RBP_SixNeighbors = {
	[0] = BlockCommon.rbp_pY,
	[1] = BlockCommon.rbp_nZ,
	[2] = BlockCommon.rbp_nY,
	[3] = BlockCommon.rbp_nX,
	[4] = BlockCommon.rbp_pX,
	[5] = BlockCommon.rbp_pZ,
};

