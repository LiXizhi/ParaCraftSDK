
--[[
NPL.load("(gl)script/ide/Effect/transparentEffect.lua");
TransparentEffect = commonlib.gettable("MyCompany.Aries.TransparentEffect");
TransparentEffect.Apply();
--]]

local TransparentEffect = commonlib.gettable("MyCompany.Aries.TransparentEffect");
local shaderFile = "script/ide/Effect/Shaders/transparent.fxo";
local effectHandleId = 1102;
local defaultEffectHandle = 12;

--@return effectHandle: remember the previous effect so we can set it back later
function TransparentEffect.Apply(character)
	if(character and character:IsValid())then
		local prevEffectHandle = character:GetField("render_tech",nil);
		TransparentEffect.CreateEffect();
		character:SetField("render_tech",effectHandleId);
		character:SetField("RenderImportance",3);
		return prevEffectHandle;
	end
end

--r,g,b values range in [0,1]
function TransparentEffect.SetDiffuseColor(r,g,b)
	local effect = ParaAsset.GetEffectFile("transparent");
	if(effect and effect:IsValid())then
		local params = effect:GetParamBlock();
		params:SetVector3("diffuseColor",r,g,b);
	end
end

function TransparentEffect.ResetEffect(character,effectHandle)
	effectHandle = effectHandle or defaultEffectHandle;
	if(character and character:IsValid())then
		character:SetField("render_tech",effectHandle);
	end
end

function TransparentEffect.CreateEffect()
	local effect = ParaAsset.GetEffectFile("transparent");
	if(effect:IsValid() == false)then
		LOG.std(nil, "debug", "transparent", "shader file %s is loaded", shaderFile);
		effect = ParaAsset.LoadEffectFile("transparent",shaderFile);
		effect = ParaAsset.GetEffectFile("transparent");
		effect:SetHandle(effectHandleId);
	else
		local handle = effect:GetHandle();
		if(handle == -1)then
			effect:SetHandle(effectHandleId);	
		end
	end
end