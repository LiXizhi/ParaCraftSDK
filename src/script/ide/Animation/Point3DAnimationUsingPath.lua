--[[
Title: Point3DAnimationUsingPath
Author(s): Leio Zhang
Date: 2008/9/5
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Point3DAnimationUsingPath.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");

local Point3DAnimationUsingPath = commonlib.inherit(CommonCtrl.Animation.AnimationUsingKeyFrames, {
	property = "Point3DAnimationUsingPath",
	name = "Point3DAnimationUsingPath_instance",
	mcmlTitle = "pe:point3DAnimationUsingPath",
	SurpportProperty = {"SetPosition","ParaCamera_SetLookAtPos","ParaCamera_SetEyePos","SetProtagonistPosition","RunTo"},
});
commonlib.setfield("CommonCtrl.Animation.Point3DAnimationUsingPath",Point3DAnimationUsingPath);
-- override parent InsertFirstKeyFrame
function Point3DAnimationUsingPath:InsertFirstKeyFrame()
	local keyframe = CommonCtrl.Animation.DiscretePoint3DUsingPath:new{
		KeyTime = "00:00:00",
		Value = nil,
	}
	commonlib.insertArrayItem(self.keyframes, 1, keyframe);
end
function Point3DAnimationUsingPath:getValue(time)
	local result = nil;
	local curKeyframe = self:getCurrentKeyframe(time);
	if(not curKeyframe)then return; end
	local begin = curKeyframe:GetValue();
	--local begin = curKeyframe.Value_2;
	if(not begin)then return; end
	local timeFromKeyframe = time - curKeyframe:GetFrames()-1;
	
	local nextKeyframe = self:getNextKeyframe(time);
	
	if (not nextKeyframe) then			
		return;
	end
	local keyframeDuration = nextKeyframe:GetFrames() - curKeyframe:GetFrames();
	
	local pts_x = begin[1];
	local pts_y = begin[2];
	local pts_z = begin[3];
	if(not pts_x)then return; end
	--local x = CommonCtrl.Animation.Util.getBezierSegmentValue( timeFromKeyframe, 0, 1, keyframeDuration ,pts_x)
	--local y = CommonCtrl.Animation.Util.getBezierSegmentValue( timeFromKeyframe, 0, 1, keyframeDuration ,pts_y)
	--local z = CommonCtrl.Animation.Util.getBezierSegmentValue( timeFromKeyframe, 0, 1, keyframeDuration ,pts_z)	
	local len = table.getn(pts_x);
	local index = len * (timeFromKeyframe/keyframeDuration)+1;	
	index = math.floor(index);
	if(index>len)then index = len; end
	--commonlib.echo({index,len});
	local x = pts_x[index];
	local y = pts_y[index];
	local z = pts_z[index];
	result = {x,y,z}
	--commonlib.echo(pts_x);
	--commonlib.echo(result);
	return result,curKeyframe,time;
end

---------------------------------------------------------------------------
-- DiscretePoint3DUsingPath
local DiscretePoint3DUsingPath  = commonlib.inherit(CommonCtrl.Animation.KeyFrame, {
	parentProperty = "DiscreteUsingPath",
	property = "DiscretePoint3DUsingPath",
	name = "DiscretePoint3DUsingPath_instance",
	mcmlTitle = "pe:discretePoint3DUsingPath",
});
commonlib.setfield("CommonCtrl.Animation.DiscretePoint3DUsingPath",DiscretePoint3DUsingPath );
function DiscretePoint3DUsingPath:SetValue(v)
	if(not v)then return; end
	-- v = "1 1 1,10 13 17"
	local point3D;
	local bool = false;
	for point3D in string.gfind(v,"[^,]+")do
		if(point3D)then
			bool = true;
			break;
		end
	end
	if(not bool)then return; end	
	local x_arr = {}
	local y_arr = {}
	local z_arr = {}
	for point3D in string.gfind(v,"[^,]+")do		
		if(point3D)then		
			local __,__,x,y,z = string.find(point3D,"(.+)%s+(.+)%s+(.+)");
			x = tonumber(x) or 0;
			y = tonumber(y) or 0;
			z = tonumber(z) or 0;
			table.insert(x_arr,x);
			table.insert(y_arr,y);
			table.insert(z_arr,z);
		end
	end
	self.Value = {[1] = x_arr,[2] = y_arr,[3] = z_arr};
	
end
function DiscretePoint3DUsingPath:ReverseToMcml()
	if(not self.KeyTime)then return "" end		
	local p_node = "";
	local p_n = "\r\n";
	if(self.Value)then
		local x_arr = self.Value[1];
		local y_arr = self.Value[2];
		local z_arr = self.Value[3];
		if(x_arr)then
			local k,len = 1,table.getn(x_arr);
			local x,y,z;	
			for k =1,len do
				x = x_arr[k];
				y = y_arr[k];
				z = z_arr[k];
				
				x = x  or 0;
				y = y  or 0;
				z = z  or 0;
				local str = string.format("%s %s %s,",x,y,z);
				p_node = p_node .. str;
			end
		end
	end
	local node = string.format([[<%s KeyTime="%s" Value="%s" />%s]],self.mcmlTitle,self.KeyTime,p_node,p_n);
	return node;
end
function DiscretePoint3DUsingPath:GetMaxVaule(result)
	if(not result)then return; end
	local k,v;
	local data = {}
	local max = 1;
	for k,v in ipairs(result) do
		if(v.x > max)then
			max = v.x;
		end
	end
	for k,v in ipairs(result) do
		local x = v.x/max;
		local y = v.y/max;
		table.insert(data,{x = x,y = y});
	end
	return max,data;
end