
--[[
NPL.load("(gl)script/ide/Effect/stoneEffect.lua");
local StoneEffect = commonlib.gettable("MyCompany.Aries.StoneEffect");
--]]

NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");


local StoneEffect = commonlib.gettable("MyCompany.Aries.StoneEffect");
local stone_shader_file = "script/ide/Effect/Shaders/stoneEffect.fxo";
local stone_effect_handle = 1103;
local default_effect_handle = 12;

function StoneEffect.CreateEffect()
	local effect = ParaAsset.GetEffectFile("stone");
	if(effect:IsValid() == false)then
		LOG.std(nil,"debug","StoneEffect","shader file %s is loaded",stone_shader_file);
		effect = ParaAsset.LoadEffectFile("stone",stone_shader_file);
		effect = ParaAsset.GetEffectFile("stone");
		effect:SetHandle(stone_effect_handle);
		local params = effect:GetParamBlock();
		params:SetTexture(1,"Texture/Aries/ShaderResource/stoneNoise.dds");
	else
		local handle = effect:GetHandle();
		if(handle == -1)then
			effect:SetHandle(stone_effect_handle);
		end
	end
	return effect,stone_effect_handle;
end

function StoneEffect.ApplyEffect(character)
	if(character and character:IsValid())then
		local prevEffectHandle = character:GetField("render_tech",nil);
		local effect,effectHandle = StoneEffect.CreateEffect();
		character:SetField("render_tech",effectHandle);
		character:SetField("IsAnimPaused",true);
		return prevEffectHandle;
	end
end

function StoneEffect.ResetEffect(character,effectHandle)
	local prevEffect = effectHandle or default_effect_handle;
	if(character and character:IsValid())then
		character:SetField("render_tech",prevEffect);
		character:SetField("IsAnimPaused",false);
	end
end


function StoneEffect.Update()
	local effect = ParaAsset.GetEffectFile("stone");
	if(effect and effect:IsValid())then
		local params = effect:GetParamBlock();
		params:SetVector3("blendFactor",0.9,0,0);
	end
end
