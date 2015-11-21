--[[
Title: common control shared lib
Author(s): LiXizhi
Date: 2006/5/29
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/common_control.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/AI.lua");

--[[common control library]]
if(not CommonCtrl) then CommonCtrl={}; end
if(not CommonCtrl.allcontrols) then CommonCtrl.allcontrols={}; end

function CommonCtrl.Locale()
	return function(a)
		return a or "";
	end
end

--[[add a new global control]]
function CommonCtrl.AddControl(sControlName,ctl)
	CommonCtrl.allcontrols[sControlName] = ctl;
end

--[[destroy and delete a global control. It will call the controll's Destroy() method if it exists]]
function CommonCtrl.DeleteControl(sControlName)
	local ctl = CommonCtrl.allcontrols[sControlName];
	if(ctl~=nil) then
		if(ctl.Destroy ~=nil) then
			ctl:Destroy();
		end
		--CommonCtrl.DeleteSubControls(ctl);
		CommonCtrl.allcontrols[sControlName] = nil;
	end
end

--[[ get control by name. return nil if control not found]]
function CommonCtrl.GetControl(sControlName)
	return CommonCtrl.allcontrols[sControlName];
end


-- in case, CommonCtrl.NewSubControlName's parentCtl is nil, this table ctl is used. 
CommonCtrl.DefaultNameCtl = {name = "gCtrl"};

-- create a new unqiue sub control name based on the parent ctl object. 
-- usually used for controls like tree view that needs to dynamically create a large number of sub controls whose name needs to unique
-- however, creating a unique name each sub control will pollute the global environment. Using CommonCtrl.NewSubControlName and CommonCtrl.ReleaseSubControlName to generate 
-- control names will reuse control names as much as possible while ensuring that all visible control names are unique. 
-- @param parentCtl: the parent control object. If nil, a global unnamed table is used. 
-- @return: a unique name is returned. the name is (parentCtl.name or parentCtl.Name).."."..nNextEmptyIndex
function CommonCtrl.NewSubControlName(parentCtl)	
	parentCtl = parentCtl or CommonCtrl.DefaultNameCtl;
	-- create name slots if not exists. 
	parentCtl._nameslots = parentCtl._nameslots or {nCount=0};
	local i;
	local nNextEmptyIndex;
	for i = 1, parentCtl._nameslots.nCount do 
		if(not parentCtl._nameslots[i]) then
			-- we have found an available one
			nNextEmptyIndex = i;
			break;
		end
	end
	if(not nNextEmptyIndex) then
		nNextEmptyIndex = parentCtl._nameslots.nCount + 1;
		parentCtl._nameslots.nCount = nNextEmptyIndex;
	end
	parentCtl._nameslots[nNextEmptyIndex] = true;
	return (parentCtl.name or parentCtl.Name).."."..nNextEmptyIndex;
end

-- when a sub control is not used, one needs to explicitly call this function to make its name reusable by newly created controls later on. 
-- @param parentCtl: the parent control object.  
-- @param subCtlName: the sub control name. 
function CommonCtrl.ReleaseSubControlName(parentCtl, subCtlName)
	if(parentCtl ~=nil and parentCtl._nameslots ~=nil and subCtlName~=nil) then
		local _,_, nNameSlotIndex = string.find(subCtlName, "%.(%d+)$");
		if(nNameSlotIndex~=nil) then
			nNameSlotIndex = tonumber(nNameSlotIndex);
			if(nNameSlotIndex~=nil) then
				parentCtl._nameslots[nNameSlotIndex] = nil;
			end	
		end
	end
end

-- delete all sub controls, whose name is created by CommonCtrl.NewSubControlName. Usually used by TreeView class during update. 
function CommonCtrl.DeleteAllSubControls(parentCtl)
	if(parentCtl ~=nil and parentCtl._nameslots ~=nil) then
		local i;
		for i = 1, parentCtl._nameslots.nCount do 
			if(parentCtl._nameslots[i]) then
				-- we have found an available one
				CommonCtrl.DeleteControl((parentCtl.name or parentCtl.Name).."."..i)
				parentCtl._nameslots[i] = nil;
			end
		end
	end
end