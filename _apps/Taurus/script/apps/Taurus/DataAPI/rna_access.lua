--[[
Title: Runtime Naming Architecture(RNA) accessor functions
Author(s): LiXizhi
Date: 2010.10.23
Desc: RNA is an high-level abstracted data api, which provides a unified and 
human-readable data access to low level data objects. Internally, it will call the low level data api. 
The following lower level data types are recognized: ParaObject, ParaUIObject, IPCBinding Data Object. ParaAttributeObject, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/DataAPI/rna_access.lua");
local RNA = commonlib.gettable("PETools.RNA");
------------------------------------------------------------
]]
local RNA = commonlib.gettable("PETools.RNA");

function RNA.boolean_get(ptr, name)
	-- TODO: 
end