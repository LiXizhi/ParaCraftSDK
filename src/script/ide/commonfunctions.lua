--[[
Title: Common functions collection
Author(s): Liuweili
Date: 2006/6/20
Desc: This file includes several common function to modify the character object
-------------------------------------------------------

-------------------------------------------------------
]]
function DummyNPCLineWalker_func(name, facing, radius, waitlength)
	if(name==nil or facing==nil or radius==nil or waitlength==nil)then
		log("Parameter nil in DummyNPCLineWalker_func\n");
		return;
	end
	local o=ParaScene.GetObject(name);
	local s = o:ToCharacter():GetSeqController();
	local destx,desty;
	destx=radius*math.cos(facing);
	desty=radius*math.sin(facing);
	-- delete alll previous keys
	s:DeleteKeysRange(0,-1);
	-- add keys
	s:BeginAddKeys();
	s:SetStartFacing(facing);
	s:Lable("start");
	s:WalkTo(destx,desty,0);
	s:Wait(0);
	s:Turn(facing-3.14);
	s:Wait(waitlength);
	s:WalkTo(-destx,-desty,0);
	s:Wait(0);
	s:Turn(facing);
	s:Wait(waitlength);
	s:Goto("start");
	s:EndAddKeys();
end

