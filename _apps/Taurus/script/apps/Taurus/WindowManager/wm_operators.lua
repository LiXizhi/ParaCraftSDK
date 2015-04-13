--[[
Title: operator
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/Taurus/WindowManager/wm_operators.lua");
------------------------------------------------------------
]]
local wmOperator = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmOperator"));

-- this one is the operator itself, stored in files for macros etc 
-- operator + operatortype should be able to redo entirely, but for different contextes 
function wmOperator:ctor()
	-- /* saved */
	-- used to retrieve type pointer
	self.idname = nil;
	-- RNA pointer
	self.ptr = nil;

	-- /* runtime */
	-- operator type definition from idname
	sefl.type = nil;
	-- custom storage, only while operator runs 
	self.customdata = nil;

	-- errors and warnings storage
	self.reports = nil;

	-- list of operators, can be a tree 
	self.macro = nil;
	-- current running macro, not saved
	self.opm = nil;

	-- /* operator type exec(), invoke() modal(), return values */
	-- #define OPERATOR_RUNNING_MODAL	1
	-- #define OPERATOR_CANCELLED		2
	-- #define OPERATOR_FINISHED		4
	-- /* add this flag if the event should pass through */
	-- #define OPERATOR_PASS_THROUGH	8
	-- /* in case operator got executed outside WM code... like via fileselect */
	-- #define OPERATOR_HANDLED		16
	self.flag = nil;
end

-- free this operator
function wmOperator:free()
end