--[[ 
Title: Button styles in ParaEngine
Author(s): LiXizhi, WangTian
Date: 2005/10
desc: button styles
------------------------------------------------------
NPL.load("(gl)script/ide/ButtonStyles.lua");
------------------------------------------------------
]]
if(_guihelper==nil) then _guihelper={} end

-- make a button Windows Vista Style buttons, like the left top menu item in MS Office 2007.
-- @param uiobject: button UI object
-- @param foregroundImage: 
-- @param backgroundImage
-- @param background_image_color: default to "255 255 255". if can be "#ff00ff", etc
function _guihelper.SetVistaStyleButton(uiobject, foregroundImage, backgroundImage, background_image_color)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(not background_image_color) then
			background_image_color = "255 255 255";
		else
			background_image_color = _guihelper.ConvertColorToRGBAString(background_image_color);
		end

		if(backgroundImage~=nil) then
			uiobject:SetActiveLayer("background");
			uiobject.background = backgroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color=background_image_color;
			uiobject:SetCurrentState("pressed");
			uiobject.color="160 160 160";
			uiobject:SetCurrentState("disabled");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("normal");
			uiobject.color="0 0 0 0";
			
			uiobject:SetActiveLayer("artwork");
		end
		
		if(foregroundImage~=nil) then
			uiobject.background = foregroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color=background_image_color;
			uiobject:SetCurrentState("pressed");
			uiobject.color=background_image_color;
			uiobject:SetCurrentState("normal");
			uiobject.color=background_image_color;
		end
	end
end

-- NOTE: --WangTian: set background color visible when mouse not over
			--texture.color="255 255 255 255";
			--uiobject:SetCurrentState("disabled");
-- make a button Windows Vista Style buttons, like the left top menu item in MS Office 2007.
-- @param uiobject: button UI object
-- @param foregroundImage: 
function _guihelper.SetVistaStyleButton2(uiobject, foregroundImage, backgroundImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(backgroundImage~=nil) then
			uiobject:SetActiveLayer("background");
			uiobject.background = backgroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="160 160 160";
			uiobject:SetCurrentState("disabled");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("normal");
			uiobject.color="200 200 200";
			
			uiobject:SetActiveLayer("artwork");
		end
		
		if(foregroundImage~=nil) then
			uiobject:SetActiveLayer("artwork");
			uiobject.background = foregroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
		end
	end
end


-- NOTE: --WangTian: buttons for main bar icons
-- Note: only texture with ; in file name is supported. nine tile texture with : is not support yet. 
-- @param uiobject: button UI object
-- @param normalImage: normal and pressed layer image
-- @param mouseoverImage: highlight layer image
-- @param disableImage: disabled layer image
function _guihelper.SetVistaStyleButton3(uiobject, normalImage, mouseoverImage, disableImage, pressedImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(normalImage ~= nil) then
			
			uiobject:SetActiveLayer("artwork");
			
			-- tricky code: this ensures the layer type from 9 tile to 0 tile.
			uiobject.background = normalImage; 
			
			if(mouseoverImage) then
				uiobject:SetCurrentState("highlight");
				uiobject:GetTexture(nil).texture = mouseoverImage;
				uiobject.color="255 255 255";
			else
				uiobject:SetCurrentState("highlight");
				uiobject:GetTexture(nil).texture = normalImage;
				uiobject.color="255 255 255";
			end	
			if(pressedImage) then
				uiobject:SetCurrentState("pressed");
				uiobject:GetTexture(nil).texture = pressedImage;
				uiobject.color="255 255 255";
			else
				uiobject:SetCurrentState("pressed");
				uiobject:GetTexture(nil).texture = normalImage;
				uiobject.color="200 200 200";
			end	
			if(disableImage) then
				uiobject:SetCurrentState("disabled");
				uiobject:GetTexture(nil).texture = disableImage;
				uiobject.color="255 255 255";
			else
				uiobject:SetCurrentState("disabled");
				uiobject:GetTexture(nil).texture = normalImage;
				uiobject.color="160 160 160";
			end	
			uiobject:SetCurrentState("normal");
			uiobject:GetTexture(nil).texture = normalImage;
			uiobject.color="255 255 255";
			
			-- uiobject:SetActiveLayer("artwork");
		end
	end
end

-- NOTE: by andy: this is another solution of _guihelper.SetVistaStyleButton
--		the difference is this function swap the SetVistaStyleButton2 background and foreground color behavior
-- make a button Windows Vista Style buttons, like the left top menu item in MS Office 2007.
-- @param uiobject: button UI object
-- @param foregroundImage: 
function _guihelper.SetVistaStyleButton4(uiobject, foregroundImage, backgroundImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(backgroundImage~=nil) then
			uiobject:SetActiveLayer("background");
			uiobject.background = backgroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("disabled");
			uiobject.color="160 160 160";
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
			
			uiobject:SetActiveLayer("artwork");
		end
		
		if(foregroundImage~=nil) then
			uiobject:SetActiveLayer("artwork");
			uiobject.background = foregroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="160 160 160";
			uiobject:SetCurrentState("normal");
			uiobject.color="240 240 240";
		end
	end
end

-- show artwork layer when not over, and show background layer when active.
-- @param uiobject: button UI object
-- @param foregroundImage: 
function _guihelper.SetVistaStyleButton5(uiobject, foregroundImage, backgroundImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(backgroundImage~=nil) then
			uiobject:SetActiveLayer("background");
			uiobject.background = backgroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="160 160 160";
			uiobject:SetCurrentState("disabled");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("normal");
			uiobject.color="0 0 0 0";
			
			uiobject:SetActiveLayer("artwork");
		end
		
		if(foregroundImage~=nil) then
			uiobject.background = foregroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("pressed");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
		end
	end
end

-- NOTE: --WangTian: set background color bright
--			all status are colored "255 255 255"
-- make a button Windows Vista Style buttons, like the left top menu item in MS Office 2007.
-- @param uiobject: button UI object
-- @param foregroundImage: 
function _guihelper.SetVistaStyleButtonBright(uiobject, foregroundImage, backgroundImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(backgroundImage~=nil) then
			uiobject:SetActiveLayer("background");
			uiobject.background = backgroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("disabled");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
			
			uiobject:SetActiveLayer("artwork");
		end
		
		if(foregroundImage~=nil) then
			uiobject.background = foregroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
		end
	end
end

-- NOTE: --LiXizhi: buttons for tab views or main menu items
-- Note: only texture with ; in file name is supported. nine tile texture with : is not support yet. 
-- @param uiobject: button UI object
-- @param normalImage: normal and pressed layer image
-- @param mouseoverImage: highlight layer image
-- @param disableImage: disabled layer image
function _guihelper.SetTabStyleButton(uiobject, normalImage, mouseoverImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(normalImage ~= nil) then
			
			uiobject:SetActiveLayer("artwork");
			
			-- tricky code: this ensures the layer type from 9 tile to 0 tile.
			uiobject.background = normalImage; 
			
			uiobject:SetCurrentState("highlight");
			if(mouseoverImage) then
				uiobject:GetTexture(nil).texture = mouseoverImage;
			end	
			uiobject.color="255 255 255";
			
			uiobject:SetCurrentState("pressed");
			uiobject.color="160 160 160";
			
			uiobject:SetCurrentState("disabled");
			uiobject.color="160 160 160 160";
			
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
			
			-- uiobject:SetActiveLayer("artwork");
		end
	end
end