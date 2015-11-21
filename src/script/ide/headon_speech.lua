--[[
Title: displaying head on speech on character
Author(s): LiXizhi
Date: 2006/9/5
Desc: global AI related functions.
Use Lib: For displaying head on speech on character, 
-------------------------------------------------------
NPL.load("(gl)script/ide/headon_speech.lua");
headon_speech.Speek("<player>", "Hello World", 5);
-- mcml content is also supported.
headon_speech.Speek("<player>", "<img style=\"margin-bottom:10px;width:128px;height:128px;background:Texture/Aries/Temp/Quest4.png;\" />", 5);

headon_speech.ChangeHeadMark("girlPC", "arrow");
headon_speech.ChangeHeadMark("girlPC", "quest");
headon_speech.ChangeHeadMark("girlPC", "claim");
headon_speech.ChangeHeadMark("girlPC", ""); -- clear any mark
headon_speech.ChangeHeadMark(nil, "summon"); -- current player
-------------------------------------------------------
]]

local ParaScene_GetObject = ParaScene.GetObject;
local LOG = LOG;
local type = type;
local bLog = false;
local asset_mapping = {
	["arrow"] = "character/common/headarrow/headarrow.x",
	["quest"] = "character/common/headquest/headquest.x",
	["claim"] = "character/common/headexclaimed/headexclaimed.x",
	["summon"] = "character/particles/ring.x",
	["ring_head"] = "character/particles/ring_head.x",
	["tag"] = "character/common/tag/tag.x",
	["aries_walk_point"] = "character/common/walk_point/walk_point.x",
	["aries_walk_point_teen"] = "character/common/walk_point/walk_point_teen.x",
}

-- a mapping from ID to name, so that we can prevent text to be attached twice to the same 3D object. 
local IDNameMap = {};
-- id and their last use time
local IDUsedTime = {};

local headon_speech = commonlib.createtable("headon_speech", {
	-- how many concurrent speech dialog can be displayed in the screen.
	MaxConcurrentSpeech = 10,
	-- the next blank ID. 
	nNextID = 1,
	-- ParaAssets, such as ParaX models which are attached to the head of the character.
	Assets={},
	-- max display distance square, if the player position and the camera eye position is greater than it, text is not displayed.
	MaxDisplayDistSQ = 60*60,
	-- speech log, it is an array of table {charName="", text = ""}
	log = {},
	-- maximum number of speech log, that is kept in memory.
	MaxLogSize = 20,
	-- whether we will prolong the headon text life time, when mouse is over it. 
	ProlongLifeTimeWhenMouseOver = false,
	-- next blank log index
	NextBlankLogIndex = 1,
	
	-- dialog background
	dialog_bg = "Texture/Aries/HeadOn/head_speak_bg_32bits.png;0 0 128 62:24 20 64 41",
	
	-- max width of the dialog. if text is long, it will wrap. 
	max_width = 200,
	-- min width of the dialog. if text is few, it will enlarge. 
	min_width = 80,
	-- max height
	max_height = 200,
	-- one line text height. 
	min_height = 20,
	padding = 10,
	padding_bottom = 32,
	-- default text font,
	default_font = "System;12;", 
	-- font color
	text_color = "79 125 187",
	-- pixel distance from dialog image to head of character
	margin_bottom = 0,
});

function headon_speech.AddLog(charName, text)
	local item = headon_speech.log[headon_speech.NextBlankLogIndex];
	if(not item) then
		item = {};
		headon_speech.log[headon_speech.NextBlankLogIndex] = item;
	end
	item.charName = charName;
	item.text = text;
	headon_speech.NextBlankLogIndex = math.mod(headon_speech.NextBlankLogIndex,  headon_speech.MaxLogSize)+1;
end

-- return the last spoken text of a given character, it may return nil,if the character does not speak anything.
-- it will search in all logged text
function headon_speech.GetLastSpeechOfChar(charName)
	local i, nIndex;
	for i=1,headon_speech.MaxLogSize-1 do
		nIndex = headon_speech.NextBlankLogIndex-i;
		if(nIndex<=0) then
			nIndex = nIndex + headon_speech.MaxLogSize;
		end
		local item = headon_speech.log[nIndex];
		if(not item) then return end
		if(item.charName == charName) then
			return item.text;
		end
	end
end

function headon_speech.DumpLogToFile()
	-- TODO
end

local lifetime_timer;
local monitored_items = {};
local function MonitorUILifeTime(uiobject, lifetime, ProlongLifeTimeWhenMouseOver)
	if(not uiobject or not lifetime or lifetime<=0) then 
		return 
	end
	local id = uiobject.id;
	monitored_items[id] = {start_time = commonlib.TimerManager.GetCurrentTime(), lifetime = lifetime, is_mouseover_reset = ProlongLifeTimeWhenMouseOver}
	
	if(not lifetime_timer) then
		lifetime_timer = commonlib.Timer:new({callbackFunc = function()
			local remove_map;
			local cur_time = commonlib.TimerManager.GetCurrentTime()
			local x, y;
			local id, item
			for id, item in pairs(monitored_items) do
				local ui_obj = ParaUI.GetUIObject(id)
				if(ui_obj:IsValid()) then
					if(item.is_mouseover_reset) then
						if(not x) then
							x, y = ParaUI.GetMousePosition();
						end
						local left, top, width, height = ui_obj:GetAbsPosition();
						if(left<x and  x<(left+width) and top<y and y<(top+height)) then
							time.start_time = cur_time;
							ui_obj.lifetime = item.lifetime;
						end
					end
					if((cur_time > (item.lifetime*1000 + item.start_time))) then
						remove_map = remove_map or {}
						remove_map[#remove_map+1] = id;
						ParaUI.Destroy(id);
					end
				else
					remove_map = remove_map or {}
					remove_map[#remove_map+1] = id;
				end
			end
			if(remove_map) then
				local _, id
				for _, id in ipairs(remove_map) do
					monitored_items[id] = nil;
				end
			end
		end})
		lifetime_timer:Change(300, 300)
	else
		lifetime_timer:Enable();
	end
end


--[[ display a simple 3D text on the head of a given character for a given seconds. 
@param charName: character name or the object itself, to which the text is attached.it first searches the global object, if not found, it will search the OPC list.  
@param text: the text to be displayed on the head of the character. if nil, displays nothing. if it is pure text, it will displayed using centered text control
or it may contains any static MCML tags, in which case it will be rendered as interactive mcml elements. such as "<a>href links</a>"
@param nLifeTime: number of seconds the text maintains on the head of the character. if -1, it will be permanent. if 0 and text is "", it will remove head on text. 
@param bAbove3D: default to nil, if true, headon UI will be displayed above all 3D objects. if false or nil, it just renders the UI with z buffer test enabled. 
@param bHideBG: if true, it will hide background image. default to nil. 
@param bNoneOverwrite: default to nil. if true, it will not overwrite the previous UI object attached to the same charName.  This is only valid when nLifeTime is specified and larger than 0.
@param zorder: default to -1
@param bg_color: default to nil. which is the original color. it can also be "#ffffff80", etc. 
@return: the headon display ui control name, sCtrlName
]]
function headon_speech.Speak(charName, text, nLifeTime, bAbove3D, bHideBG, bNoneOverwrite, zorder, bg_color, margin_bottom)
	if(text == nil) then
		return;
	end
	local obj;
	if(type(charName) == "userdata") then
		obj = charName;
		charName = tostring(obj.id);
	else
		obj = ParaScene_GetObject(charName);
	end
	if(not obj:IsValid())then
		LOG.warn("%s does not exist when calling headon_speech.Speek", charName);
		return
	end
	
	local _this, _parent, i, nForceID;

	-- add to log
	if(bLog)then
		headon_speech.AddLog(charName, text);
	end	

	
	-- check distance	
	if(obj:DistanceToCameraSq() > headon_speech.MaxDisplayDistSQ) then 
		return
	end
	if(bNoneOverwrite) then
		 if(not nLifeTime or nLifeTime<=0) then	
			bNoneOverwrite = nil;
		 end
	end
	if(not bNoneOverwrite) then
		-- we will force using an existing ID, if the charName has been attached before.
		for i = 1, headon_speech.MaxConcurrentSpeech do 
			if(IDNameMap[i] == charName) then
				nForceID = i;
				break;
			end
		end
	end
	local sCtrlName = headon_speech.GetNextSpeechGUIName(nForceID);
	if(not bNoneOverwrite) then
		if(nForceID==nil) then
			IDNameMap[headon_speech.nNextID] = charName;
		end
	end
	
	local width, height;
	-- always destroy the control, if the background and padding are reset
	ParaUI.Destroy(sCtrlName);
	
	if(not string.match(text, "<.+>") or not Map3DSystem and Map3DSystem.mcml_controls) then
		local textWidth = _guihelper.GetTextWidth(text, headon_speech.default_font)+6;
		if(textWidth>headon_speech.max_width) then
			width = headon_speech.max_width
			height = headon_speech.min_height + (math.ceil(textWidth/headon_speech.max_width)-1)*16;
			
			if(height > headon_speech.max_height) then
				height = headon_speech.max_height;
			end
		else
			width = math.max(headon_speech.min_width, textWidth);
			height = headon_speech.min_height
		end
		width = width + headon_speech.padding*2
		height = height + headon_speech.padding + headon_speech.padding_bottom
	
		-- create the control if not exists
		_parent=ParaUI.CreateUIObject("container",sCtrlName,"_lt",-width/2,-height-headon_speech.margin_bottom,width, height);
		if(not bHideBG) then
			_parent.background=headon_speech.dialog_bg;
			if(bg_color) then
				_guihelper.SetUIColor(_parent, bg_color)
			end
		else	
			_parent.background = "";
		end	
		_parent.zorder = zorder or -1;
		
		_this=ParaUI.CreateUIObject("button","text","_fi",headon_speech.padding,headon_speech.padding,headon_speech.padding, headon_speech.padding_bottom);
		_this.text = text;
		_this.font=headon_speech.default_font;
		_this:GetFont("text").color = headon_speech.text_color;
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 21) -- centered and with word break
		_parent:AddChild(_this);
		
		_parent.lifetime = nLifeTime;
		MonitorUILifeTime(_parent, nLifeTime, headon_speech.ProlongLifeTimeWhenMouseOver);

		if(bAbove3D) then
			_parent.zdepth = 0;
		end
		_parent:AttachTo3D(obj);
		
		-- disable parent for performance. 
		_parent.enabled = false; 
	else
		-- text = "<img style=\"margin-bottom:10px;width:128px;height:128px;background:Texture/Aries/Temp/Quest4.png;\" />";
		-- text = [[<div style="margin-bottom:10px;width:128px;height:64px;color:#00FF00;background:url(Texture/Aries/Temp/Quest4.png)" >hello</div>]]
		-- text = [[this is ok. <input name="asd" value="Hello World">]]
		text = "<p>"..text.."</p>";
		--text = ParaMisc.EncodingConvert("", "HTML", text);
		local xmlRoot = ParaXML.LuaXML_ParseString(text);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
			local mcmlNode = xmlRoot[1];
			if(mcmlNode) then
				_this = ParaUI.CreateUIObject("container", "mcml", "_fi", headon_speech.padding, headon_speech.padding, headon_speech.padding, headon_speech.padding_bottom);
				--_this.background = "Texture/alphadot.png";
				_this.background = "";

				local myLayout = Map3DSystem.mcml_controls.layout:new();
				myLayout:reset(0, 0, 200, 200);
				Map3DSystem.mcml_controls.create(sCtrlName.."headonspeach", mcmlNode, nil, _this, 0, 0, 1000, headon_speech.max_height, nil, myLayout);

				-- repostion the head on text with the used MCML layout space
				local usedWidth, usedHeight = myLayout:GetUsedSize();

				width = math.max(headon_speech.min_width, usedWidth);
				height = math.max(headon_speech.min_height, usedHeight);
				
				width = width + headon_speech.padding * 2;
				height = height + headon_speech.padding + headon_speech.padding_bottom;

				local _parent =ParaUI.CreateUIObject("container",sCtrlName,"_lt",-width/2,-height - (margin_bottom or headon_speech.margin_bottom),width, height);
				if(not bHideBG) then
					_parent.background=headon_speech.dialog_bg;
					if(bg_color) then
						_guihelper.SetUIColor(_parent, bg_color)
					end
				else
					_parent.background = "";
				end	
				_parent.zorder = zorder or -1;
				_parent.lifetime = nLifeTime;
				MonitorUILifeTime(_parent, nLifeTime, headon_speech.ProlongLifeTimeWhenMouseOver);
				if(bAbove3D) then
					_parent.zdepth = 0;
				end
				_parent:AttachTo3D(obj);
				_parent:AddChild(_this);

				-- enable parent since it may contain interactive content. 
				-- _parent.enabled = true; 
			end
		else
			LOG.std(nil, "warn", "headon_speech", "invalid mcml text %s", text);
		end
	end
	return sCtrlName;
end
headon_speech.Speek = headon_speech.Speak;

-- get the bold text MCML string
--@param text: plain text to show
-- e.x.: headon_speech.Speek(policeDog.name, headon_speech.GetBoldTextMCML("汪汪，汪汪"), 3);
function headon_speech.GetBoldTextMCML(text)
	if(type(text) == "string") then
		return "<div style=\"font-weight:bold;\">"..text.."</div>";
	end
end

-- if mouse cursor is over the control, we will prolong the life time 5 seconds each time. 
function headon_speech.OnDialogBoxFrameMove(sCtrlName)
	local _parent = ParaUI.GetUIObject(sCtrlName);
	if(_parent:IsValid() and _parent.visible) then
		if(_parent.lifetime>1 and _parent.lifetime<=5) then
			local x, y = ParaUI.GetMousePosition();
			local left, top, width, height = _parent:GetAbsPosition();
			if(left<x and  x<(left+width) and top<y and y<(top+height)) then
				_parent.lifetime = 5;
			end
		end
	end
end

local last_time = 1;
-- [private]get next free speech GUI name, auto increase the ID. 
-- @param nid: if nil, headon_speech.nNextID is used.
function headon_speech.GetNextSpeechGUIName(nid)
	last_time = last_time + 1;
	if(nid == nil) then
		local min_time = last_time - headon_speech.MaxConcurrentSpeech + 1;

		for i=1, headon_speech.MaxConcurrentSpeech do
			headon_speech.nNextID = headon_speech.nNextID + 1;
			if(headon_speech.nNextID>headon_speech.MaxConcurrentSpeech) then
				headon_speech.nNextID = 1;
			end
			if(not IDUsedTime[headon_speech.nNextID] or IDUsedTime[headon_speech.nNextID] <= min_time ) then
				break;
			end
		end
		nid = headon_speech.nNextID;
	end
	IDUsedTime[nid] = last_time;
	return "headon_speech"..nid;
end

-- automatically called when script is loaded. However, if the application restarts, remember to call before using the ChangeHeadMark() functions.
function headon_speech.GetAsset(key)
	local asset = headon_speech.Assets[key];
	if(asset == nil) then
		if(asset_mapping[key]) then
			asset = ParaAsset.LoadParaX("", asset_mapping[key])
			headon_speech.Assets[key] = asset;
		else
			commonlib.log("warning: headon_speech asset %s not found \n", tostring(key))
		end	
	end	
	return asset;
end

--[[
change the models which are displayed on the head of the given character
@param charName: If nil or "", it is current player. the character on whose head the model is attached.it first searches the global object, if not found, it will search the OPC list.  
@param markName: the mark name, such as "arrow", "quest", "claim", "summon". It should be a field in headon_speech.Assets.
	if this is nil or "", the mark is removed from the head of the character.
]]
function headon_speech.ChangeHeadMark(charName, markName)
	local player;
	if(charName ==nil or charName =="") then
		player = ParaScene.GetPlayer();
	else
		player = ParaScene.GetCharacter(charName);
	end
	
	if(player:IsValid()==true)then
		player:ToCharacter():RemoveAttachment(11);
		if(markName~=nil and markName~="") then
			local asset = headon_speech.GetAsset(markName);
			if(asset~=nil and asset:IsValid()==true) then
				player:ToCharacter():AddAttachment(asset, 11);
			end
		end
	end
end

-- the only difference with headon_speech.Speek is that the UI is persistent
function headon_speech.ChangeHeadUITemplate(obj, text, nLifeTime, bAbove3D, bHideBG)
	if(text == nil) then
		return;
	end
	
	if(type(obj) == "string") then
		obj = ParaScene_GetObject(obj);
	end
	if(not obj:IsValid())then
		LOG.warn("obj does not exist when calling headon_speech.ChangeHeadUITemplate");
		return
	end
	local charName = obj.name;
	
	local _this, _parent, i, nForceID;
	
	-- check distance	
	if(obj:DistanceToCameraSq() > headon_speech.MaxDisplayDistSQ) then 
		return
	end

	-- we will force using an existing ID, if the charName has been attached before.
	for i = 1, headon_speech.MaxConcurrentSpeech do 
		if(IDNameMap[i] == charName) then
			nForceID = i;
			break;
		end
	end
	local sCtrlName = headon_speech.GetNextSpeechGUIName(nForceID);
	if(nForceID==nil) then
		IDNameMap[headon_speech.nNextID] = charName;
	end
	
	local width, height;
	-- always destroy the control, if the background and padding are reset
	ParaUI.Destroy(sCtrlName);
	
	nLifeTime = nLifeTime or 4;
	if(not string.match(text, "<.+>") or not Map3DSystem and Map3DSystem.mcml_controls) then
		local textWidth = _guihelper.GetTextWidth(text, headon_speech.default_font)+6;
		if(textWidth>headon_speech.max_width) then
			width = headon_speech.max_width
			height = headon_speech.min_height + (math.ceil(textWidth/headon_speech.max_width)-1)*16;
			
			if(height > headon_speech.max_height) then
				height = headon_speech.max_height;
			end
		else
			width = math.max(headon_speech.min_width, textWidth);
			height = headon_speech.min_height
		end
		width = width + headon_speech.padding*2
		height = height + headon_speech.padding + headon_speech.padding_bottom
	
		-- create the control if not exists
		_parent=ParaUI.CreateUIObject("container",sCtrlName,"_lt",-width/2,-height-headon_speech.margin_bottom,width, height);
		if(not bHideBG) then
			_parent.background=headon_speech.dialog_bg;
		else	
			_parent.background = "";
		end	
		
		_parent.zorder = -1;
		
		_this=ParaUI.CreateUIObject("button","text","_fi",headon_speech.padding,headon_speech.padding,headon_speech.padding, headon_speech.padding_bottom);
		_this.text = text;
		_this.font=headon_speech.default_font;
		_this:GetFont("text").color = headon_speech.text_color;
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 21) -- centered and with word break
		_parent:AddChild(_this);
		
		_parent.lifetime = nLifeTime;
		MonitorUILifeTime(_parent, nLifeTime, headon_speech.ProlongLifeTimeWhenMouseOver);
		if(bAbove3D) then
			_parent.zdepth = 0;
		end
		_parent:AttachTo3D(obj);
		
		-- disable parent for performance. 
		_parent.enabled = false; 
	else
		-- text = "<img style=\"margin-bottom:10px;width:128px;height:128px;background:Texture/Aries/Temp/Quest4.png;\" />";
		-- text = [[<div style="margin-bottom:10px;width:128px;height:64px;color:#00FF00;background:url(Texture/Aries/Temp/Quest4.png)" >hello</div>]]
		-- text = [[this is ok. <input name="asd" value="Hello World">]]
		text = "<p>"..text.."</p>";
		--text = ParaMisc.EncodingConvert("", "HTML", text);
		local xmlRoot = ParaXML.LuaXML_ParseString(text);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
			local mcmlNode = xmlRoot[1];
			if(mcmlNode) then
				height, width = headon_speech.max_width, headon_speech.max_height;
				
				_this = ParaUI.CreateUIObject("container", "mcml", "_fi", headon_speech.padding, headon_speech.padding, headon_speech.padding, headon_speech.padding_bottom);
				--_this.background = "Texture/alphadot.png";
				_this.background = "";

				local myLayout = Map3DSystem.mcml_controls.layout:new();
				myLayout:reset(0, 0, 200, 200);
				Map3DSystem.mcml_controls.create(sCtrlName.."headonspeach", mcmlNode, nil, _this, 0, 0, 1000, height, nil, myLayout);

				-- repostion the head on text with the used MCML layout space
				local usedWidth, usedHeight = myLayout:GetUsedSize();

				width = math.max(headon_speech.min_width, usedWidth);
				height = math.max(headon_speech.min_height, usedHeight);
				
				width = width + headon_speech.padding * 2;
				height = height + headon_speech.padding + headon_speech.padding_bottom;

				local _parent =ParaUI.CreateUIObject("container",sCtrlName,"_lt",-width/2,-height-headon_speech.margin_bottom,width, height);
				if(not bHideBG) then
					_parent.background=headon_speech.dialog_bg;
				else
					_parent.background = "";
				end	
				_parent.zorder = -1;
				_parent.lifetime = nLifeTime;
				MonitorUILifeTime(_parent, nLifeTime, headon_speech.ProlongLifeTimeWhenMouseOver);
				if(bAbove3D) then
					_parent.zdepth = 0;
				end
				_parent:AttachTo3D(obj);
				_parent:AddChild(_this);

				-- enable parent since it may contain interactive content. 
				-- _parent.enabled = true; 
			end
		end
	end
	return sCtrlName;
end
