--[[
Title: time line view
Author(s): LiXizhi
Date: 2015/4/20
Desc: a time line view renders rows of (x(i),t), each of which is projected to 2d coordinates. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/TimelineView.lua");
local TimelineView = commonlib.gettable("MyCompany.Aries.Game.Movie.TimelineView");

TimelineView  <--> MovieClip
	TimelineTime <--> MovieClip
	TimelineActor <--> Actor
		TimelineVar <--> Variable
		TimelineDicreteVar <--> Variable
		TimelineMultiVar <--> Variables
		Timeline3DPos <--> Variables
		TimelineBone <--> Variables
-------------------------------------------------------
]]