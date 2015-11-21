--[[
Title: CurtainLib
Author(s): Leio Zhang
Date: 2008/8/15
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/CurtainLib.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Storyboard.lua");
local CurtainLib = {
	name = "CurtainLib_instance",
	Storyboard = nil,
}
commonlib.setfield("CommonCtrl.Animation.CurtainLib",CurtainLib);
function CurtainLib.createTopContainer()
	local _this=ParaUI.GetUIObject(CurtainLib.name);
	if(_this:IsValid() == true)then
		ParaUI.Destroy(CurtainLib.name);
	end
	local left, top, width, height = 0,0,0,0
	_this = ParaUI.CreateUIObject("container",CurtainLib.name, "_fi", left, top, width, height)
	_this.background="Texture/whitedot.png";
	_guihelper.SetUIColor(_this, "0 0 0");
	_this:AttachToRoot();
	return _this;
end
function CurtainLib.createStoryboard()
	if(not CurtainLib.Storyboard)then
		local frames = CommonCtrl.Animation.DoubleAnimationUsingKeyFrames:new{
			TargetName = CurtainLib.name,
			TargetProperty = "alpha",
		}
		local keyframe 
			keyframe = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
				KeyTime = "00:00:00",
				Value = 0,
			}	
		frames:addKeyframe(keyframe);
		keyframe = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
				KeyTime = "00:00:00.5",
				Value = 1,
			}	
		frames:addKeyframe(keyframe);
		keyframe = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
				KeyTime = "00:00:01",
				Value = 0,
			}	
		frames:addKeyframe(keyframe);
		
		local Storyboard = CommonCtrl.Animation.Storyboard:new();
		local StoryboardManager = CommonCtrl.Animation.StoryboardManager:new();
		
		StoryboardManager:AddChild(frames);
		Storyboard:SetAnimatorManager(StoryboardManager);
		
		Storyboard.OnMotionEnd = CurtainLib.OnMotionEnd;
		CurtainLib.Storyboard = Storyboard;
	end
end
function CurtainLib.doPlay()
	CurtainLib.createTopContainer();
	CurtainLib.createStoryboard()
	CurtainLib.Storyboard:doPlay();
end
function CurtainLib.OnMotionEnd(sControlName,time)
	ParaUI.Destroy(CurtainLib.name);
end
------------------------------------------------------------
-- MovieCaption 
------------------------------------------------------------
local MovieCaption = {
	name = "MovieCaption_instance",
}
commonlib.setfield("CommonCtrl.Animation.MovieCaption",MovieCaption);
function MovieCaption.show(bShow)
	local _parent=ParaUI.GetUIObject(MovieCaption.name);
	if(_parent:IsValid() == false)then		
		local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
		local _this = ParaUI.CreateUIObject("container",MovieCaption.name, "_lb", 0, -66, screenWidth, 66)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0");
		_this:AttachToRoot();
		_this.zorder = 1000;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", MovieCaption.name.."text", "_lt", 10,5,screenWidth-10,56)
		_this.text = "";
		_this.font="System;17;bold;true";
		_guihelper.SetFontColor(_this, "#ffffff");
		_this.shadow = false;
		_guihelper.SetUIFontFormat(_this,5);
		_parent:AddChild(_this);
	end
	_parent.visible = bShow;
end
function MovieCaption.setText(txt)
	if(not txt)then return; end
	local _this = ParaUI.GetUIObject(MovieCaption.name.."text");
	if(_this:IsValid())then
		_this.text = txt;	
	end
end

