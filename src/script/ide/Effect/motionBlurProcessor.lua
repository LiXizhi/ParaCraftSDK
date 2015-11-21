
NPL.load("(gl)script/ide/PostProcessor.lua");

local motionBlur = {};
commonlib.setfield("commonlib.ps.motionBlur", motionBlur);

--private members
motionBlur.enableRadialBlur = false;
--render target size;
motionBlur.rtWidth = 1024;
motionBlur.rtHeight = 768;
--the vector of fix direction blur
motionBlur.blurDirectionX = 0;
motionBlur.blurDirectionY = 1;
--control how much blur you want
motionBlur.blurWeight = 0.8;
--blur offset for fix direction blur
motionBlur.dirctionBlurStep = 0.005;
--blur offfset for radial blur
motionBlur.radialBlurStep = 0.025;

motionBlur.downSampleRT = nil;
motionBlur.blurRT = nil;

motionBlur.effect = nil;


--public function
function motionBlur.Initialize()
	motionBlur.effect = ParaAsset.LoadEffectFile("motionBlur","script/ide/Effect/Shaders/MotionBlur.fx");
	motionBlur.effect = ParaAsset.GetEffectFile("motionBlur");
		
	local params = motionBlur.effect:GetParamBlock();
	params:SetVector2("screenParam",motionBlur.rtWidth,motionBlur.rtHeight);
	params:SetVector2("blurDirection",motionBlur.blurDirectionX,motionBlur.blurDirectionY);
	params:SetVector2("blurStep",motionBlur.radialBlurStep,motionBlur.dirctionBlurStep);
	params:SetFloat("blendWeight",motionBlur.blurWeight);
end

function motionBlur.Process()
	if(motionBlur.downSampleRT == nil or motionBlur.blurRT == nil)then
		motionBlur.CreateRenderTarget();
	end
	
	local effect = motionBlur.effect;
	if(effect:Begin())then
		ParaEngine.SetVertexDeclaration(0);
		local params = effect:GetParamBlock();
		
		local sourceRT = ParaEngine.GetRenderTarget();
		
		ParaEngine.StretchRect(sourceRT,motionBlur.downSampleRT);

		--blur pass
		params:SetTextureObj(0,motionBlur.downSampleRT);
		ParaEngine.SetRenderTarget(motionBlur.blurRT);		
		if(motionBlur.enableRadialBlur)then
			effect:BeginPass(0);
		else
			effect:BeginPass(1);
		end
		effect:CommitChanges();
		
		ParaEngine.DrawQuad();
		effect:EndPass();

		--compose pass
		ParaEngine.SetRenderTarget(sourceRT);
		effect:BeginPass(2);
		params:SetTextureObj(1,motionBlur.blurRT);
		effect:CommitChanges();
		ParaEngine.DrawQuad();
		effect:EndPass();
		
		effect:End();
	end
end

function motionBlur.EnableRadialBlur(isEnable)
	motionBlur.enableRadialBlur = isEnable;
	
	if(motionBlur.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:SetBoolean("enableRadialBlur",isEnable);
	end	
end

function motionBlur.SetRenderTargetSize(width,height)
	motionBlur.rtWidth = width;
	motionBlur.rtHeight = height;
	
	if(motionBlur.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:SetVector2("screenParam",width,height);
	end	
end

--nomalized vector (x,y)
function motionBlur.SetBlurDirection(x,y)
	motionBlur.blurDirectionX = x;
	motionBlur.blurDirectionY = y;
	
	if(motionBlur.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:SetVector2("blurDirection",x,y);
	end	
end

function motionBlur.SetBlurStep(radiusBlurStep,fixedBlurStep)
	motionBlur.dirctionBlurStep = fixedBlurStep;
	motionBlur.radialBlurStep = radiusBlurStep;
	
	if(motionBlur.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:SetVector2("blurStep",radiusBlurStep,fixedBlurStep);
	end
end

function motionBlur.SetBlurWeight(weight)
	motionBlur.blurWeight = weight;
	
	if(motionBlur.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:float("blendWeight",weight);
	end
end

--private 
function motionBlur.CreateRenderTarget()
	motionBlur.downSampleRT = ParaAsset.LoadTexture("downSampleRT", "downSampleRT", 0);
	motionBlur.downSampleRT:SetSize(motionBlur.rtWidth/4,motionBlur.rtHeight/4);
	
	motionBlur.blurRT = ParaAsset.LoadTexture("blurRT", "blurRT", 0); 
	motionBlur.blurRT:SetSize(motionBlur.rtWidth/4,motionBlur.rtHeight/4);
end

