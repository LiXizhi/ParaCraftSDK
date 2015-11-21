--[[
Title: Reverse
Author(s): Leio Zhang
Date: 2008/8/6
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Reverse.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
local Reverse = {

}
commonlib.setfield("CommonCtrl.Animation.Reverse",Reverse);
function Reverse.LrcToMcml(lrcStr,stringAnimationUsingKeyFrames)
	if(not lrcStr)then return end
	local list = {};
	local timeList,value;
	for line in string.gfind(lrcStr, "(%[(.-)%](.-))[\r\n]") do
	local __,__, timelist,value = string.find(line,"(%[.+%])(.+)")
		if(timelist)then
			for time in string.gfind(timelist,"%[(.-)%]") do
				local mill = CommonCtrl.Animation.TimeSpan.GetMilliseconds(time)				
				--value = ParaMisc.EncodingConvert("", "utf-8", value)				
				table.insert(list,{index = mill,value = value});
			end
		end
	end
	NPL.load("(gl)script/ide/TreeView.lua");
	local compareFunc = CommonCtrl.TreeNode.GenerateLessCFByField("index");
	-- quick sort
	table.sort(list, compareFunc)
	local k,v;
	local len = table.getn(list);

	if(len>0)then
		if(not stringAnimationUsingKeyFrames)then
		NPL.load("(gl)script/ide/Animation/StringAnimationUsingKeyFrames.lua");
		stringAnimationUsingKeyFrames = CommonCtrl.Animation.StringAnimationUsingKeyFrames:new{
			TargetName = "targetName",
			TargetProperty = "text",
			}
		end
	end
	for k,v in ipairs(list) do	
		local keyTime = CommonCtrl.Animation.TimeSpan.GetMillisecondsToTimeStr(v["index"])
		local value = v["value"];	
		
		local keyframe = CommonCtrl.Animation.DiscreteStringKeyFrame:new{
			KeyTime = keyTime,
			Value = value,
		}		
		stringAnimationUsingKeyFrames:addKeyframe(keyframe)
	end
	return stringAnimationUsingKeyFrames;
end
function Reverse.LrcToMcml_2(lrcStr,targetAnimationUsingKeyFrames)
	if(not lrcStr)then return end
	local list = {};
	local timeList,value;
	for line in string.gfind(lrcStr, "(%[(.-)%](.-))[\r\n]") do
	local __,__, timelist,value = string.find(line,"(%[.+%])(.+)")
		if(timelist)then
			for time in string.gfind(timelist,"%[(.-)%]") do
				local mill = CommonCtrl.Animation.TimeSpan.GetMilliseconds(time)				
				--value = ParaMisc.EncodingConvert("", "utf-8", value)				
				--table.insert(list,{index = mill,value = value});
				list[mill] = value
			end
		end
	end
	local temp = {};
	local f,v;
	for f,v in pairs(list) do
		table.insert(temp,{index = f,value = v});
	end
	list = temp;
	
	NPL.load("(gl)script/ide/TreeView.lua");
	local compareFunc = CommonCtrl.TreeNode.GenerateLessCFByField("index");
	-- quick sort
	table.sort(list, compareFunc)
	local k,v;
	local len = table.getn(list);

	if(len>0)then
		if(not targetAnimationUsingKeyFrames)then
		NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TargetAnimationUsingKeyFrames.lua");
		targetAnimationUsingKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{
			TargetName = "CaptionTarget",
			TargetProperty = "CaptionTarget",
			}
		end
	end
	for k,v in ipairs(list) do	
		local keyTime = CommonCtrl.Animation.TimeSpan.GetMillisecondsToTimeStr(v["index"])
		local value = v["value"];	
		local CaptionTarget = CommonCtrl.Animation.Motion.CaptionTarget:new{
			ID = ID,
			Text = value,
		}
		local keyframe = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{
			KeyTime = keyTime,
			Value = CaptionTarget,
		}		
		targetAnimationUsingKeyFrames:addKeyframe(keyframe)
	end
	return targetAnimationUsingKeyFrames;
end
function Reverse.SrtToMcml(srtStr,stringAnimationUsingKeyFrames)
	srtStr = Reverse.SrtToLrc(srtStr)
	Reverse.LrcToMcml(srtStr,stringAnimationUsingKeyFrames) 
end
function Reverse.SrtToLrc(srtStr)
	if(not srtStr)then return; end
	if(not srtStr)then return; end
	local start_str,start_str_m,end_str,end_str_m,txt;
	local s = "";
	for __,start_str,start_str_m,end_str,end_str_m,txt in string.gfind(srtStr, "((%d-:%d-:%d-),(%d-)%s%-%-%>%s(%d-:%d-:%d-),(%d-)[\r\n]+)(.-)[\r\n]+") do
		if(start_str  and end_str and txt)then
			start_str_m = start_str_m or 0;
			end_str_m = end_str_m or 0;
			start_str = string.format("[%s.%s]%s\r\n",start_str,start_str_m,txt);
			end_str = string.format("[%s.%s] \r\n",end_str,end_str_m);
			s = s..start_str
			s = s..end_str
		end
	end	
	return s;
end

function Reverse.McmlToLrc()
end