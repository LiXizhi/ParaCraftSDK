--[[
Title: video recording settings
Author(s): LiXizhi
Date: 2014/5/21
Desc: video recording settings. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/VideoRecorderSettings.lua");
local VideoRecorderSettings = commonlib.gettable("MyCompany.Aries.Game.Movie.VideoRecorderSettings");
VideoRecorderSettings.ShowPage(function(settings)
end);
-------------------------------------------------------
]]
-- @param OnClose: function(result, values) end 
-- result is "ok" is user clicks the OK button. 
function VideoRecorderSettings.ShowPage(OnClose)
end
