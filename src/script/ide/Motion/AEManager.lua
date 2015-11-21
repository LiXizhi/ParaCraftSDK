--[[
Title: AEManager
Author(s): Leio Zhang
Date: 2008/6/24
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/AEManager.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
local AEManager = {
	name = "AEManager.instance",
	childrenList = {},
	childrenNameMap = {},
	framerate = 1000,
}

commonlib.setfield("CommonCtrl.Motion.AEManager",AEManager);
CommonCtrl.Motion.AEManager.XamlResource = {};
function AEManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

-- get a animation's resource from a xaml file,the xaml file includes several AnimatorEngine(Storyboard as AnimatorEngine)
-- @return: a instance of AEManager
function AEManager.GetResourceFromXaml(path)
	local aeManager_instance = AEManager:new();
	local xamlNode = CommonCtrl.Motion.AEManager.XamlResource[path];
	if(not xamlNode)then
		local file = ParaIO.open(path, "r")
		if(file:IsValid()) then
			xamlNode = ParaXML.LuaXML_ParseString(file:GetText())
			file:close();	
			CommonCtrl.Motion.AEManager.XamlResource[path] = xamlNode;			
		end	
	end
	if(xamlNode) then
		AEManager.find(aeManager_instance,xamlNode);	
	end		
	return aeManager_instance;
end

function AEManager.find(aeManager_instance,xamlNode)
	if(type(xamlNode)=="table")then
		local k,v;
			for k,v in pairs(xamlNode) do
				if(type(v)=="table")then
					if(v.name=="Storyboard")then
						--commonlib.echo(v);
						AEManager.build_animatorEngine(aeManager_instance,v);
					else
						AEManager.find(aeManager_instance,v)
					end
				end
			end
	end
end
function AEManager.build_animatorEngine(parent,data)
	local aeManager_instance = parent;
	local name = data["attr"]["x:Name"];
	local engine = CommonCtrl.Motion.AnimatorEngine:new();
	engine.framerate = AEManager.framerate;
	if(name)then engine.name = name; end
	aeManager_instance:AddChild(engine);
	local animatorManager = CommonCtrl.Motion.AnimatorManager:new();
	local animator,layerManager;
	local k,v;
	for k,v in ipairs(data) do
		animator = CommonCtrl.Motion.Animator:new();
		
		local targetName,motion_str = AEManager.build_motionXML(v)
		if(motion_str)then
			--commonlib.echo(motion_str);
			animator:InitFromMotion(motion_str,targetName);
			AEManager.AllowUpdateWhichProperty(v,animator);
			layerManager = CommonCtrl.Motion.LayerManager:new();
			layerManager:AddChild(animator);
			animatorManager:AddChild(layerManager);
		end
	end
	engine:SetAnimatorManager(animatorManager);
end
function AEManager.AllowUpdateWhichProperty(data,animator)
	local displayObject = animator:GetTarget();
	local targetProperty = data["attr"]["Storyboard.TargetProperty"];
	local property = AEManager.get_propertyName(targetProperty);
	displayObject.updateAllProperty = false;
	if(property == "x")then
							displayObject.updateProperty.x =true;
	elseif(property == "y")then
							displayObject.updateProperty.y =true;
	elseif(property == "scaleX")then
							displayObject.updateProperty.scaleX =true;
	elseif(property == "scaleY")then
							displayObject.updateProperty.scaleY =true;
	elseif(property == "rotation")then
							displayObject.updateProperty.rotation =true;
	elseif(property == "color")then
							displayObject.updateProperty.color =true;
	elseif(property == "alpha")then
							displayObject.updateProperty.alpha =true;
	end
end
function AEManager.build_motionXML(data)
	local xml;
	local targetName = data["attr"]["Storyboard.TargetName"]
	local duration,keyframes = AEManager.build_AllkeyFrames(data);
	if(not keyframes or not duration)then 
		local targetName = data["attr"]["Storyboard.TargetName"]
		local targetProperty = data["attr"]["Storyboard.TargetProperty"];
			log(string.format("warning------:%s %s can't be parse in AEManager.build_motionXML \n",targetName,targetProperty));
		return 
	end;
	xml = string.format([[
			<Motion duration="%s" xmlns="fl.motion.*" xmlns:geom="flash.geom.*" xmlns:filters="flash.filters.*">
			<source>
				<Source frameRate="12" x="" y="" scaleX="" scaleY="" rotation="" elementType="" symbolName="">
				  <dimensions>
					<geom:Rectangle left="" top="" width="" height=""/>
				  </dimensions>
				  <transformationPoint>
					<geom:Point x="0.5" y="0.5"/>
				  </transformationPoint>
				</Source>
			</source>
			%s
			</Motion>
			]],duration,keyframes);
	
	return targetName,xml;
end

function AEManager.build_AllkeyFrames(data)
	local k,v;
	local targetName = data["attr"]["Storyboard.TargetName"]
	local targetProperty = data["attr"]["Storyboard.TargetProperty"];
	local property = AEManager.get_propertyName(targetProperty);
	if(not property)then return; end
	local temp = {};
	for k,v in ipairs(data) do				
			local index,keyframe = AEManager.build_keyFrame(property,v);
			local obj = {index=tonumber(index),keyframe=keyframe}	
			temp[index.."_"] = 	obj	
			--table.insert(temp,obj);		
	end
	temp = AEManager.CheckFirstFrame(temp)
	NPL.load("(gl)script/ide/TreeView.lua");
	local compareFunc = CommonCtrl.TreeNode.GenerateLessCFByField("index");
	-- quick sort
	table.sort(temp, compareFunc)
	local str = "";
	local maxFrame;
	for k,v in ipairs(temp) do		
		str = str..v["keyframe"];
		maxFrame = v["index"];
		
	end
	maxFrame = maxFrame + 1;
	return maxFrame,str;
end
function AEManager.CheckFirstFrame(framesTable)
	local hasFirst = false;
	local k,v;
	for k,v in pairs(framesTable) do				
			local index= v["index"];
			if(index ==0)then
				hasFirst = true;
				break;
			end
	end
	if(not hasFirst)then
		local firstFrame = [[<Keyframe index="0"><tweens><SimpleEase ease="1"/></tweens></Keyframe>]]
		local obj = {index=0,keyframe=firstFrame}	
			  framesTable["0_"] = obj	
	end
	
	local temp = {};
	for k,v in pairs(framesTable) do				
		table.insert(temp,v);
	end	
	return temp;
end
function AEManager.build_keyFrame(property,data)
	--local  attr={ KeySpline="0,0,0.008,0.847", KeyTime="00:00:00", Value="22" },
	--<Keyframe index="24" tweenSnap="true" tweenSync="true" y="267" scaleX="0.3" scaleY="0.3" rotation="-60">
		--<tweens>
		  --<SimpleEase ease="1"/>
		--</tweens>
	--</Keyframe>
	if(not property)then return end;
	local temp = data["attr"];
	local KeySpline = temp["KeySpline"];
	local KeyTime = temp["KeyTime"];
	local Value = temp["Value"];
	
	local indexValue,propertyName,propertyValue,colorValue,tweensValue = "","","","","";
	indexValue = AEManager.get_keyTime(KeyTime)
	propertyName = property;
	propertyValue = Value;

	colorValue = AEManager.get_color(propertyName,propertyValue);
	tweensValue = [[<tweens><SimpleEase ease="0"/></tweens>]]
	if(KeySpline)then
		tweensValue = AEManager.get_keySpline(propertyName,KeySpline)
		
		tweensValue = string.format([[<tweens>%s</tweens></Keyframe>]],tweensValue);
		
	end	
	local frame = string.format([[<Keyframe index = "%s" %s = "%s" > %s %s </Keyframe>]], indexValue,propertyName,propertyValue,colorValue,tweensValue); 
	return indexValue,frame;
end

function AEManager.get_color(propertyName,propertyValue)
	--<color>
			--<Color tintColor="0x935600" alphaMultiplier="0.53"/>
	--</color>
	local color,alphaMultiplier ="","","";
	if(propertyName =="alpha")then
		alphaMultiplier = string.format([[ alphaMultiplier = "%s" ]],propertyValue);
	elseif(propertyName =="color")then
		local __,__,tintMultiplier,tintColor = string.find(propertyValue,"#(%w%w)(%w%w%w%w%w%w)")
		--<Color tintColor="0xA033CC" tintMultiplier="0.63"/>		
		tintMultiplier = mathlib.bit.Hex2Dec(tintMultiplier)
		color = string.format([[ tintMultiplier = "%s" tintColor = "0x%s" ]],tintMultiplier,tintColor);
	end
	local str = [[<color><Color]]..alphaMultiplier..color..[[/></color>]];
	return str;
end
function AEManager.get_keyTime(KeyTime)
	local totalSeconds;
	if(not KeyTime) then totalSeconds = 0; end
	local framerate = AEManager.framerate;
	local __,__,hours,minutes,seconds = string.find(KeyTime,"(.+):(.+):(.+)");
	hours,minutes,seconds = tonumber(hours),tonumber(minutes),tonumber(seconds)
	totalSeconds = hours * 3600 + minutes*60 + seconds;
	local frame = totalSeconds *framerate/20;
	frame = math.floor(frame);
	return frame;
end

function AEManager.get_keySpline(property,KeySpline)
	--KeySpline="0,0,0.008,0.847"
	--<CustomEase target="position">
		--<geom:Point x="0.33333333333333326" y="0.33333333333333337"/>
		--<geom:Point x="0.6666666666666666" y="0.6666666666666666"/>
	--</CustomEase>
	local target;
	if(property =="x" or property =="y")then
		target = "position";
	elseif(property =="scaleX" or property =="scaleY" or property =="skewX" or property =="skewY")then
		target = "scale";
	elseif(property =="rotation")then
		target = "rotation";
	elseif(property =="color")then
		target = "color";
	end
	local value,geom;
	geom = "";
	for value in string.gfind(KeySpline, "([^%s,]+)") do
		geom = geom..string.format([[<geom:Point x="%s" y="%s"/>]],value,value);
	end
	local str = string.format([[<CustomEase target="%s"> %s </CustomEase>]],target,geom);
	return str;
end
function AEManager.get_propertyName(property)
	 --Storyboard.TargetProperty="(UIElement.Opacity)">
	 --Storyboard.TargetProperty="(Shape.Fill).(SolidColorBrush.Color)">
	 --["Storyboard.TargetProperty"]="(UIElement.RenderTransform).(TransformGroup.Children)[3].(TranslateTransform.Y)" 
	 --local __,__,__,__,__,value = string.find(property,"%((.+)%).%((.+)%)(.+)%.%((.+)%)");

	 local v,value;
	 for v  in string.gfind(property,"%((.-)%)") do
		value = v;
	 end
	 local __,__,__,value = string.find(value,"(.+)%.(.+)");
	 --local tweenableNames = {"x", "y", "scaleX", "scaleY", "rotation", "skewX", "skewY"};
	 local propertyName;
	 if(value =="X")then
					propertyName = "x";
	 elseif(value =="Y")then
					propertyName = "y";
	 elseif(value =="ScaleX")then
					propertyName = "scaleX";
	 elseif(value =="ScaleY")then
					propertyName = "scaleY";	 
	 elseif(value =="Angle")then
					propertyName = "rotation";	 
	 elseif(value =="AngleX")then
					propertyName = "skewX";
	 elseif(value =="AngleY")then
					propertyName = "skewY";
	 elseif(value =="Opacity")then
					propertyName = "alpha";
	 elseif(value =="Color")then
					propertyName = "color";
	 end
	 return propertyName;
	 
end
-- @return: a AnimatorEngine 
function AEManager:FindChildByName(name)
	return self.childrenNameMap[name];
end

function AEManager:AddChild(engine)
	if(not engine) then return end;
	self.childrenNameMap[engine.name] = engine
	table.insert(self.childrenList,engine);
end

function AEManager:RemoveChildAt(index)
	local engine = self.childrenList[index];
	if(engine)then
		local name = engine.name;
		self.childrenNameMap[name] = nil;
		table.remove(self.childrenList,index);
	end
end

function AEManager:RemoveChildByName(name)
	if(not name)then return end;
	local k , v ;
	for k , v in ipairs(self.childrenList) do
		local engine = v;
		local index = k;
		local _name = engine.name;
		if(_name == name)then
			self:RemoveChildAt(index);
			break;
		end
	end
end