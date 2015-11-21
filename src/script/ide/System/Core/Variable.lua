--[[
Title: Variable types
Author(s): LiXizhi, 
Date: 2015/9/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Variable.lua");
local ATTRIBUTE_FIELDTYPE = commonlib.gettable("System.Core.ATTRIBUTE_FIELDTYPE");
------------------------------------------------------------
]]
local i=0;
local function AutoEnum()
	i=i+1;
	return i;
end

local ATTRIBUTE_FIELDTYPE = commonlib.createtable("System.Core.ATTRIBUTE_FIELDTYPE", {
	-- unknown
	FieldType_unknown = 0,
	-- get(), set()
	FieldType_void = AutoEnum(),
	-- get(int*) set(int)
	FieldType_Int = AutoEnum(),
	-- get(bool*) set(bool)
	FieldType_Bool = AutoEnum(),
	-- get(float*) set(float)
	FieldType_Float = AutoEnum(),
	-- get(float*,float* ) set(float, float)
	FieldType_Float_Float = AutoEnum(),
	-- get(float*,float*,float*) set(float, float, float)
	FieldType_Float_Float_Float = AutoEnum(),
	-- get(int*) set(int)
	FieldType_Enum = AutoEnum(),
	-- get(double*) set(double)
	FieldType_Double = AutoEnum(),
	-- get(Vector2*) set(Vector2)
	FieldType_Vector2 = AutoEnum(),
	-- get(Vector3*) set(Vector3)
	FieldType_Vector3 = AutoEnum(),
	-- get(Vector4*) set(Vector4)
	FieldType_Vector4 = AutoEnum(),
	-- get(Quaternion*) set(Quaternion)
	FieldType_Quaternion = AutoEnum(),
	-- get(const char**) set(const char*)
	FieldType_String = AutoEnum(),
	FieldType_DWORD = AutoEnum(),
	FieldType_DVector3 = AutoEnum(),
	FieldType_Float_Float_Float_Float = AutoEnum(),
	FieldType_Matrix4 = AutoEnum(),
	FieldType_Double_Double = AutoEnum(),
	FieldType_Double_Double_Double = AutoEnum(),
	-- following types are all animated
	FieldType_Animated = AutoEnum(),
	FieldType_AnimatedInt = AutoEnum(),
	FieldType_AnimatedFloat = AutoEnum(),
	FieldType_AnimatedDouble = AutoEnum(),
	FieldType_AnimatedVector2 = AutoEnum(),
	FieldType_AnimatedVector3 = AutoEnum(),
	FieldType_AnimatedDVector3 = AutoEnum(),
	FieldType_AnimatedVector4 = AutoEnum(),
	FieldType_AnimatedQuaternion = AutoEnum(),
	FieldType_Deprecated = 0xffffffff
});