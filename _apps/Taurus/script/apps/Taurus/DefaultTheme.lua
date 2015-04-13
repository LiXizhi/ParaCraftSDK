--[[
Title: load default UI theme
Author(s): WangTian
Date: 2008/12/2
Desc: load the default theme for the ui objects and common controls
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/DefaultTheme.lua");
------------------------------------------------------------
]]

-- load the default theme or style for the following ui objects and common controls
--		Cursor: default cursor
--		Day Length:
--		Default ui objects: scroll bar, button, text, editbox .etc
--		Font: default font
--		MessageBox: background
--		WindowFrame: frame background and close button
--		World Loader: background, logo, progress bar and text
function Taurus_LoadDefaultTheme()

	-- ParaUI.SetUseSystemCursor(true);
	local default_cursor = {file = "Texture/kidui/main/cursor.tga", hot_x=3,hot_y=4};
	NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/Cursor.lua");
	local Cursor = commonlib.gettable("Map3DSystem.UI.Cursor");
	Cursor.SetDefaultCursor(default_cursor);
	Cursor.ApplyCursor("default");

	local root_ = ParaUI.GetUIObject("root");
	if(root_.SetCursor) then
		root_:SetCursor(default_cursor.file, default_cursor.hot_x, default_cursor.hot_y);
	else
		root_.cursor = default_cursor.file;
	end
	
	
	System.options.layout = ParaEngine.GetAppCommandLineByParam("layout", "")
	-- NOTE: choose a font carefully for Taurus
	
	--System.DefaultFontFamily = "Tahoma"; -- Windows default font
	--System.DefaultFontFamily = "helvetica"; -- Macintosh default font
	--System.DefaultFontFamily = "Verdana"; -- famous microsoft font
	
	--System.DefaultFontFamily = "System";
	System.DefaultFontFamily = "System"
	System.DefaultFontSize = 12;
	System.DefaultFontWeight = "norm";
	
	local fontStr = string.format("%s;%d;%s", 
				System.DefaultFontFamily, 
				System.DefaultFontSize, 
				System.DefaultFontWeight);
				
	local _this;
	_this = ParaUI.GetDefaultObject("scrollbar");
	local states = {[1] = "highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};
	local function UpdateScrollBar_(_this)
		local i;
		for i = 1, 4 do
			_this:SetCurrentState(states[i]);
			texture=_this:GetTexture("track");
			texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_track.png";
			texture=_this:GetTexture("up_left");
			texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_upleft.png";
			texture=_this:GetTexture("down_right");
			texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_downright.png";
			texture=_this:GetTexture("thumb");
			texture.texture="Texture/3DMapSystem/common/ThemeLightBlue/scroll_thumb.png";
		end
		--_this.fixedthumb = false;
		--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/scroll_thumb.png:3 3 3 3";
	end
	UpdateScrollBar_(_this);

	_this=ParaUI.GetDefaultObject("button");
	_this.font = fontStr;
	_this.background = "Texture/Taurus/Button_Normal.png:8 8 7 7";

	_this=ParaUI.GetDefaultObject("listbox");
	_this.font = fontStr;
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/listbox_bg.png: 4 4 4 4";
	UpdateScrollBar_(_this:GetChild("vscrollbar"));
	
	_this=ParaUI.GetDefaultObject("container");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4";
	UpdateScrollBar_(_this:GetChild("vscrollbar"));

	_this=ParaUI.GetDefaultObject("editbox");
	_this.font = fontStr;
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/editbox_bg.png: 4 4 4 4";
	_this.spacing = 2;
	
	_this=ParaUI.GetDefaultObject("imeeditbox");
	_this.font = fontStr;
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/editbox_bg.png: 4 4 4 4";
	_this.spacing = 2;
	
	_this=ParaUI.GetDefaultObject("text");
	_this.font = fontStr;
	
	_this=ParaUI.GetDefaultObject("slider");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7"; 
	_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
	
	
	-- replace the default messagebox background with Taurus customization
	_guihelper.MessageBox_BG = "Texture/Taurus/MessageBox.png:24 24 24 24";
	-- default toplevel dialogbox bg
	_guihelper.DialogBox_BG = "Texture/Taurus/MessageBox.png:24 24 24 24";
	
	-- TODO: change the following background
	_guihelper.OK_BG = "Texture/Taurus/Button_HighLight.png:8 8 7 7";
	
	_guihelper.Cancel_BG = "Texture/Taurus/Button_Normal.png:8 8 7 7";
	
	_guihelper.QuestionMark_BG = "Texture/3DMapSystem/QuestionMark_BG.png";
	
	_guihelper.ExclamationMark_BG = "Texture/3DMapSystem/ExclamationMark_BG.png";
	
	
	NPL.load("(gl)script/ide/ContextMenu.lua");
	CommonCtrl.ContextMenu.DefaultStyle = {
		borderTop = 4,
		borderBottom = 4,
		borderLeft = 0,
		borderRight = 0,
		
		fillLeft = -20,
		fillTop = -20,
		fillWidth = -20,
		fillHeight = -24,
		
		menu_bg = "Texture/Aries/Dock/BBSChat_Panel.png:85 28 30 35",
		shadow_bg = nil,
		separator_bg = "Texture/Aquarius/Common/ContextMenu_Separator.png: 1 1 1 4",
		item_bg = "Texture/Aries/Dock/QuickWordMenuItem.png;0 0 64 24: 14 11 40 11",
		expand_bg = "Texture/Aries/Dock/QuickWordMenuExpand.png",
		expand_bg_mouseover = "Texture/Aries/Dock/QuickWordMenuExpand.png",
		
		menuitemHeight = 22,
		separatorHeight = 8,
		titleHeight = 22,
		
		titleFont = System.DefaultLargeBoldFontString;
	};
	
	-- replace the default window style with Aquarius customization
	CommonCtrl.WindowFrame.DefaultStyle = {
		name = "DefaultStyle",
		
		--window_bg = "Texture/Aquarius/Common/frame2_32bits.png:8 25 8 8",
		window_bg = "Texture/Aquarius/Common/Frame3_32bits.png:32 46 20 17",
		fillBGLeft = 0,
		fillBGTop = 0,
		fillBGWidth = 0,
		fillBGHeight = 0,
		
		shadow_bg = "Texture/Aquarius/Common/Frame3_shadow_32bits.png: 16 16 32 32",
		fillShadowLeft = -5,
		fillShadowTop = -4,
		fillShadowWidth = -9,
		fillShadowHeight = -10,
		
		titleBarHeight = 36,
		toolboxBarHeight = 48,
		statusBarHeight = 32,
		borderLeft = 1,
		borderRight = 1,
		borderBottom = 16,
		
		textfont = System.DefaultBoldFontString;
		textcolor = "35 35 35",
		
		iconSize = 16,
		iconTextDistance = 16, -- distance between icon and text on the title bar
		
		IconBox = {alignment = "_lt",
					x = 13, y = 12, size = 16,},
		TextBox = {alignment = "_lt",
					x = 32, y = 12, height = 16,},
					
		CloseBox = {alignment = "_rt",
					x = -24, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Close_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Close_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Close_pressed_32bits.png; 0 0 17 16",
					},
		MinBox = {alignment = "_rt",
					x = -60, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Min_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Min_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Min_pressed_32bits.png; 0 0 17 16",
					},
		MaxBox = {alignment = "_rt",
					x = -42, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Max_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Max_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Max_pressed_32bits.png; 0 0 17 16",
					},
		PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
					x = 2, y = 2, size = 20,
					icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
					icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
		
		resizerSize = 24,
		resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
	};
	
	-- change the loader UI, remove following lines if u want to use default paraworld loader ui.
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	System.UI.LoaderUI.items = {
		{name = "Taurus.UI.LoaderUI.bg", type="container",bg="Texture/Taurus/Loader/TaurusLoading.png", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "Taurus.UI.LoaderUI.logoTxt", type="container",bg="", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Taurus.UI.LoaderUI.logo", type="container",bg="", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Taurus.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",alignment = "_ct", left=-100, top=160, width=200, height=22, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Taurus.UI.LoaderUI.text", type="text", text="正在加载...", alignment = "_ct", left=-100+10, top=160+28, width=120, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "Taurus.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/3DMapSystem/Loader/progressbar_filled.png:7 7 13 7", alignment = "_ct", left=-100, top=160, width=20, max_width=200, height=22,anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	}

	local pe_css = commonlib.gettable("Map3DSystem.mcml_controls.pe_css");
	pe_css.default = {
		["taskbarbutton"] = {
			["width"] = 48,
			["height"] = 48,
			["margin"] = 8,
		},
	}
end