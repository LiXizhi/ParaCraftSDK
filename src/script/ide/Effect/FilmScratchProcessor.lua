--[[
Title: Film Scratch Post processor effect. 
Author(s): refactored by LiXizhi from clayman's orginal implementation. 
Date: 2010/7/24
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/Effect/filmScratchProcessor.lua");
-- call this to start
commonlib.ps.filmScratch.Initialize();
commonlib.ps.filmScratch.StartEffect();

-- call this to stop
commonlib.ps.filmScratch.EndEffect();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/PostProcessor.lua");
NPL.load("(gl)script/ide/timer.lua");

local filmScratch = commonlib.gettable("commonlib.ps.filmScratch");

--render target size
filmScratch.rtWidth = 512;
filmScratch.rtHeight = 512;

filmScratch.verticalScanSpeed = 0.005; -- [0.001,0.1] works fine
filmScratch.horizontalScanSpeed = 0.005; -- [0.001,0.1] works fine
filmScratch.verticalOffset = 0;
filmScratch.horizontalOffset = 0;
filmScratch.noiseTextureName = "Texture/Effect/filmScratchNoise.dds";
filmScratch.scratchAmount = 0.8;
filmScratch.scratchPersistence = 15;
filmScratch.sourceTexture = nil;

filmScratch.updateFreq = 0.05;

--public function: call this once to initialize
function filmScratch.Initialize()
	--load effect and texture
	filmScratch.effect = ParaAsset.LoadEffectFile("filmScratch","script/ide/Effect/Shaders/filmScratch.fx");
	filmScratch.noiseTexture = ParaAsset.LoadTexture("fsNoiseTexture",filmScratch.noiseTextureName,1);
end

-- start applying the effect
-- @param bAnimate: true to animate
function filmScratch.StartEffect(bAnimate)
	if(bAnimate == nil) then
		bAnimate = true;
	end
	commonlib.ps.filmScratch.Animate(bAnimate);
	commonlib.ps.EnablePostProcessing(true,commonlib.ps.filmScratch.Process);
end

-- end effect. 
function filmScratch.EndEffect()
	commonlib.ps.filmScratch.Animate(false);
	commonlib.ps.EnablePostProcessing(false);
end

function filmScratch.Process()
	if(filmScratch.sourceTexture == nil)then
		filmScratch.CreateRenderTarget();
	end
	
	--copy back buffer to texture;
	local sourceRT = ParaEngine.GetRenderTarget();
	ParaEngine.StretchRect(sourceRT,filmScratch.sourceTexture);

	local effect = filmScratch.effect;

	ParaEngine.SetRenderTarget(sourceRT);
	ParaEngine.SetVertexDeclaration(0);
	
	if(effect:Begin())then
		local effectParams = effect:GetParamBlock();
		effectParams:SetTextureObj(0,filmScratch.sourceTexture);
		effectParams:SetTextureObj(1,filmScratch.noiseTexture);
		effectParams:SetFloat("side",filmScratch.horizontalOffset);
		effectParams:SetFloat("scanLine",filmScratch.verticalOffset);
		effect:CommitChanges();
		effect:BeginPass(0);
		ParaEngine.DrawQuad();
		effect:EndPass();
		
		effect:End();
	end	
end

-- start/stop animating shader parameters. 
function filmScratch.Animate(isActive)
	filmScratch.timer = filmScratch.timer or commonlib.Timer:new({callbackFunc = filmScratch.Update})
	if(isActive)then
		filmScratch.timer:Change(10, filmScratch.updateFreq*1000);
	else
		filmScratch.timer:Change();
	end	
end

function filmScratch.SetScratchAmount(scratchAmount)
	filmScratch.scratchAmount = scratchAmount;
	if(filmScratch.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:SetFloat("scratchAmount",scratchAmount);
	end
end

function filmScratch.SetScratchPersistence(persistence)
	filmScratch.scratchPersistence = persistence;
	if(filmScratch.effect ~= nil)then
		local params = motionBlur.effect:GetParamBlock();
		params:SetFloat("ScratchPersistence",persistence);
	end
end

--private function: update scratch position during a timer
function filmScratch.Update()
	filmScratch.verticalOffset = filmScratch.verticalOffset + filmScratch.verticalScanSpeed*filmScratch.updateFreq;
	if(filmScratch.verticalOffset > 2) then
		filmScratch.verticalOffset = filmScratch.verticalOffset -1;
	end
	filmScratch.horizontalOffset = filmScratch.horizontalOffset + filmScratch.horizontalScanSpeed*filmScratch.updateFreq;
	if(filmScratch.horizontalOffset > 2) then
		filmScratch.horizontalOffset = filmScratch.horizontalOffset -1;
	end
end

function filmScratch.CreateRenderTarget()
	filmScratch.sourceTexture = ParaAsset.LoadTexture("fsSourceTex","fsSourceTex",0);
	filmScratch.sourceTexture:SetSize(filmScratch.rtWidth,filmScratch.rtHeight);
end

