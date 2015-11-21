--[[
Title: A special movie controller
Author(s): LiXizhi
Date: 2015/1/13
Desc: only shown when in read-only play mode. 
We can rotate the camera while playing, once untouched, camera returned to original position. 
TODO: in future we may add pause/resume/stop for currently playing movie in theater mode?
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/PlayModeController.lua");
local PlayModeController = commonlib.gettable("MyCompany.Aries.Game.Movie.PlayModeController");
PlayModeController:InitSingleton();
-------------------------------------------------------
]]
function PlayModeController:ctor()
end

-- simulate the touch event
function PlayModeController:OnMouseDown()
end

-- simulate the touch event
function PlayModeController:OnMouseUp()
end

-- simulate the touch event
function PlayModeController:OnMouseMove()
end

-- whether the page is visible. 
function PlayModeController:IsVisible()
end

-- when the game movie mode is changed
function PlayModeController:OnModeChanged(mode)
end

-- rotate camera 
function PlayModeController:handleTouchSessionMove(touch_session, touch)
end

-- rotate the camera based on delta in the touch_session. 
function PlayModeController:RotateCamera(touch_session)
end
