--[[
Title: ParaEngine settings functions and UI handlers
Author(s): LiXizhi
Date: 2006/5/29
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/ParaEngineSettings.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/network/ClientServerIncludes.lua");

if(not ParaSettingsUI) then ParaSettingsUI={}; end

function ParaSettingsUI.ShowCurrentTerrainProperty()
	local obj = ParaScene.GetPlayer();
	if(obj:IsValid() == true) then 
		local x,y,z = obj:GetPosition();
		CommonCtrl.ShowObjProperty("setting", ParaTerrain.GetAttributeObjectAt(x,z), true);		
	end
end

function ParaSettingsUI.ToggleShadow()
	local nShadowMethod;
	if(ParaScene.GetShadowMethod() > 0) then 
		nShadowMethod = 0;
	else
		nShadowMethod = 1;
	end
	ParaScene.SetShadowMethod(nShadowMethod);
end

function ParaSettingsUI.ToggleLighting()
	local nMethod;
	if(ParaScene.IsLightingEnabled() == true) then 
		nMethod = false;
	else
		nMethod = true;
	end
	ParaScene.EnableLighting(nMethod);
end

-- UI handler 
--@param sSliderControlName: name of the slider control. If nil, it defaults to "fogrange_slider"
function ParaSettingsUI.OnFogRangeSliderChanged(sSliderControlName)
	if(not sSliderControlName) then
		sSliderControlName = "fogrange_slider";
	end
	local temp = ParaUI.GetUIObject(sSliderControlName);
	if (temp:IsValid() == true) then
		local att =	ParaScene.GetAttributeObject();
		local fogend = att:GetField("FogEnd", 120);
		local fogmin = 0;
		if(fogend > fogmin) then
			local fFogStart=(temp.value/100*(fogend-fogmin))+fogmin;
			log(fogend..fFogStart.." on changed\r\n");
			att:SetField("FogStart", fFogStart);
		end
	end
end

-- UI handler 
--@param sSliderControlName: name of the slider control.If nil, it defaults to "slider_time"
function ParaSettingsUI.OnTimeSliderChanged
(sSliderControlName)
	if(not sSliderControlName) then
		sSliderControlName = "slider_time";
	end
	local temp = ParaUI.GetUIObject(sSliderControlName);
	if (temp:IsValid() == true) then
		local fTime=(temp.value/100-0.5)*2;
		
		local nServerState = ParaWorld.GetServerState();
		if(nServerState == 0) then
			-- this is a standalone computer
			ParaScene.SetTimeOfDaySTD(fTime);
		elseif(nServerState == 1) then
			-- this is a server. 
			server.BroadcastTimeModify(fTime);
		elseif(nServerState == 2) then
			-- this is a client. 
			client.RequestTimeModify(fTime);
		end
	end	
end

-- UI handler 
--@param sSliderControlName: name of the slider control.If nil, it defaults to "slider_perf"
function ParaSettingsUI.OnPerfSliderChanged(sSliderControlName)
	if(not sSliderControlName) then
		sSliderControlName = "slider_perf";
	end
	local temp = ParaUI.GetUIObject(sSliderControlName);
	if (temp:IsValid() == true) then
		local nLevel=temp.value;
		if(nLevel==0) then
			ParaEngine.LoadGameEffectSet(1024);
		elseif(nLevel<33) then
			ParaEngine.LoadGameEffectSet(-1);
		elseif(nLevel<66) then
			ParaEngine.LoadGameEffectSet(0);
		elseif(nLevel<=95) then
			ParaEngine.LoadGameEffectSet(1);
		elseif(nLevel<=100) then
			ParaEngine.LoadGameEffectSet(2);
		end
	end
end

-- @param: 0 means medium, 1 means high, 2 means ultra high, -1 means low. 1024 is poor using fixed function.
function ParaSettingsUI.SetGraphicsLevel(nLevel)
	if(nLevel == 0) then
		ParaEngine.LoadGameEffectSet(0);
	elseif(nLevel == 1) then
		ParaEngine.LoadGameEffectSet(1);
	elseif(nLevel == 2) then
		ParaEngine.LoadGameEffectSet(2);
	elseif(nLevel == -1) then
		ParaEngine.LoadGameEffectSet(-1);
	elseif(nLevel == 1024) then
		ParaEngine.LoadGameEffectSet(1024);
	end
end

-- bInverse: if nil, it is a toggle operation
function ParaSettingsUI.InverseMouse(bInverse)
	if(bInverse == nil) then
		if(ParaEngine.GetMouseInverse() == true ) then
			bInverse = false
		else
			bInverse = true
		end
	end	
	ParaEngine.SetMouseInverse(bInverse);
end

function ParaSettingsUI.IsInverseMouse()
	return ParaEngine.GetMouseInverse();
end

-- set all volumes
function ParaSettingsUI.SetMusicVolume(value)
	ParaAudio.SetBGMusicVolume(value);
	ParaAudio.SetDialogVolume(value);
	ParaAudio.SetAmbientSoundVolume(value);
	ParaAudio.SetUISoundVolume(value);
	ParaAudio.Set3DSoundVolume(value);
	ParaAudio.SetInteractiveSoundVolume(value);
end

--[[
ParaSettingsUI.StopCategories("3DSound", "Ambient", "Background", "Default", "Dialog", "Interactive", "Music", "UI");
]]
function ParaSettingsUI.StopCategories(a1,a2,a3,a4,a5,a6,a7,a8)
	if(a1~=nil) then
		ParaAudio.StopCategory(a1);
	end	
	if(a2~=nil) then
		ParaAudio.StopCategory(a2);
	end	
	if(a3~=nil) then
		ParaAudio.StopCategory(a3);
	end	
	if(a4~=nil) then
		ParaAudio.StopCategory(a4);
	end	
	if(a5~=nil) then
		ParaAudio.StopCategory(a5);
	end	
	if(a6~=nil) then
		ParaAudio.StopCategory(a6);
	end	
	if(a7~=nil) then
		ParaAudio.StopCategory(a7);
	end	
	if(a8~=nil) then
		ParaAudio.StopCategory(a8);
	end	
end