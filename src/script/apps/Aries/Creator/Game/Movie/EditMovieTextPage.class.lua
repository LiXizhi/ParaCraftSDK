--[[
Title: edit movie text
Author(s): LiXizhi
Date: 2014/5/12
Desc: edit movie text page
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/EditMovieTextPage.lua");
local EditMovieTextPage = commonlib.gettable("MyCompany.Aries.Game.Movie.EditMovieTextPage");
EditMovieTextPage.ShowPage(nil, function(values)
	echo(values);
end, {text="1", fontsize="30", bganim="fadein"})
-------------------------------------------------------
]]
-- @param OnClose: function(values) end 
-- @param last_values: {text, ...}
function EditMovieTextPage.ShowPage(title, OnClose, last_values)
end
