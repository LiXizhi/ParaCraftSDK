
--[[
NPL.load("(gl)script/ide/Effect/frozenEffect.lua");
local FrozenEffect = commonlib.gettable("MyCompany.Aries.FrozenEffect");
--]]
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");


local FrozenEffect = commonlib.gettable("MyCompany.Aries.FrozenEffect");
local frozen_shader_file = "script/ide/Effect/Shaders/frozen.fxo";
local frozen_effect_handle = 1101;
local default_effect_handle = 12;

function FrozenEffect.CreateFrozenEffect()
	local effect = ParaAsset.GetEffectFile("frozen");
	if(effect:IsValid() == false)then
		LOG.std(nil, "debug", "FrozenEffect", "shader file %s is loaded", frozen_shader_file);
		effect = ParaAsset.LoadEffectFile("frozen",frozen_shader_file);
		effect = ParaAsset.GetEffectFile("frozen");
		effect:SetHandle(frozen_effect_handle);
		local params = effect:GetParamBlock();
		params:SetTexture(1,"Texture/Aries/ShaderResource/frozenNoise.dds");
	else
		local handle = effect:GetHandle();
		if(handle == -1)then
			effect:SetHandle(frozen_effect_handle);	
		end
	end
	return effect,frozen_effect_handle;
end
 
--@return effectHandle: remember the previous effect so you can set it back later
function FrozenEffect.ApplyFrozenEffect(character)
	if(character and character:IsValid())then
		local prevEffectHandle = character:GetField("render_tech",nil);

		local effect,effectHandle = FrozenEffect.CreateFrozenEffect();
		character:SetField("render_tech",effectHandle);
		character:SetField("RenderImportance", 3);	
		character:SetField("IsAnimPaused", true);

		return prevEffectHandle;
	end
end


function FrozenEffect.ResetEffect(character, effectHandle)
	effectHandle = effectHandle or default_effect_handle;
	if(character and character:IsValid())then
		FrozenEffect.prevEffectHandle = character:GetField("render_tech",nil);
		character:SetField("render_tech",effectHandle);
		character:SetField("RenderImportance", 0);	
		character:SetField("IsAnimPaused", false);
	end
end