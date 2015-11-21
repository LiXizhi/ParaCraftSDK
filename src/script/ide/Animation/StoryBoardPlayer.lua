--[[
Title: StoryBoardPlayer
Author(s): Leio Zhang
Date: 2008/8/19
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/StoryBoardPlayer.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/PreLoader.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTracks.lua");
local StoryBoardPlayer = {
	name = "StoryBoardPlayer_instance",
	mcmlTitle = "pe:storyboards",
	curStoryBoard = nil,
	-- the index of current playing's storyboard 
	curIndex = 1,
	repeatCount = 1,
	dataList = {},
}
commonlib.setfield("CommonCtrl.Animation.StoryBoardPlayer",StoryBoardPlayer);
function StoryBoardPlayer:new(filename)
	local o = {
		filename = filename,
		mcmlTitle = "pe:storyboards",
		dataList = {},
		curIndex = 1,
		repeatCount = 1,
		name = ParaGlobal.GenerateUniqueID(),
	}
	setmetatable(o, self)
	self.__index = self;
	if(filename)then
		o:Load(filename);
	end
	return o
end
--event
function StoryBoardPlayer.OnMotionStop(self,time)
	
end	
function StoryBoardPlayer.OnMotionEnd(self,time)
	
end	
function StoryBoardPlayer.OnMotionStart(self,time)

end	

function StoryBoardPlayer.OnTimeChange(self,time)

end	
function StoryBoardPlayer.OnMotionRewind(self)
	
end	
function StoryBoardPlayer.OnMotionPause(self)

end	
function StoryBoardPlayer.OnMotionResume(self)

end
--event
function StoryBoardPlayer.__OnMotionStop(sControl,time)
	local storyboard = sControl;
	local storyBoardPlayer = storyboard.storyBoardPlayer;
	if(storyBoardPlayer)then
		local frame = storyBoardPlayer:getCurFrame(time)
			storyBoardPlayer.OnMotionStop(storyBoardPlayer,frame)
	end
end	
function StoryBoardPlayer.__OnMotionEnd(sControl,time)
	local storyboard = sControl;
	local storyBoardPlayer = storyboard.storyBoardPlayer;
	if(storyBoardPlayer)then
		local frame = storyBoardPlayer:getCurFrame(time)
		storyBoardPlayer.curIndex = storyBoardPlayer.curIndex + 1;
		local really = storyBoardPlayer:isReallyOnEnd()
		if(really)then			
			storyBoardPlayer.OnMotionEnd(storyBoardPlayer,frame)
		else
			-- play next storyboard;
			local engine = storyBoardPlayer:getCurStoryBoard();
			if(not engine) then return ;end
			engine:doPlay();
		end
	end
end	
function StoryBoardPlayer.__OnMotionStart(sControl,time)
	local storyboard = sControl;
	local storyBoardPlayer = storyboard.storyBoardPlayer;
	if(storyBoardPlayer)then
		local frame = storyBoardPlayer:getCurFrame(time)
		if(storyBoardPlayer.curIndex == 1)then
			storyBoardPlayer.OnMotionStart(storyBoardPlayer,frame)
		end
	end
end	

function StoryBoardPlayer.__OnTimeChange(sControl,time)
	local storyboard = sControl;
	local storyBoardPlayer = storyboard.storyBoardPlayer;
	if(storyBoardPlayer)then
		local frame = storyBoardPlayer:getCurFrame(time)
		storyBoardPlayer.OnTimeChange(storyBoardPlayer,frame)
	end
end	
--function StoryBoardPlayer.__OnMotionRewind(sControl)
	--local storyboard = sControl;
	--local storyBoardPlayer = storyboard.storyBoardPlayer;
	--if(storyBoardPlayer)then
		--local frame = storyBoardPlayer:getCurFrame(time)
		--storyBoardPlayer.OnMotionRewind(storyBoardPlayer)
	--end
--end	
function StoryBoardPlayer.__OnMotionPause(sControl)
	local storyboard = sControl;
	local storyBoardPlayer = storyboard.storyBoardPlayer;
	if(storyBoardPlayer)then
		storyBoardPlayer.OnMotionPause(storyBoardPlayer)
	end
end	
function StoryBoardPlayer.__OnMotionResume(sControl)
	local storyboard = sControl;
	local storyBoardPlayer = storyboard.storyBoardPlayer;
	if(storyBoardPlayer)then
		storyBoardPlayer.OnMotionResume(storyBoardPlayer)
	end
end	
function StoryBoardPlayer.OnFail(engine)
	if(engine)then
		--log("warning: StoryBoardPlayer:"..engine.name.." is closed\n");
		engine:Destroy()
	end
end	
-- get a storyboard
function StoryBoardPlayer:getCurStoryBoard(index)
	if(self.curStoryBoard)then
		-- only pause current storyboard but not send event
		self.curStoryBoard:_doPause();
	end
	if(index)then
		self.curIndex = index;
	end
	local storyboard = self.dataList[self.curIndex];
	self.curStoryBoard = storyboard;
	return storyboard;
end
function StoryBoardPlayer:getCurStoryBoardByFrame(frame)
	if(not frame)then return; end
	for k,v in ipairs(self.dataList) do
		local animatorManager = v.animatorManager;
		if(animatorManager)then
			local len = animatorManager:GetFrameLength();
			frame = frame - len;
			if(frame <=0)then
				return self:getCurStoryBoard(k),(len+frame)
			end
		end
	end
end
-- add a storyboard
function StoryBoardPlayer:addStoryBoard(storyboard)
	if(not storyboard)then return end
	storyboard.OnMotionStop = self.__OnMotionStop;
	storyboard.OnMotionEnd = self.__OnMotionEnd;
	storyboard.OnMotionStart = self.__OnMotionStart;
	storyboard.OnTimeChange = self.__OnTimeChange;
	storyboard.OnMotionRewind = self.__OnMotionRewind;
	storyboard.OnMotionPause = self.__OnMotionPause;
	storyboard.OnMotionResume = self.__OnMotionResume;
	storyboard.storyBoardPlayer = self;
	table.insert(self.dataList,storyboard);
end
function StoryBoardPlayer:removeStoryBoard(storyboard)
	local k,v;
	if(not storyboard)then
		self.dataList = {};
	end
	for k,v in ipairs(self.dataList) do
		if(v==storyboard)then
			table.remove(self.dataList,k);
			break;
		end
	end
end
-- retudrn the length of all storyboard
function StoryBoardPlayer:getTotalFrame()
	local frames = 0;
	local k,v;
	for k,v in ipairs(self.dataList) do
		local animatorManager = v.animatorManager;
		if(animatorManager)then
			local len = animatorManager:GetFrameLength();
			frames = frames + len;
		end
	end
	return frames;
end
function StoryBoardPlayer:isPlaying()
	local engine = self:getCurStoryBoard();
	if(not engine) then return ;end
	return engine:isPlaying();
end
-- get current frame
function StoryBoardPlayer:getCurFrame(time)
	if(not time)then 
		local cur = self:getCurStoryBoard();	
		if(cur)then
			time = cur:GetTime(); 
		else
			time = 0;
		end
	end
	local frames = 0;
	local k;
	for k = 1,self.curIndex - 1 do
		local v = self.dataList[k];
		local animatorManager = v.animatorManager;
		if(animatorManager)then
			local len = animatorManager:GetFrameLength();
			frames = frames + len;
		end
	end
	frames = frames + time;
	return frames;
end
function StoryBoardPlayer:isReallyOnEnd()
	if(self.curIndex > table.getn(self.dataList))then
		return true;
	else
		return false;
	end
end
-- play from beginning
function StoryBoardPlayer:doPlay()
	self:pauseCurStoryboard()
	local engine = self:getCurStoryBoard(1);
	if(not engine) then return ;end
	engine:doPlay();
end
-- pause group 
function StoryBoardPlayer:doPause()
	local engine = self:getCurStoryBoard();
	if(not engine) then return ;end
	engine:doPause();
end
-- inherent pause group 
function StoryBoardPlayer:_doPause()
	local engine = self:getCurStoryBoard();
	if(not engine) then return ;end
	engine:_doPause();
end
-- resume group 
function StoryBoardPlayer:doResume()
	local engine = self:getCurStoryBoard();
	if(not engine) then return ;end
	engine:doResume();
end
-- stop group 
function StoryBoardPlayer:doStop()
	self:pauseCurStoryboard()
	local engine = self:getCurStoryBoard(1);
	if(not engine) then return ;end
	engine:doStop();
	self:resetAllStoryboardTime("stop")
end
-- end group 
function StoryBoardPlayer:doEnd()
	self:pauseCurStoryboard()
	local len = table.getn(self.dataList);
	local engine = self:getCurStoryBoard(len);
	if(not engine) then return ;end
	engine:doEnd();	
	self:resetAllStoryboardTime("end")
end

function StoryBoardPlayer:pauseCurStoryboard()
	local engine = self:getCurStoryBoard();
	if(not engine) then return ;end
	engine:_doPause();
end
-- gotoAndPlay
function StoryBoardPlayer:gotoAndPlay(frame)	
	local engine,curframe = self:getCurStoryBoardByFrame(frame);
	if(not engine) then return ;end
	engine:gotoAndPlay(curframe);
end
-- speedPreTime
-- @param steptime: "00:00:01"
function StoryBoardPlayer:speedPreTime(steptime)	
	local engine = self:_speedPreTime(steptime)
	if(not engine) then return ;end
	engine:speedPreTime(steptime);
end
-- speedNextTime
-- @param steptime: "00:00:01"
function StoryBoardPlayer:speedNextTime(steptime)
	local engine = self:_speedNextTime(steptime);	
	if(not engine) then return ;end
	engine:speedNextTime(steptime);
end

-- speedPreFrame
-- @param stepframe: 1
function StoryBoardPlayer:speedPreFrame(stepframe)
	local engine = self:_speedPreFrame(stepframe)
	if(not engine) then return ;end
	engine:speedPreFrame(stepframe);
end
-- speedNextFrame
-- @param stepframe: 1
function StoryBoardPlayer:speedNextFrame(stepframe)
	local engine = self:_speedNextFrame(stepframe)
	if(not engine) then return ;end
	engine:speedNextFrame(stepframe);
end
-- gotoAndStopPreFrame
function StoryBoardPlayer:gotoAndStopPreFrame()
	local engine = self:_speedPreFrame()
	if(not engine) then return ;end
	engine:gotoAndStopPreFrame();
end
-- gotoAndStopNextFrame
function StoryBoardPlayer:gotoAndStopNextFrame()
	local engine = self:_speedNextFrame()
	if(not engine) then return ;end
	engine:gotoAndStopNextFrame();
end
-- gotoAndStopPreTime
function StoryBoardPlayer:gotoAndStopPreTime()
	local engine = self:_speedPreTime();
	if(not engine) then return ;end
	engine:gotoAndStopPreTime();
end
-- gotoAndStopNextTime
function StoryBoardPlayer:gotoAndStopNextTime()
	local engine = self:_speedNextTime();
	if(not engine) then return ;end
	engine:gotoAndStopNextTime();
end
function StoryBoardPlayer:_speedPreFrame(stepframe)
	if(not stepframe)then stepframe = 1; end
	local curFrames = self:getCurFrame();
	curFrames = curFrames - stepframe;
	local engine = self:getCurStoryBoardByFrame(curFrames);
	return engine;
end
function StoryBoardPlayer:_speedNextFrame(stepframe)
	if(not stepframe)then stepframe = 1; end
	local curFrames = self:getCurFrame();
	curFrames = curFrames + stepframe;
	local engine = self:getCurStoryBoardByFrame(curFrames);
	return engine;
end
function StoryBoardPlayer:_speedPreTime(steptime)
	if(not steptime) then 
			steptime = "00:00:01";
	end
	local stepframe = CommonCtrl.Animation.TimeSpan.GetFrames(steptime);
	
	local engine = self:_speedPreFrame(stepframe)
	return engine;
end
function StoryBoardPlayer:_speedNextTime(steptime)
	if(not steptime) then 
			steptime = "00:00:01";
	end
	local stepframe = CommonCtrl.Animation.TimeSpan.GetFrames(steptime);
	
	local engine = self:_speedNextFrame(stepframe)
	return engine;
end

function StoryBoardPlayer:resetAllStoryboardTime(type)
	local k,len = 1,table.getn(self.dataList);
	for k = 1,len do
		local storyboard = self.dataList[k];
		if(type == "stop")then
		storyboard._time = 1;
		else
		storyboard._time = storyboard.totalFrame;
		end
	end
end
function StoryBoardPlayer:ReverseToMcml()
	local node_value = "";
	local k,storyboard;
	for k,storyboard in ipairs(self.dataList) do
		node_value = node_value..storyboard:ReverseToMcml();
	end
	local p_node = "\r\n";
	local str = string.format([[<%s name="%s" repeatCount = "%s" xmlns:pe="www.paraengine.com/pe">%s</%s>%s]],self.mcmlTitle,self.name,self.repeatCount,"\r\n"..node_value,self.mcmlTitle,p_node);
	str = ParaMisc.EncodingConvert("", "utf-8", str)
	return str;
end
function StoryBoardPlayer.LoadFromMovieScript(path)
end
-- load from a file
function StoryBoardPlayer:Load(filename)
	if(not filename == nil) then
		return;
	end
	self.filename = filename;
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	self:__DoParse(xmlRoot)
end
function StoryBoardPlayer:Parse(str)
	if(not str)then return; end
	local xmlRoot = ParaXML.LuaXML_ParseString(str);
	self:__DoParse(xmlRoot)
end
function StoryBoardPlayer:__DoParse(xmlRoot)
	self:removeStoryBoard();
	if(not xmlRoot)then return; end
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");		
		-- root: pe:storyboards
		local rootNode = nil;
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//pe:storyboards") do
			rootNode = node;
			break;
		end			
		if(rootNode) then
			local childnode;
			for childnode in rootNode:next() do
				local storyboard = Map3DSystem.Movie.mcml_controls.create(childnode);
				if(storyboard) then
					self:addStoryBoard(storyboard);
				end
			end
		else
			commonlib.log("warning: failed loading movie script %s, because the pe:storyboards node is not found\n", path);
		end
	end
end
function StoryBoardPlayer:SaveMotionFile()
	local outputpath = "test_StoryBoardPlayer.xml"
	local file = ParaIO.open(outputpath, "w");
	if(file ~= nil and file:IsValid()) then
		file:WriteString(self:ReverseToMcml())
	end
	file:close();
end