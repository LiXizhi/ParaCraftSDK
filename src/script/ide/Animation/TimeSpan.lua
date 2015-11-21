--[[
Title: TimeSpan
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/Animation/CurtainLib.lua");
local TimeSpan = {
	name = "TimeSpan_instance",
	framerate = 33,
}
commonlib.setfield("CommonCtrl.Animation.TimeSpan",TimeSpan);
function TimeSpan.GetMillisecondsToTimeStr(time)
	time = tonumber(time);
	if(not time)then return end
	local frame = time/TimeSpan.framerate;
	local s = TimeSpan.GetTime(frame);
	return s;
end
function TimeSpan.CheckTimeFormat(time_str)
	if(not time_str)then return end
	local t;
	local temp = {}
	for t in string.gfind(time_str, "([^%s:]+)") do
		t = tonumber(t);
		if(t)then
			table.insert(temp,t)
		end
	end
	local len = table.getn(temp);
	local k,v;
	local seconds = 0;
	for k,v in ipairs(temp) do
		local n = len - k;
		seconds = seconds + (60^n)*v
	end
	local millseconds = seconds * 1000;
	return TimeSpan.GetMillisecondsToTimeStr(millseconds);
end
function TimeSpan.GetMilliseconds(time_str)
	if(not time_str)then return end
	time_str = tostring(time_str);
	time_str = TimeSpan.CheckTimeFormat(time_str)
	local __,__,hours,minutes,seconds = string.find(time_str,"(.+):(.+):(.+)");
	hours,minutes,seconds = tonumber(hours),tonumber(minutes),tonumber(seconds)
	totalSeconds = hours * 3600 + minutes*60 + seconds;
	local totalMillseconds = totalSeconds * 1000;
	return totalMillseconds	
end
function TimeSpan.GetFrames(time_str)
	if(not time_str)then return end
	time_str = tostring(time_str);
	local totalMillseconds = TimeSpan.GetMilliseconds(time_str)
	if(not totalMillseconds)then 
		return 
	end
	local frame = totalMillseconds /TimeSpan.framerate;
	frame = math.floor(frame);
	return frame;
end

function TimeSpan.GetTime(frame)
	if(not frame or type(frame)~="number")then return end
	local totalMillseconds = frame * TimeSpan.framerate
	
	local hours,minutes,seconds ;
	local t = 3600*1000;
	hours = math.floor(totalMillseconds/t);
	totalMillseconds = totalMillseconds - hours*t;
	
	t = 60*1000;
	minutes = math.floor(totalMillseconds/t);
	totalMillseconds = totalMillseconds - minutes*t;
	
	t = 1000;
	seconds = totalMillseconds/t;
	
	return hours..":"..minutes..":"..seconds;
end
------------------------------------------------------------------
local Util = {

}
commonlib.setfield("CommonCtrl.Animation.Util",Util);
function Util.GetDisplayObjProperty(animationKeyFrames)
	local result = 0;
	if(not animationKeyFrames)then 
		return result ;
	end
	local TargetName = animationKeyFrames.TargetName;
	local TargetProperty = animationKeyFrames.TargetProperty;
	local keyframesType = animationKeyFrames.property;
	local display = Util.GetDisplayObj(TargetName)
	if(keyframesType =="DoubleAnimationUsingKeyFrames")then
		if(display)then
			if(TargetProperty =="x")then
				result = display.translationx;
			elseif(TargetProperty =="y")then
				result = display.translationy;
			elseif(TargetProperty =="scaleX")then
				result = display.scalingx ;
			elseif(TargetProperty =="scaleY")then
				result = display.scalingy;
			elseif(TargetProperty =="rotation")then
				result = display.rotation ;
				result = result / (math.pi/180)
			elseif(TargetProperty =="alpha")then
				local color = Util.GetColor(TargetName)
				local _,_,r,g,b,a =string.find(color,"%s-(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s-");
				r = Util.ChecColorkNum(r)
				g = Util.ChecColorkNum(g)
				b = Util.ChecColorkNum(b)
				a = Util.ChecColorkNum(a)	
				result = a / 255;			
			end
		end
	elseif(keyframesType =="StringAnimationUsingKeyFrames")then
		if(display)then
			if(TargetProperty =="text")then
				result = display.text;
			elseif(TargetProperty =="visible")then
				result = display.visible;
			end
		end
	elseif(keyframesType =="Point3DAnimationUsingKeyFrames")then
		local px,py,pz;
		if(TargetProperty =="RunTo" or TargetProperty =="SetProtagonistPosition")then
			local player = ParaScene.GetPlayer()
			
			if(player:IsValid() == true) then 	
				px,py,pz = player:GetPosition();	
			else
				px,py,pz = 255,0,255
			end
			result = {px,py,pz}	
		elseif(TargetProperty =="ParaCamera_SetLookAtPos")then
			local px,py,pz = ParaCamera.GetLookAtPos()
			result = {px,py,pz}		
		elseif(TargetProperty =="ParaCamera_SetEyePos")then
			local px,py,pz = ParaCamera.GetEyePos()
			result = {px,py,pz}	
		end
	end
	return result;
end
function Util.GetCameraObj(name)
	local player;
	local playerChar;
	local _name = name or "invisible camera"
	player = ParaScene.GetObject(_name);
	if(player:IsValid()) then
		return player;
	end
end
-- curKeyframe and frame: it will be available when keyframesType ="ObjectAnimationUsingKeyFrames" 
function Util.SetDisplayObjProperty(result,animationKeyFrames,curKeyframe,frame)
	if(not animationKeyFrames or not result)then return; end
	local TargetName = animationKeyFrames.TargetName;
	local TargetProperty = animationKeyFrames.TargetProperty;
	local keyframesType = animationKeyFrames.property;
	local display = Util.GetDisplayObj(TargetName) or ParaScene.GetCharacter(TargetName);
	
	
	if(keyframesType =="DoubleAnimationUsingKeyFrames")then
		if(not display)then return; end
		if(TargetProperty =="x")then
			display.translationx = tonumber(result);
		elseif(TargetProperty =="y")then
			display.translationy = tonumber(result);
		elseif(TargetProperty =="scaleX")then
			display.scalingx = tonumber(result);
		elseif(TargetProperty =="scaleY")then
			display.scalingy = tonumber(result);
		elseif(TargetProperty =="rotation")then
			display.rotation = tonumber(result) * (math.pi/180);
		elseif(TargetProperty =="alpha")then
			local color = Util.GetColor(TargetName)
			local _,_,r,g,b,a =string.find(color,"%s-(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s-");
			r = Util.ChecColorkNum(r)
			g = Util.ChecColorkNum(g)
			b = Util.ChecColorkNum(b)
			a = Util.ChecColorkNum(a)	
			local  new_a = tonumber(result);
			new_a = new_a * 255;
			new_a = math.floor(new_a);
			new_a = Util.ChecColorkNum(new_a);
			color = r.." "..g.." "..b.." "..new_a;
			Util.SetColor(TargetName,color)
		end
	elseif(keyframesType =="StringAnimationUsingKeyFrames")then
		if(animationKeyFrames.lastResult ~= result)then	
			animationKeyFrames.lastResult = result
			if(display)then
				if(TargetProperty =="text")then
					display.text = tostring(result);
				elseif(TargetProperty =="visible")then
					if(type(result) == "string")then
						if(result=="true")then
							display.visible = true;
						else
							display.visible = false;
						end
					elseif(type(result) == "boolean")then
						display.visible = result;
					end
				elseif(TargetProperty =="headon_speech")then
					local s = tostring(result);
					headon_speech.Speek(TargetName, s, 2);
				end
			end		
		
			if(TargetProperty =="curtain")then
				if(tonumber(result)>0)then 
					CommonCtrl.Animation.CurtainLib.doPlay();
				end
			elseif(TargetProperty =="movieCaption")then
				local s = tostring(result);
				if(s==nil)then s = "" end;
				CommonCtrl.Animation.MovieCaption.setText(s)			
			end
		end
	elseif(keyframesType =="Point3DAnimationUsingKeyFrames" or keyframesType =="Point3DAnimationUsingPath")then
		local px,py,pz = result[1], result[2], result[3];
		px = tonumber(px);
		py = tonumber(py);
		pz = tonumber(pz);
		if(not px or not py or not pz)then return; end
		if(TargetProperty =="RunTo")then
			local player = ParaScene.GetPlayer()
			if(player:IsValid() == true) then 	
				local s = player:ToCharacter():GetSeqController();	
				s:RunTo(px, py, pz);
			end
		elseif(TargetProperty =="SetProtagonistPosition")then
			local player = ParaScene.GetPlayer()
			local px,py,pz;
			if(player:IsValid() == true) then 		
				player:SetPosition(px, py, pz);
			end
		elseif(TargetProperty =="ParaCamera_SetLookAtPos")then
			ParaCamera.SetLookAtPos(px, py, pz); 
		elseif(TargetProperty =="ParaCamera_SetEyePos")then
			ParaCamera.SetEyePos(px, py, pz); 
		end
	elseif(keyframesType =="ObjectAnimationUsingKeyFrames")then
		if(animationKeyFrames.lastResult ~= result)then	
			animationKeyFrames.lastResult = result
			if(TargetProperty =="CreateMeshPhysicsObject")then
				Util.CreateMeshPhysicsObject(animationKeyFrames,result,curKeyframe,frame);
			elseif(TargetProperty == "DeleteMeshPhysicsObject")then
				Util.DeleteMeshPhysicsObject(animationKeyFrames,result,curKeyframe,frame);
			elseif(TargetProperty == "ModifyMeshPhysicsObject")then
				Util.ModifyMeshPhysicsObject(animationKeyFrames,result,curKeyframe,frame);
			elseif(TargetProperty == "Create2DContainer" or TargetProperty =="Create2DButton" or TargetProperty =="Create2DText")then
				Util.Create2DObject(animationKeyFrames,result,curKeyframe);
			end
		end
	end
end
-- DeleteMeshPhysicsObject
function Util.DeleteMeshPhysicsObject(animationKeyFrames,result,curKeyframe,frame)
	if(not animationKeyFrames or not result or not curKeyframe or not frame)then return; end
	local KeyFramesPool = CommonCtrl.Animation.KeyFramesPool;
		local TargetName = animationKeyFrames.TargetName;	
		local scene = ParaScene.GetMiniSceneGraph(TargetName);  -- "object_editor"
		local k,value;
		if(scene:IsValid())then
			for k,value in pairs(result) do	
				if(value)then
					local objectname = value.name;
					Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=value});	
				end
			end
		end
end
-- ModifyMeshPhysicsObject
function Util.ModifyMeshPhysicsObject(animationKeyFrames,result,curKeyframe,frame)
	if(not animationKeyFrames or not result or not curKeyframe or not frame)then return; end
	local KeyFramesPool = CommonCtrl.Animation.KeyFramesPool;
		local TargetName = animationKeyFrames.TargetName;	
		local scene = ParaScene.GetMiniSceneGraph(TargetName); -- "object_editor"
		local k,value;
		if(scene:IsValid())then
			for k,value in pairs(result) do	
				if(value)then
					local objectname = value.name;
					Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params=value});	
				end
			end
		end
end
-- CreateMeshPhysicsObject
function Util.CreateMeshPhysicsObject(animationKeyFrames,result,curKeyframe,frame)
	if(not animationKeyFrames or not result or not curKeyframe or not frame)then return; end
	local KeyFramesPool = CommonCtrl.Animation.KeyFramesPool;
		local TargetName = animationKeyFrames.TargetName;	
		local scene = ParaScene.GetMiniSceneGraph(TargetName); -- "object_editor"
		local k,value;
		if(scene:IsValid())then
			for k,value in pairs(result) do	
				if(value)then			
					--local object = ObjEditor.GetObjectByParams(value)	
					local object = ParaScene.GetCharacter(value.name);				
					KeyFramesPool.addObject(animationKeyFrames,curKeyframe,value);				
					if(not object or not object:IsValid())then					
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=value});						
					else
						object:SetVisible(true);
						object:SetScale(1)
					end
				end
			end
		end
end
-- Create2DObject
function Util.Create2DObject(animationKeyFrames,result,curKeyframe,frame)

end
function Util.GetDisplayObj(name)
	local display = ParaUI.GetUIObject(name);
	if(display:IsValid()==false)then
		--log("warning: animator binding control:"..self.name.." is not found\n");
		display = nil;
	end
	return display;
end
function Util.ChecColorkNum(n)
	if(not n ) then n = 255; end
	n = tonumber(n);
	if( n<0)then
		n = 0;
	 elseif( n>255)then
		n=255;
	end
	return n;
end
function Util.SetColor(name,color)
	local display = Util.GetDisplayObj(name);
	if(not display)then return ; end;
	local uiType = display.type;
	if(uiType == "text")then
		display:GetFont("text").color = color ;
	else
		display.color = color;
	end
end
function Util.GetColor(name)
	local display = Util.GetDisplayObj(name);
	if(not display)then return ; end;
	local color;
	local uiType = display.type;
	if(uiType == "text")then
		color = display:GetFont("text").color.." 255";		
	else
		color = display.color;
	end
	return color;
end
 -- get PolyBezierSegment value
function Util.getBezierSegmentValue( time, begin, change, duration ,pts)
	if (duration <=0 or not pts) then return nil ; end
	local percent = time / duration ;
	if(percent <=0) then return begin; end
	if(percent >=1) then return begin + change ; end
	
	local easedPercent = Util.getYForPercent_BezierSegment(percent,pts);
	local result = begin + easedPercent * change;
	return result;	
end

function Util.getYForPercent_BezierSegment(percent,pts)
	NPL.load("(gl)script/ide/Motion/BezierSegment.lua");
	local bez0 = CommonCtrl.Motion.BezierSegment:new{a = pts[1], b = pts[2], c = pts[3],d = pts[4]};
	local beziers  = {bez0};
	local i , len = 4 , table.getn(pts)-3 ;
	
	while(i<=len) do	
		table.insert(beziers , CommonCtrl.Motion.BezierSegment:new{a = pts[i],b = pts[i+1],c = pts[i+2],d = pts[i+3]})
		i = i + 3;
	end
	local theRightBez = bez0;
	--log("-----------\n");
	--log(table.getn(beziers).."\n");
	--log(commonlib.serialize(beziers).."\n");
	len = table.getn(pts);	
	if (len >=5) then
		for bi = 1,table.getn(beziers) do
			local bez = beziers[bi];
			if(bez.a and bez.d)then
				if (bez.a.x <=percent and percent <=bez.d.x) then
					theRightBez = bez;
					break
				end
			end
		end
	end
	local easedPercent = theRightBez:getYForX(percent);
	return  easedPercent;
end

------------------------------------------------------------
-- KeyFramesPool
------------------------------------------------------------
local KeyFramesPool = {};
commonlib.setfield("CommonCtrl.Animation.KeyFramesPool",KeyFramesPool);
function KeyFramesPool.addObject(keyframes,keyframe,obj_params)
	if(not keyframes or not keyframe or not obj_params)then return; end
	if(not KeyFramesPool[keyframes])then
		KeyFramesPool[keyframes] = {};
	end
	local pool =  KeyFramesPool[keyframes];
	pool[obj_params] = keyframe;
end
function KeyFramesPool.getObject(keyframes,keyframe,obj_params)
	if(not keyframes or not keyframe or not obj_params)then return; end
	if(not KeyFramesPool[keyframes])then
		return;
	end
	local pool =  KeyFramesPool[keyframes];
	if(not pool)then return; end
	local k,v;
	for k,v in pairs(pool) do
		if(k == obj_params)then
			return true;
		end
	end
end
function KeyFramesPool.removeObject(keyframes,keyframe,obj_params)
	--if(not keyframes or not keyframe or not obj_params)then return; end
	if(not KeyFramesPool[keyframes])then
		return;
	end
	local pool =  KeyFramesPool[keyframes];
	if(not pool)then return; end
	local k,v;
	for k,v in pairs(pool) do
		if(k == obj_params)then
			pool[k] = nil;
		end
	end
end
function KeyFramesPool.WhoIsShowed(keyframes,frame)	
	if(not keyframes or not frame)then return; end
	--local sceneName = self.TargetName;
			keyframes = KeyFramesPool[keyframes]
			if(not keyframes) then return; end
			local obj_params,vv;
			for obj_params,vv in pairs(keyframes) do
				local keyframe = vv;
				local property = keyframe.property;
				if(property == "DiscreteObjectKeyFrame")then
					local keytime = keyframe.KeyTime;
					if(keytime)then
						local k_frame = CommonCtrl.Animation.TimeSpan.GetFrames(keytime);
						local obj = ObjEditor.GetObjectByParams(obj_params);
						if(obj)then							
							if(frame<k_frame)then	
								-- visible is false
									obj:SetVisible(false);
									obj:SetScale(0)
									--commonlib.echo({frame,k_frame,obj:IsVisible()});
							else
								-- visible is true;
									obj:SetVisible(true);
									obj:SetScale(1)
									--commonlib.echo({frame,k_frame,obj:IsVisible()});
							end
						end
					end
				end
			end

end