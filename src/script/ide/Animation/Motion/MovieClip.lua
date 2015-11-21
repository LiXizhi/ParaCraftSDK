--[[
Title: MovieClip
Author(s): Leio Zhang
Date: 2008/10/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/Reverse.lua");
NPL.load("(gl)script/ide/Animation/Motion/AnimationEditor/AnimationEditor.lua");
NPL.load("(gl)script/ide/Animation/Motion/Animator.lua");
NPL.load("(gl)script/ide/Animation/Motion/MovieClipBase.lua");
NPL.load("(gl)script/ide/Animation/Motion/LayerManager.lua");

NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeySpline.lua");

NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/AnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TargetAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/DoubleAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/ObjectAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/Point3DAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/Point3DAnimationUsingPath.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/StringAnimationUsingKeyFrames.lua");

NPL.load("(gl)script/ide/Animation/Motion/Target/CameraTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/LandTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/OceanTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/SkyTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/CaptionTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/ActorTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/SoundTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/BuildingTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/PlantTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/EffectTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/ControlTarget.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/Sprite3DTarget.lua");

NPL.load("(gl)script/ide/Animation/Motion/McPlayer.lua");
NPL.load("(gl)script/ide/Animation/Motion/PreLoader.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MoviePlayerPage.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/TargetResourceManager.lua");
local MovieClip = commonlib.inherit(CommonCtrl.Animation.Motion.MovieClipBase,{});  
commonlib.setfield("CommonCtrl.Animation.Motion.MovieClip",MovieClip);