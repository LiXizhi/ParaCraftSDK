--[[
Title: SoundTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/SoundTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local SoundTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "SoundTarget",
	ID = nil,
	Path = nil
});
commonlib.setfield("CommonCtrl.Animation.Motion.SoundTarget",SoundTarget);
function SoundTarget:GetDifference(curTarget,nextTarget)
	return nil;
end
function SoundTarget:GetDefaultProperty(path)
	self.Path = path or "";
end
function SoundTarget:Update(curKeyframe,lastFrame,frame)
	if(not self.Path)then return; end
	-- update special value
	if(not curKeyframe or not lastFrame or not frame)then return; end
	local isActivate = curKeyframe:GetActivate();	
	if(isActivate)then
		local file = ParaIO.GetCurDirectory(0)..self.Path;
		if(ParaIO.DoesFileExist(file, true))then
			ParaAudio.StopWaveFile(self.Path, true);
			ParaAudio.PlayWaveFile(self.Path, 0);
		end		
	end
end