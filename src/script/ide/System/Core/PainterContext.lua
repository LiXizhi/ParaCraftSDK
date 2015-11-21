--[[
Title: Painting context
Author(s): LiXizhi
Date: 2015/4/20
Desc: wrapper to ParaPainter. It can also be used as an PaintEvent
---++ On Coordinate System
The 2D API uses Y axis downward coordinate; where as the 3D API uses Y up axis.
Both APIs can be used together. The final world matrix is calculated as thus:
	finalMatrix = mat2DFinal * matInvertY * mat3DFinal;	
	mat2DFinal is the final matrix by all the 2d api like scale, translate, rotate
	mat3DFinal is the final matrix by all the 3d api like PushMatrix, TranslateMatrix, etc.
Please note, mat3DFinal only takes effect when 3d mode is enabled, such as during rendering head on display or overlays.
When you are rendering 3D triangles mixed with 2D GUI, it is good practice to restore mat2DFinal to identity matrix after
drawing 2D GUI.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/PainterContext.lua");
local PainterContext = commonlib.gettable("System.Core.PainterContext");
local painter = System.Core.PainterContext:new():init(parent);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Matrix4.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

local PainterContext = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Core.PainterContext"));
local painter = PainterContext; -- just for NPLDoc, since most PainterContext is called painter in function parameter. 

PainterContext.event_type = "paintEvent";
local ParaPainter = ParaPainter;

function painter:ctor()
end

-- TODO:
function painter:rect()
	return self.m_rect;
end

-- TODO:
function painter:region()
	return self.m_region;
end

function painter:init(parentWindow)
	self.parentWindow = parentWindow;
	return self;
end

function painter:GetWindow()
	return self.parentWindow;
end

function painter:Begin(paintDevice)
	return ParaPainter.Begin(paintDevice);
end

function painter:End()
	return ParaPainter.End();
end

function painter:Flush()
	ParaPainter.Flush();
end

function painter:Save()
	ParaPainter.Save();
end

function painter:Restore()
	ParaPainter.Restore();
end

--[[
CompositionMode_SourceBlend= 0,
CompositionMode_SourceOver= 1,
CompositionMode_DestinationOver = 2,
CompositionMode_Clear = 3,
CompositionMode_Source = 4,
CompositionMode_Destination = 5,
CompositionMode_SourceIn,
CompositionMode_DestinationIn,
CompositionMode_SourceOut,
CompositionMode_DestinationOut,
CompositionMode_SourceAtop,
CompositionMode_DestinationAtop,
CompositionMode_Xor,
CompositionMode_Plus,
CompositionMode_PlusSourceBlend,
]]
function painter:SetCompositionMode(mode)
	ParaPainter.SetCompositionMode(mode);
end

function painter:GetCompositionMode()
	return ParaPainter.GetCompositionMode();
end

-- set current font 
-- @param font: {family="System", size=10, bold=true}
-- or it can be string "System;14;" or "System;14;bold"
function painter:SetFont(font)
	ParaPainter.SetFont(font);
end

-- set current pen
-- @param pen: { width=1, brush = {color="#00000000", texture="filename or texture asset"}, }
-- or it can be {width=1, color="#000000", texture="filename or texture asset"}
-- or it can be pen color "#ff000000" or "255 255 255" or DWORD
function painter:SetPen(pen)
	ParaPainter.SetPen(pen);
end

-- set current brush (texture and color)
-- @param brush: { color="#00000000", texture="filename or texture asset"} 
-- or it can be pen color "#ff000000" or "255 255 255" or DWORD
function painter:SetBrush(brush)
	ParaPainter.SetBrush(brush);
end

function painter:SetBrushOrigin(x, y)
	ParaPainter.SetBrushOrigin(x, y);
end

-- set current background brush
-- @param brush: { color="#00000000", texture="filename or texture asset"}
function painter:SetBackground(brush)
	ParaPainter.SetBackground(brush);
end

-- between [0,1]
function painter:SetOpacity(fOpacity)
	ParaPainter.SetOpacity(fOpacity);
end

function painter:SetClipRegion(x, y, w, h)
	ParaPainter.SetClipRegion(x, y, w, h);
end

function painter:SetClipping(enable)
	ParaPainter.SetClipping(enable);
end

function painter:HasClipping()
	return ParaPainter.HasClipping();
end

		

-- Sets the world transformation matrix.
-- If combine is true, the specified matrix is combined with the current matrix; otherwise it replaces the current matrix.
function painter:SetTransform(trans, combine)
	ParaPainter.SetTransform(trans, combine);
end

function painter:GetTransform(out)
	return ParaPainter.GetTransform(out);
end

function painter:Scale(sx, sy)
	ParaPainter.Scale(sx, sy);
end

function painter:Shear(sh, sv)
	ParaPainter.Shear(sh, sv);
end

function painter:Rotate(a)
	ParaPainter.Rotate(a);
end

function painter:Translate(dx, dy)
	ParaPainter.Translate(dx, dy);
end

function painter:DrawPoint(x, y)
	ParaPainter.DrawPoint(x, y);
end

function painter:DrawLine(x1, y1, x2, y2)
	ParaPainter.DrawLine(x1, y1, x2, y2);
end

-- draw triangle List
--@param triangles: array of triangle vertices {{0,1,0}, {1,0,0}, {0,0,1}, ...}, 
--@param nTriangleCount: triangle count, default to #triangleList/ 3
--@param nIndexOffset: start index offset. default to 0.
function painter:DrawTriangleList(triangles, nTriangleCount, nIndexOffset)
	nTriangleCount = nTriangleCount or (#triangles)/3;
	ParaPainter.DrawTriangleList(triangles, nTriangleCount, indexOffset or 0);
end

-- draw line List
--@param lineList: array of line vertices {{0,1,0}, {1,0,1},  ...}, 
--@param nlineCount: line count, default to #lineList/ 2
--@param nIndexOffset: start index offset. default to 0.
function painter:DrawLineList(lineList, nlineCount, nIndexOffset)
	nlineCount = nlineCount or (#lineList)/2;
	ParaPainter.DrawLineList(lineList, nlineCount, indexOffset or 0);
end

function painter:DrawRect(left, top, width, height)
	if(left and top and width and height) then
		ParaPainter.DrawRect(left, top, width, height);
	else
		echo("invalid DrawRect:"..tostring(commonlib.debugstack(2, 5, 1)));
	end
end

function painter:DrawTexture(x, y, w, h, pTexture, sx, sy, sw, sh)
	if(sx) then
		ParaPainter.DrawTexture(x, y, w, h, pTexture, sx, sy, sw, sh);
	else
		ParaPainter.DrawTexture(x, y, w, h, pTexture);
	end
end

-- @param w, h: if h is nil, w is the sText
function painter:DrawText(x, y, w, h, sText, textOption)
	if(h and sText) then
		ParaPainter.DrawText(x, y, w, h, sText, textOption);
	else
		ParaPainter.DrawText(x, y, w);
	end
end

-- helper function:
-- @param scale: text scale. if nil or 1, it is same as DrawText()
function painter:DrawTextScaled(x, y, text, scale)
	if(text and text~="") then
		if(scale and scale~=1) then
			self:Save();
			self:Translate(x,y);
			self:Scale(scale, scale);
			self:DrawText(0,0, text);
			self:Restore();
		else
			self:DrawText(x,y, text);
		end
	end
end

-- Set the text align and other text displaying formats
-- @param alignment: It can be any combination of the following values.
-- DT_BOTTOM (0x00000008)
-- Justifies the text to the bottom of the rectangle. This value must be combined with DT_SINGLELINE.
-- DT_CALCRECT (0x00000400)
-- Determines the width and height of the rectangle. If there are multiple lines of text, ID3DXFont::DrawText uses the width of the rectangle pointed to by the pRect parameter and extends the base of the rectangle to bound the last line of text. If there is only one line of text, ID3DXFont::DrawText modifies the right side of the rectangle so that it bounds the last character in the line. In either case, ID3DXFont::DrawText returns the height of the formatted text but does not draw the text.
-- DT_CENTER (0x00000001)
-- Centers text horizontally in the rectangle.
-- DT_EXPANDTABS (0x00000040)
-- Expands tab characters. The default number of characters per tab is eight.
-- DT_LEFT (0x00000000)
-- Aligns text to the left.
-- DT_NOCLIP (0x00000100)
-- Draws without clipping. ID3DXFont::DrawText is somewhat faster when DT_NOCLIP is used.
-- DT_RIGHT (0x00000002)
-- Aligns text to the right.
-- DT_RTLREADING
-- Displays text in right-to-left reading order for bi-directional text when a Hebrew or Arabic font is selected. The default reading order for all text is left-to-right.
-- DT_SINGLELINE (0x00000020)
-- Displays text on a single line only. Carriage returns and line feeds do not break the line.
-- DT_TOP (0x00000000)
-- Top-justifies text.
-- DT_VCENTER (0x00000004)
-- Centers text vertically (single line only).
-- DT_WORDBREAK (0x00000010)
-- Breaks words. Lines are automatically broken between words if a word would extend past the edge of the rectangle specified by the pRect parameter. A carriage return/line feed sequence also breaks the line.
function painter:DrawTextScaledEx(x, y, width, height, text, alignment, scale)
	if(text and text~="") then
		if(scale and scale~=1) then
			self:Save();
			self:Translate(x,y);
			self:Scale(scale, scale);
			self:DrawText(0,0, width, height, text, alignment);
			self:Restore();
		else
			self:DrawText(x,y, width, height, text, alignment);
		end
	end
end


-- helper function: 
-- @param texture: if nil or "" or "Texture/whitedot.png", it will render with current pen color. 
-- otherwise it can also be single or 9-tiled texture
function painter:DrawRectTexture(x, y, width, height, texture)
	if(texture and texture~="" and texture~="Texture/whitedot.png") then
		self:DrawTexture(x, y, width, height, texture);
	else
		self:DrawRect(x, y, width, height);
	end
end

-----------------------------------
-- 3d transform related. only useful in 3d mode such as rendering overlays.
-----------------------------------

-- similar to glMatrixMode() in opengl. 
-- @param nMode:  0 is world, 1 is view, 2 is projection. default to 0. 
function painter:SetMatrixMode(nMode)
	ParaPainter.SetField("MatrixMode", nMode);
end

function painter:GetMatrixMode()
	return ParaPainter.GetField("MatrixMode", 0);
end
		
-- similar to glPushMatrix() in opengl.
function painter:PushMatrix()
	ParaPainter.CallField("PushMatrix");
end

-- similar to glPopMatrix() in opengl.
function painter:PopMatrix()
	ParaPainter.CallField("PopMatrix");
end

-- retrieve the current matrix. 
function painter:LoadCurrentMatrix()
	ParaPainter.CallField("LoadCurrentMatrix");
end

-- load identity matrix 
function painter:LoadIdentityMatrix()
	ParaPainter.CallField("LoadIdentityMatrix");
end

-- load billboard matrix, so that everything rendered (including text) always face the camera.
function painter:LoadBillboardMatrix()
	ParaPainter.CallField("LoadBillboardMatrix");
end

-- we use row-major matrix 
-- @param mat: both 4*3 or 4*4 matrix are fine
function painter:LoadMatrix(mat)
	ParaPainter.SetField("LoadMatrix", mat);
end

-- multiply the current matrix with the specified matrix. we use row-major matrix 
function painter:MultiplyMatrix(mat)
	ParaPainter.SetField("MultiplyMatrix", mat);
end

local tmpVec3d = {};
-- multiply the current matrix by a translation matrix 
function painter:TranslateMatrix(x, y, z)
	tmpVec3d[1], tmpVec3d[2], tmpVec3d[3] = x, y, z;
	ParaPainter.SetField("TranslateMatrix", tmpVec3d);
end

local tmpVec4d = {};
-- multiply the current matrix by a rotation matrix 
function painter:RotateMatrix(angle, x, y, z)
	tmpVec4d[1], tmpVec4d[2], tmpVec4d[3], tmpVec4d[4] = angle, x, y, z;
	ParaPainter.SetField("RotateMatrix", tmpVec4d);
end

-- multiply the current matrix by a scaling matrix 
function painter:ScaleMatrix(x, y, z)
	tmpVec3d[1], tmpVec3d[2], tmpVec3d[3] = x, y, z;
	ParaPainter.SetField("ScaleMatrix", tmpVec3d);
end

-- get current scaling. 
-- @return x,y,z of current scaling. 
function painter:GetScaling()
	return unpack(ParaPainter.GetField("Scaling", tmpVec3d));
end

-- get current matrix
-- @return a new Matrix4
function painter:GetCurrentMatrix()
	return ParaPainter.GetField("CurrentMatrix", Matrix4:new());
end

-- if enabled, the minimum line width is 1 pixel for 3d lines.
-- @param bEnable: if nil or true, it means true
function painter:EnableAutoLineWidth(bEnable)
	ParaPainter.SetField("AutoLineWidth", bEnable~=false);
end
