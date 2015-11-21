--[[
Title: animation_editor_test_page
Author(s): Leio Zhang
Date: 2008/10/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/test/animation_editor_test_page.lua");
CommonCtrl.Animation.Motion.animation_editor_test_page.Show()
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClipHelper.lua");
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");
local animation_editor_test_page = {

}
commonlib.setfield("CommonCtrl.Animation.Motion.animation_editor_test_page",animation_editor_test_page);
function animation_editor_test_page.OnInit()
	local page = document:GetPageCtrl();
	animation_editor_test_page.page = page
end
function animation_editor_test_page.OnPreview_1()
	local self = animation_editor_test_page;
	self.OnPreview(1)
end
function animation_editor_test_page.OnPreview_2()
	local self = animation_editor_test_page;
	self.OnPreview(2)
end
function animation_editor_test_page.OnPreview_3()
	local self = animation_editor_test_page;
	self.OnPreview(3)
end
function animation_editor_test_page.OnPreview_4()
	local self = animation_editor_test_page;
	self.OnPreview(4)
end
function animation_editor_test_page.OnPreview_5()
	local self = animation_editor_test_page;
	self.OnPreview(5)
end
function animation_editor_test_page.OnTest_MovieClipHelpler_PlayControlTarget()
	local self = animation_editor_test_page;
	local objName = self.GetMcmlControlName("ImgControl_1");
	local property = "Alpha";
	local duration = "00:00:05";
	local fromValue = 0.1;
	local toValue = 1;
	local simpleEase = 1;
	CommonCtrl.Animation.Motion.MovieClipHelper.PlayControlTargetProperty(objName,property,duration,fromValue,toValue,simpleEase)
end
function animation_editor_test_page.OnPreview(index)
	if(not index)then return; end
	local self = animation_editor_test_page;
	local str = "CommonCtrl.Animation.Motion.animation_editor_test_page.mc = CommonCtrl.Animation.Motion.animation_editor_test_page.Test_Script_"..index.."()";
	NPL.DoString(str);
	local mc = CommonCtrl.Animation.Motion.animation_editor_test_page.mc;
	Map3DSystem.Movie.MoviePlayerPage.DoOpenWindow();
	Map3DSystem.Movie.MoviePlayerPage.DataBind(mc);
end
function animation_editor_test_page.GetMcmlControlName(name)
	if(not name)then return end
	local self = animation_editor_test_page;
	local targetNode = self.page:GetNode(name);
		if(targetNode)then
			local UICtrlName = targetNode:GetInstanceName(self.page.name);
			return UICtrlName;
		end
end
function animation_editor_test_page.Test_Script_1()
	local self = animation_editor_test_page;
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	-------------layer_1
	local Name = self.GetMcmlControlName("ImgControl_1");
	local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00", SimpleEase = 1,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:03"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:03", SimpleEase = 0,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:08"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:08",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_1:AddChild(targetKeyFrames);
	root_mc:AddLayer(layer_1);
		
	root_mc:UpdateDuration();
	return root_mc;
end
function animation_editor_test_page.Test_Script_2()
	local self = animation_editor_test_page;
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	-------------layer_1
	local Name = self.GetMcmlControlName("ImgControl_1");
	local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00", SimpleEase = 0,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:02"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:02", SimpleEase = -1,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 100,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:05"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:05",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:08"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:08",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_1:AddChild(targetKeyFrames);
	root_mc:AddLayer(layer_1);
	-------------layer_2
	Name = self.GetMcmlControlName("ImgControl_2");
	local layer_2 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0, };
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:03"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:03",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 100,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:07"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:07",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:10"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:10",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_2:AddChild(targetKeyFrames);
	targetKeyFrames:addKeyframe(t_frame);
	root_mc:AddLayer(layer_2);
	
	root_mc:UpdateDuration();
	return root_mc;
end
function animation_editor_test_page.Test_Script_3()
	local self = animation_editor_test_page;
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	-------------layer_1
	local Name = self.GetMcmlControlName("ImgControl_1");
	local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	local t_frame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{KeyTime = "00:00:00",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:02"
	t_frame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{KeyTime = "00:00:02",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 100,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:05"
	t_frame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{KeyTime = "00:00:05",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:08"
	t_frame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{KeyTime = "00:00:08",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_1:AddChild(targetKeyFrames);
	root_mc:AddLayer(layer_1);
	-------------layer_2
	Name = self.GetMcmlControlName("ImgControl_2");
	local layer_2 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0, };
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:03"
	t_frame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{KeyTime = "00:00:03",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 100,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:07"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:07",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:10"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:10",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_2:AddChild(targetKeyFrames);
	targetKeyFrames:addKeyframe(t_frame);
	root_mc:AddLayer(layer_2);
	
	root_mc:UpdateDuration();
	return root_mc;
end
function animation_editor_test_page.Test_Script_4()
	local self = animation_editor_test_page;
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	-------------layer_1 first keyframes
	local Name = self.GetMcmlControlName("ImgControl_1");
	local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:04"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:04",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_1:AddChild(targetKeyFrames);
	
	-------------layer_1 second keyframes
	Name = self.GetMcmlControlName("ImgControl_2");
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0, };
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:03"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:03",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 100,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_1:AddChild(targetKeyFrames);
	
	root_mc:AddLayer(layer_1);
	-------------layer_2
	Name = self.GetMcmlControlName("ImgControl_3");
	local layer_2 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0, };
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:03"
	t_frame = CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame:new{KeyTime = "00:00:03",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 100,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:07"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:07",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 300,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:10"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:10",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_2:AddChild(targetKeyFrames);
	targetKeyFrames:addKeyframe(t_frame);
	root_mc:AddLayer(layer_2);
	
	root_mc:UpdateDuration();
	return root_mc;
end
function animation_editor_test_page.Test_Script_5()
	local self = animation_editor_test_page;
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	-------------layer_1
	local Name = self.GetMcmlControlName("ImgControl_1");
	local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};
	-- "00:00:00"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00", SimpleEase = 1,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 0, Y = 0, ScaleX = 1, ScaleY = 1, Alpha = 1, Rot = 0, Visible = true,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:03"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:03", SimpleEase = 0,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 200, Y = 300, ScaleX = 0.2, ScaleY = 0.2, Rot = 60, Alpha = 0.5,}
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:04"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:04",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 200, Y = 300, ScaleX = 0.2, ScaleY = 0.2, Alpha = 0.5, Visible = false,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:05"
	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:05",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 200, Y = 300, ScaleX = 0.2, ScaleY = 0.2, Alpha = 0.5, Visible = true,};
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- "00:00:08"
	t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:08",}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new{ X = 400, Y = 400, ScaleX = 1, ScaleY = 1, Alpha = 1, Visible = true, };
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	-- add child
	layer_1:AddChild(targetKeyFrames);
	root_mc:AddLayer(layer_1);
		
	root_mc:UpdateDuration();
	return root_mc;
end
function animation_editor_test_page.Show()
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	NPL.load("(gl)script/ide/Animation/Motion/test/animation_editor_test_page.lua");
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/ide/Animation/Motion/test/animation_editor_test_page.html", name="animation_editor_test_page", 
			app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
			text = "测试",
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			isShowMinimizeBox = false,
			isShowCloseBox = true,
			allowResize = false,
			initialPosX = (screenWidth-640)/2,
			initialPosY = (screenHeight-480)/2,
			initialWidth = 640,
			initialHeight = 480,
			bToggleShowHide = false,
			bShow = true,
			DestroyOnClose = true,
		});
end
