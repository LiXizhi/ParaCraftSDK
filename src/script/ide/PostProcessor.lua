--[[
Title: Post Processing Effect Interface
Author: LiXizhi
Date : 2008.8.7
Desc: for developing post processing effect. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/PostProcessor.lua");
commonlib.ps.Test_LightScattering()
commonlib.ps.Test_MotionBlur()
commonlib.ps.Test_FilmScratch()
commonlib.ps.EnablePostProcessing(true, function(ps_scene)
	-- do the per frame scene rendering here. 
end)
-------------------------------------------------------
]]
local ps = {
	-- the function to be called every frame move after the main scene is rendered. 
	ProcessorFunc = nil,
};
commonlib.setfield("commonlib.ps", ps)

---------------------------------------------
-- ps class 
---------------------------------------------

-- enable or disable post processing for the current scene
-- @param bEnabled: true to enable
-- @param callbackFunc: a function(ps_scene) end, where ps_scene contains
function ps.EnablePostProcessing(bEnabled, callbackFunc)
	ps.ProcessorFunc = callbackFunc;
	
	ParaScene.EnablePostProcessing(bEnabled, "commonlib.ps.PS_Callback()");
end

-- private: function to be called per frame
function ps.PS_Callback()
	if(type(ps.ProcessorFunc) == "function") then
		-- ps_scene is a special mini-scene graph. 
		local ps_scene = ParaScene.GetPostProcessingScene();
		
		-- invoke the user callback
		ps.ProcessorFunc(ps_scene);
	end
end


---------------------------------------------
-- Test code : TODO: move this code to test folder
---------------------------------------------

-- this is an example of doing motion blur using the ps interface. 
function ps.Test_MotionBlur()
	NPL.load("(gl)script/ide/PostProcessor.lua");
	
	local _enableRadialBlur = true;
	
	commonlib.ps.EnablePostProcessing(true, function(ps_scene)
		-- local effect = ParaAsset.LoadEffectFile("motionBlur","script/shaders/MotionBlur.fx");
		local effect = ParaAsset.LoadEffectFile("motionBlur","script/ide/Effect/Shaders/motionBlur.fx");
		
		effect = ParaAsset.GetEffectFile("motionBlur");
		
		if(effect:Begin()) then
			-- 0 stands for S0_POS_TEX0,  all data in stream 0: position and tex0
			ParaEngine.SetVertexDeclaration(0); 
		
			-- save the current render target
			local old_rt = ParaEngine.GetRenderTarget();
			
			-- create/get a temp render target. 
			local _downSampleRT = ParaAsset.LoadTexture("_downSampleRT", "_downSampleRT", 0); 
			_downSampleRT:SetSize(512, 512);
			
			-- create/get a temp render target. 
			local _blurRT = ParaAsset.LoadTexture("_blurRT", "_blurRT", 0); 
			_blurRT:SetSize(512, 512);
			
			----------------------- down sample pass ----------------
			-- copy content from one surface to another
			ParaEngine.StretchRect(old_rt, _downSampleRT);
			
			----------------------- blur pass -----------------------
			-- set a new render target
			ParaEngine.SetRenderTarget(_blurRT);
			local params = effect:GetParamBlock();
			-- choose blur type
			if(_enableRadialBlur) then
				effect:BeginPass(0);
				params:SetBoolean("enableRadialBlur", true);
			else
				effect:BeginPass(1);
				params:SetBoolean("enableRadialBlur", false);
			end	
			params:SetTextureObj(0, _downSampleRT);
			--params:SetTexture(0, "model/map3D/texture/waterReflectMap.dds");
			--params:SetFloat("time", 0);
			--params:SetVector3("shallowWaterColor", 0.64,0.8,0.96);
			
			effect:CommitChanges();
			ParaEngine.DrawQuad();
				
			effect:EndPass();
			
			----------------------- compose final texture --------------
			-- restore old render target(usually it is the back buffer)
			ParaEngine.SetRenderTarget(old_rt);
			
			-- choose blur type
			effect:BeginPass(2);
			params:SetTextureObj(1, _blurRT);
			effect:CommitChanges();
			ParaEngine.DrawQuad();
				
			effect:EndPass();
			
			effect:End();
		end
	end)
end

-- this is an example of doing film scratch using the ps interface. 
function ps.Test_FilmScratch()
	NPL.load("(gl)script/ide/PostProcessor.lua");
	
	local _enableRadialBlur = true;
	
	local filmScratch = {};
	--render target size
	filmScratch.rtWidth = 1024;
	filmScratch.rtHeight = 768;

	filmScratch.verticalScanSpeed = 0.001;
	filmScratch.horizontalScanSpeed = 0.001;
	filmScratch.verticalOffset = 0;
	filmScratch.horizontalOffset = 0;
	filmScratch.noiseTextureName = "Texture/Effect/filmScratchNoise.dds";
	filmScratch.scratchAmount = 0.8;
	filmScratch.scratchPersistence = 15;
	filmScratch.sourceTexture = nil;

	filmScratch.timerID = 3000;
	filmScratch.updateFreq = 0.05;
	
	filmScratch.noiseTexture = ParaAsset.LoadTexture("fsNoiseTexture","Texture/Effect/filmScratchNoise.dds",1);
	
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

	--private: update scratch position
	function filmScratch.Update()
		filmScratch.verticalOffset = filmScratch.verticalOffset + filmScratch.verticalScanSpeed*filmScratch.updateFreq;
		filmScratch.horizontalOffset = filmScratch.horizontalOffset + filmScratch.horizontalOffset * filmScratch.updateFreq;
	end

	function filmScratch.CreateRenderTarget()
		filmScratch.sourceTexture = ParaAsset.LoadTexture("fsSourceTex","fsSourceTex",0);
		filmScratch.sourceTexture:SetSize(filmScratch.rtWidth,filmScratch.rtHeight);
	end

	filmScratch.timer = filmScratch.timer or commonlib.Timer:new({callbackFunc = function(timer)
		filmScratch.Update();
	end})
	
	filmScratch.timer:Change(50, 50);
	
	-- enable processor
	commonlib.ps.EnablePostProcessing(true, function(ps_scene)
		local effect = ParaAsset.LoadEffectFile("filmScratch","script/ide/Effect/Shaders/filmScratch.fx");
		effect = ParaAsset.GetEffectFile("filmScratch");
		
		
		if(filmScratch.sourceTexture == nil)then
			filmScratch.CreateRenderTarget();
		end
		
		--copy back buffer to texture;
		local sourceRT = ParaEngine.GetRenderTarget();
		ParaEngine.StretchRect(sourceRT,filmScratch.sourceTexture);

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
	end)
end

-- this is an example of doing light scattering using the ps interface. 
function ps.Test_LightScattering()
	NPL.load("(gl)script/ide/PostProcessor.lua");
	
	commonlib.ps.EnablePostProcessing(true, function(ps_scene)
		local effect = ParaAsset.LoadEffectFile("LightScattering","script/ide/Effect/Shaders/LightScattering.fx");
		effect = ParaAsset.GetEffectFile("LightScattering");
		
		if(effect:Begin()) then
			-- 0 stands for S0_POS_TEX0,  all data in stream 0: position and tex0
			ParaEngine.SetVertexDeclaration(0); 
		
			-- save the current render target
			local old_rt = ParaEngine.GetRenderTarget();
			
			-- create/get a temp render target. 
			local _downSampleRT = ParaAsset.LoadTexture("_downSampleRT", "_downSampleRT", 0); 
			_downSampleRT:SetSize(512, 512);
			
			-- create/get a temp render target. 
			local _lumRT = ParaAsset.LoadTexture("_lumRT", "_lumRT", 0); 
			_lumRT:SetSize(512, 512);
			
			----------------------- down sample pass ----------------
			-- copy content from one surface to another
			ParaEngine.StretchRect(old_rt, _downSampleRT);
			
			----------------------- create lum texture-----------------------
			-- set a new render target
			ParaEngine.SetRenderTarget(_lumRT);
			local params = effect:GetParamBlock();
			
			effect:BeginPass(0);
				params:SetTextureObj(0, _downSampleRT);
				effect:CommitChanges();
				ParaEngine.DrawQuad();
			effect:EndPass();
			
			-----------------------compose lum texture with original texture --------------
			ParaEngine.SetRenderTarget(old_rt);
			effect:BeginPass(1);
				params:SetTextureObj(1, _lumRT);
				effect:CommitChanges();
				ParaEngine.DrawQuad();
			effect:EndPass();
			
			effect:End();
		end
	end)
end

-- this is an example of doing light scattering using the ps interface. 
function ps.Test_ColorCorrection()
	NPL.load("(gl)script/ide/PostProcessor.lua");
	
	commonlib.ps.EnablePostProcessing(true, function(ps_scene)
		local effect = ParaAsset.LoadEffectFile("ColorCorrection","script/ide/Effect/Shaders/ColorCorrection.fx");
		effect = ParaAsset.GetEffectFile("ColorCorrection");
		
		if(effect:Begin()) then
			-- 0 stands for S0_POS_TEX0,  all data in stream 0: position and tex0
			ParaEngine.SetVertexDeclaration(0); 
		
			-- save the current render target
			local old_rt = ParaEngine.GetRenderTarget();
			
			-- create/get a temp render target. 
			local _downSampleRT = ParaAsset.LoadTexture("_downSampleRT", "_downSampleRT", 0); 
			_downSampleRT:SetSize(512, 512);
			
			----------------------- down sample pass ----------------
			-- copy content from one surface to another
			ParaEngine.StretchRect(old_rt, _downSampleRT);
			
			local params = effect:GetParamBlock();
			params:SetMatrix43("colorMatrix", "0.33,0.33,0.33,0.33,0.33,0.33,0.33,0.33,0.33,0,0,0");
			
			-----------------------compose lum texture with original texture --------------
			ParaEngine.SetRenderTarget(old_rt);
			effect:BeginPass(0);
				params:SetTextureObj(0, _downSampleRT);
				effect:CommitChanges();
				ParaEngine.DrawQuad();
			effect:EndPass();
			
			effect:End();
		end
	end)
end