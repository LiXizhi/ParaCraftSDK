-----------------------------------------------------------------------------------------
--General Mouse Behavior
-----------------------------------------------------------------------------------------
--if the left mouse button is hold and the mouse is move for this distance (x-axis + y-axis) in pixels, it will start dragging
Config.SetIntValue("Drag_begin_distance",5);
--if time between the second and the first button down event is less than this value in milliseconds, it is a double-click.
Config.SetIntValue("DBClick_interval",200);


----------------------------------------------------------------------------------------
--General Keyboard Behavior
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-- Tooltip Behavior
----------------------------------------------------------------------------------------
--ParaToolTip.initialdelay = 0; -- in milliseconds mouse hover time before a tip is shown. 
--ParaToolTip.autopopdelay = 3000; -- in milliseconds for how long the tip stays
--ParaToolTip.behavior = 0; -- 0 normal, 1 blink

----------------------------------------------------------------------------------------
--Basic Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
--Add the event mapping. 
--The values are in pairs. The following two lines means that EM_MOUSE_LEFTDOWN will trigger EM_CTRL_FOCUSIN
--Config.AppendTextValue("GUI_basic_control_mapping","EM_MOUSE_LEFTDOWN");
--Config.AppendTextValue("GUI_basic_control_mapping","EM_CTRL_FOCUSIN");
--if you have more mappings, add the pairs under the same key "GUI_basic_control_mapping"

--Add script for events
--The values are in pairs. The following two lines means that EM_MOUSE_LEFTDOWN will trigger a script "mouseleftdown()" in test.lua
--Config.AppendTextValue("GUI_basic_control_script","EM_MOUSE_LEFTDOWN");
--Config.AppendTextValue("GUI_basic_control_script","test.lua;mouseleftdown();");

----------------------------------------------------------------------------------------
-- Font mapping
-- One can install custom game font files at "fonts/*.ttf"
----------------------------------------------------------------------------------------
-- map "System" to "fonts/Tahoma.ttf", if exist, or "Tahoma" font
--local system_font_name = "Verdana";
-- local system_font_name = "ParaEngineThaiFont";
local system_font_name = "Tahoma";
--local system_font_name = "Georgia";
Config.AppendTextValue("GUI_font_mapping","System");	Config.AppendTextValue("GUI_font_mapping",system_font_name);

----------------------------------------------------------------------------------------
--Basic Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetIntValue("GUI_basic_control_candrag",0);--means "false"
Config.SetIntValue("GUI_basic_control_visible",1);--means "true"
Config.SetIntValue("GUI_basic_control_enable",1);
Config.SetIntValue("GUI_basic_control_lifetime",-1);--means permenent
Config.SetIntValue("GUI_basic_control_canhasfocus",0);
Config.SetIntValue("GUI_basic_control_receivedrag",0);

----------------------------------------------------------------------------------------
--Button Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
--these are the default behavior of the control. If deleted, the control may not function correctly
Config.AppendTextValue("GUI_button_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_button_control_mapping","EM_CTRL_CAPTUREMOUSE");
Config.AppendTextValue("GUI_button_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_button_control_mapping","EM_CTRL_RELEASEMOUSE");
Config.AppendTextValue("GUI_button_control_mapping","EM_MOUSE_LEFTCLICK");
Config.AppendTextValue("GUI_button_control_mapping","EM_BTN_CLICK");
Config.AppendTextValue("GUI_button_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_button_control_mapping","EM_BTN_DOWN");
Config.AppendTextValue("GUI_button_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_button_control_mapping","EM_BTN_UP");

----------------------------------------------------------------------------------------
--Tooltip control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
-- please note: it must be a 9 tile image with image rect and inner rect explicitly specified. 
Config.SetTextValue("CGUIToolTip_background","Texture/tooltip2_32bits.PNG;0 0 16 16:6 8 5 6");
Config.SetIntValue("CGUIToolTip_padding", 7);
Config.SetTextValue("CGUIToolTip_font", system_font_name..";12;norm");
Config.SetTextValue("CGUIToolTip_fontcolor","35 35 35 255"); -- rgba font color


----------------------------------------------------------------------------------------
--Button Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetTextValue("GUI_button_control_background","Texture/dxutcontrols.dds;136 0 136 54");

----------------------------------------------------------------------------------------
--Text Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetTextValue("GUI_text_control_background","Texture/dxutcontrols.dds;0 0 0 0");

----------------------------------------------------------------------------------------
--Container Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
--these are the default behavior of the control. If deleted, the control may not function correctly
Config.AppendTextValue("GUI_container_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_container_control_mapping","EM_CTRL_CAPTUREMOUSE");
Config.AppendTextValue("GUI_container_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_container_control_mapping","EM_CTRL_RELEASEMOUSE");

----------------------------------------------------------------------------------------
--Container Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetIntValue("GUI_container_control_canhasfocus",0);
Config.SetIntValue("GUI_container_control_fastrender",1);
Config.SetIntValue("GUI_container_control_scrollbarwidth",15);
Config.SetIntValue("GUI_container_control_margin",0);
Config.SetIntValue("GUI_container_control_borderwidth",0);
Config.SetIntValue("GUI_container_control_scrollable",0);
Config.SetTextValue("GUI_container_control_background","Texture/dxutcontrols.dds;13 124 228 141");

----------------------------------------------------------------------------------------
--Scrollbar Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
--these are the default behavior of the control. If deleted, the control may not function correctly
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_CTRL_CAPTUREMOUSE");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_CTRL_RELEASEMOUSE");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_SB_ACTIONBEGIN");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_SB_ACTIONEND");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_KEY_PAGE_DOWN");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_SB_PAGEDOWN");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_KEY_PAGE_UP");
Config.AppendTextValue("GUI_scrollbar_control_mapping","EM_SB_PAGEUP");

----------------------------------------------------------------------------------------
--Scrollbar Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetTextValue("GUI_scrollbar_control_track","Texture/dxutcontrols.dds;243 144 22 11");
Config.SetTextValue("GUI_scrollbar_control_upleft","Texture/dxutcontrols.dds;243 124 22 20");
Config.SetTextValue("GUI_scrollbar_control_downright","Texture/dxutcontrols.dds;243 155 22 21");
Config.SetTextValue("GUI_scrollbar_control_thumb","Texture/dxutcontrols.dds;266 123 20 44");

----------------------------------------------------------------------------------------
--EditBox Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.AppendTextValue("GUI_editbox_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_CTRL_CAPTUREMOUSE");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_CTRL_RELEASEMOUSE");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_EB_SELECTSTART");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_EB_SELECTEND");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_MOUSE_LEFTCLICK");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_EB_SELECTEND");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_MOUSE_LEFTDBCLICK");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_EB_SELECTALL");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_KEY_TAB");
Config.AppendTextValue("GUI_editbox_control_mapping","EM_CTRL_NEXTKEYFOCUS");

----------------------------------------------------------------------------------------
--EditBox Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetIntValue("GUI_editbox_control_9element",0);
Config.SetIntValue("GUI_editbox_control_borderwidth",1);
Config.SetIntValue("GUI_editbox_control_spacing",4);
Config.SetIntValue("GUI_editbox_control_careton",1);
Config.SetIntValue("GUI_editbox_control_readonly",0);
Config.SetIntValue("GUI_editbox_control_multipleline",0);
Config.SetTextValue("GUI_editbox_control_background","Texture/dxutcontrols.dds;14 90 227 23");
Config.SetTextValue("GUI_editbox_control_topleft","Texture/dxutcontrols.dds;8 82 6 8");
Config.SetTextValue("GUI_editbox_control_top","Texture/dxutcontrols.dds;14 82 227 8");
Config.SetTextValue("GUI_editbox_control_topright","Texture/dxutcontrols.dds;241 82 5 8");
Config.SetTextValue("GUI_editbox_control_left","Texture/dxutcontrols.dds;8 90 6 23");
Config.SetTextValue("GUI_editbox_control_right","Texture/dxutcontrols.dds;241 90 5 23");
Config.SetTextValue("GUI_editbox_control_bottomleft","Texture/dxutcontrols.dds;8 113 6 8");
Config.SetTextValue("GUI_editbox_control_bottom","Texture/dxutcontrols.dds;14 113 227 8");
Config.SetTextValue("GUI_editbox_control_bottomright","Texture/dxutcontrols.dds;241 113 5 8");

----------------------------------------------------------------------------------------
--IMEEditBox Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.AppendTextValue("GUI_imeeditbox_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_imeeditbox_control_mapping","EM_IME_SELECT");
Config.AppendTextValue("GUI_imeeditbox_control_mapping","EM_MOUSE_LEFTCLICK");
Config.AppendTextValue("GUI_imeeditbox_control_mapping","EM_IME_SELECT");

----------------------------------------------------------------------------------------
--IMEEditBox Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetTextValue("GUI_imeeditbox_control_candidate","Texture/dxutcontrols.dds;0 0 136 54");
--shall add candidate window style control here later.

----------------------------------------------------------------------------------------
--Slider Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.AppendTextValue("GUI_slider_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_slider_control_mapping","EM_SL_ACTIONBEGIN");
Config.AppendTextValue("GUI_slider_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_slider_control_mapping","EM_SL_ACTIONEND");
Config.AppendTextValue("GUI_slider_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_slider_control_mapping","EM_CTRL_FOCUSIN");

----------------------------------------------------------------------------------------
--Slider Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetIntValue("GUI_slider_control_defaultvalue",50);
Config.SetIntValue("GUI_slider_control_defaultmax",100);
Config.SetIntValue("GUI_slider_control_defaultmin",0);
Config.SetIntValue("GUI_slider_control_canhasfocus",1);
Config.SetTextValue("GUI_slider_control_background","Texture/dxutcontrols.dds;1 290 279 41");
Config.SetTextValue("GUI_slider_control_button","Texture/dxutcontrols.dds;248 55 41 41");

----------------------------------------------------------------------------------------
--ListBox Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_CTRL_CAPTUREMOUSE");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_CTRL_RELEASEMOUSE");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_LB_ACTIONBEGIN");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_LB_ACTIONEND");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTCLICK");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_LB_ACTIONEND");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTCLICK");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_CTRL_RELEASEMOUSE");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_MOUSE_LEFTDBCLICK");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_CTRL_CHANGE");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_KEY_RETURN");
Config.AppendTextValue("GUI_listbox_control_mapping","EM_CTRL_CHANGE");

----------------------------------------------------------------------------------------
--ListBox Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetIntValue("GUI_listbox_control_multiselect",0);
Config.SetIntValue("GUI_listbox_control_itemheight",0);--means the contorl will update height automatically
Config.SetIntValue("GUI_listbox_control_border",2);
Config.SetIntValue("GUI_listbox_control_margin",6);
Config.SetIntValue("GUI_listbox_control_canhasfocus",0);
Config.SetIntValue("GUI_listbox_control_fastrender",1);
Config.SetIntValue("GUI_listbox_control_wordbreak",0);
Config.SetIntValue("GUI_listbox_control_scrollbarwidth",16);
Config.SetIntValue("GUI_listbox_control_scrollable",1);
--Config.SetTextValue("GUI_listbox_control_background","Texture/dxutcontrols.dds;1 290 279 41");
Config.SetTextValue("GUI_listbox_control_selection","Texture/dxutcontrols.dds;17 269 224 18");

----------------------------------------------------------------------------------------
--Canvas Control Behavior
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.AppendTextValue("GUI_canvas_control_mapping","EM_MOUSE_LEFTDOWN");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_CV_ROTATEBEGIN");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_MOUSE_LEFTUP");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_CV_ROTATEEND");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_MOUSE_MIDDLEDOWN");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_CV_PANBEGIN");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_MOUSE_MIDDLEUP");
Config.AppendTextValue("GUI_canvas_control_mapping","EM_CV_PANEND");

----------------------------------------------------------------------------------------
--Canvas Control Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
Config.SetDoubleValue("GUI_canvas_control_rotatespeed",1.0);
Config.SetDoubleValue("GUI_canvas_control_panspeed",1.0);

----------------------------------------------------------------------------------------
--Highlight effect Properties
--These options will be overriden by the specified class's behavior.
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--4outsideArrow effect
----------------------------------------------------------------------------------------
Config.SetTextValue("GUI_highlight_4outsideArrow_left","Texture/kidui/common/highlight_4out_left.png");
Config.SetTextValue("GUI_highlight_4outsideArrow_top","Texture/kidui/common/highlight_4out_top.png");
Config.SetTextValue("GUI_highlight_4outsideArrow_right","Texture/kidui/common/highlight_4out_right.png");
Config.SetTextValue("GUI_highlight_4outsideArrow_bottom","Texture/kidui/common/highlight_4out_bottom.png");
Config.SetDoubleValue("GUI_highlight_4outsideArrow_speed",0.75);
Config.SetIntValue("GUI_highlight_4outsideArrow_range",20);
Config.SetIntValue("GUI_highlight_4outsideArrow_size",64);
----------------------------------------------------------------------------------------
--NstageAnimation effect
----------------------------------------------------------------------------------------
Config.SetTextValue("GUI_highlight_NstageAnimation_stage0","Texture/kidui/common/highlight_4out_left.png");
Config.SetTextValue("GUI_highlight_NstageAnimation_stage1","Texture/kidui/common/highlight_4out_top.png");
Config.SetDoubleValue("GUI_highlight_NstageAnimation_speed",0.5);
Config.SetIntValue("GUI_highlight_NstageAnimation_size",2);
