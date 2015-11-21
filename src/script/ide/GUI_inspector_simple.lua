--[[
Title: common control shared lib
Author(s): LiXizhi
Date: 2006/7/15
Desc: a collection of functions and UIs to inspect GUI object at the mouse position. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/GUI_inspector_simple.lua");
-- call this function at any time to inspect UI at the current mouse position
CommonCtrl.GUI_inspector_simple.InspectUI(); 
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");
if(not CommonCtrl) then CommonCtrl={}; end

local GUI_inspector_simple = {
	enabled = true,
	lastX=0,lastY=0,
};

CommonCtrl.GUI_inspector_simple = GUI_inspector_simple;

--[[ inspect the GUI at the current position and out put the result to the GUI inspector window.
@param x,y: the screen position. if nil,nil, the current mouse position is used for probing.
]]
function GUI_inspector_simple.InspectUI(x,y)
	if(not x or not y)then
		x,y = ParaUI.GetMousePosition();
		GUI_inspector_simple.lastX,GUI_inspector_simple.lastY = x,y;
	end
	local temp = ParaUI.GetUIObjectAtPoint(x,y);
	if(temp:IsValid() == true) then
		
		local abs_x,abs_y = temp:GetAbsPosition();
		local r_x,r_y = x - abs_x, y - abs_y;
		local att = temp:GetAttributeObject();
		local text = string.format([[mouse pos: %d,%d
type:%s
name: %s(id:%d)
parent %s(id:%d)
control width,height: %d, %d
bg: %s
relative pos: %d, %d
ClickThrough: %s
]], x,y,temp.type, temp.name, temp.id, temp.parent.name, temp.parent.id, temp.width, temp.height, temp.background, r_x,r_y, tostring(att:GetField("ClickThrough", false)));
		_guihelper.MessageBox(text);
	else
		local text = string.format([[mouse pos: %d, %d
]], x,y);
		_guihelper.MessageBox(text);
	end
end