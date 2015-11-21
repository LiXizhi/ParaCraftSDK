--[[
Title: LandTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/LandTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local LandTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "LandTarget",
	ID = nil,
	TerrainBrushSize = nil,
	TerrainType = "",
	X = nil,
	Y = nil,
	Z = nil,
	HeightScale = nil,
	bRoughen = nil,
	
	TextureBrushSize = nil,
	BrushIndex = nil,
});
commonlib.setfield("CommonCtrl.Animation.Motion.LandTarget",LandTarget);
function LandTarget:GetDifference(curTarget,nextTarget)
	return nil;
end
function LandTarget:GetDefaultProperty()
	local x,y,z;
	local player = ParaScene.GetPlayer();
	self.TerrainType = "GaussianHill";
	self.TerrainBrushSize = 10;
	self.HeightScale = 1;
	self.TextureBrushSize = 1;
	self.BrushIndex = 1;
	if(player:IsValid() == true) then		
		x,y,z = player:GetPosition();
		x = x or 255;
		y = y or 0;
		z = z or 255;
	else
		x,y,z = 255,0,255	
	end	
	self.X = self:FormatNumberValue(x);
	self.Y = self:FormatNumberValue(y);
	self.Z = self:FormatNumberValue(z);
end
function LandTarget:Update(curKeyframe,lastFrame,frame)
	-- update special value
	if(not curKeyframe or not lastFrame or not frame)then return; end
	local isActivate = curKeyframe:GetActivate();	
	if(isActivate)then
		-- Terrain
		local height = self.HeightScale;
		local bRoughen = self.bRoughen;
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
				type = self.TerrainType,
				radius = self.TerrainBrushSize,
				x = self.X,
				y = self.Y,
				z = self.Z,
				heightScale = height,
				bRoughen = bRoughen,
			},})		
		if(self.TerrainType =="GaussianHill")then
			-- play animation according to terrain height operation
			if(height > 0) then
				Map3DSystem.Animation.SendMeMessage({
						type = Map3DSystem.msg.ANIMATION_Character,
						obj_params = nil, --  <player>
						animationName = "RaiseTerrain",
						});
			elseif(height < 0) then
				Map3DSystem.Animation.SendMeMessage({
						type = Map3DSystem.msg.ANIMATION_Character,
						obj_params = nil, --  <player>
						animationName = "LowerTerrain",
						});
			end
		end
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
		-- Texture
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_PaintBrush, brush = {
					filename = self.BrushIndex or "",
					radius = self.TextureBrushSize,
					x = self.X,
					y = self.Y,
					z = self.Z,
				},})
				
				
			Map3DSystem.Animation.SendMeMessage({
						type = Map3DSystem.msg.ANIMATION_Character,
						obj_params = nil, --  <player>
						animationName = "ModifyTerrainTexture",
						});
				
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_Paint,})
	end
end