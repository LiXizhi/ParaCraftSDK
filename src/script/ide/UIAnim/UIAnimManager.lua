--[[
Title: UI Animation
Author(s): WangTian
Date: 2007/9/30
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
UIAnimManager.Init();
-------------------------------------------------------
]]
local format = format;
local type = type;
local pairs = pairs;
local UIAnimManager = commonlib.gettable("UIAnimManager");
local math_floor = math.floor;

local AllFiles = {};

local UIAnimationPool = {};

local UI_timer;
-- start the animation framework and start the timer
function UIAnimManager.Init()
	NPL.load("(gl)script/ide/timer.lua");
	UI_timer = UI_timer or commonlib.Timer:new({callbackFunc = UIAnimManager.DoAnimation});
	-- call every frame move
	UI_timer:Change(0, 1);
end

function UIAnimManager.AddFile(FileName, file)
	if(not AllFiles[FileName]) then
		AllFiles[FileName] = file;
		file.FileName = FileName;
	else
		log("warning: file :"..FileName.." already exists in animation manager.\r\n");
	end
end

function UIAnimManager.DeleteFile(FileName)
	local obj = AllFiles[FileName];
	if(obj ~= nil) then
		AllFiles[FileName] = nil;
	else
		log("error: file :"..FileName.." doesn't exist or not yet opened.\r\n");
	end
end

-- load the UI animation file
function UIAnimManager.LoadUIAnimationFile(fileName)
	local NewTable = commonlib.LoadTableFromFile(fileName);
	
	NPL.load("(gl)script/ide/UIAnim/UIAnimFile.lua");
	
	if(not NewTable) then
		log("error loading animation file: "..fileName.."\n");
		return nil;
	end

	local ctl = UIAnimFile:new(NewTable);
	UIAnimManager.AddFile(fileName, ctl);
	
	
	--Map3DSystem.Misc.SaveTableToFile(ctl, "TestTable/file.ini");

	return ctl;
end

---- play UI animation according to the filename and the animation ID and range ID
--function UIAnimManager.PlayUIAnimationSingle(obj, fileName, AnimID, RangeID)
	---- TODO: load the UI animation file
--end

-- play UI animation according to the filename and the sequence ID 
function UIAnimManager.PlayUIAnimationSequence(obj, fileName, ID, bLooping)
	if(obj == nil or obj:IsValid() == false) then
		return;
	end

	local file = AllFiles[fileName];
	if(file == nil) then
		log("warning: animation file is not yet opened: "..fileName.."\n");
		return;
	end
	local anim_seq = file.UIAnimSeq[ID];
	if(not anim_seq)  then
		LOG.std(nil, "warn", "UIAnimManager",  "warning: %s sub animation sequence not found in %s: ", tostring(ID), fileName);
		return;
	end

	local animationID = anim_seq.AnimationID;
	local seq = anim_seq.Seq;
	if(not UIAnimationPool) then
		UIAnimationPool = {};
	end
	
	local _objectNameString;
	_objectNameString = UIAnimManager.GetPathStringFromUIObject(obj)
	
	if(obj.type == "container") then
		local nCount = obj:GetChildCount();
		-- traverse all children in a container
		-- pay attention the GetChildAt function indexed in C++ form which begins at index 0
		for i = 0, nCount - 1 do
			local _ui = obj:GetChildAt(i);
			if(_ui.visible == true) then
				UIAnimManager.PlayUIAnimationSequence(_ui, fileName, ID, bLooping);
			end
		end
	end
	
	-- record the object name and parent
	local objIndex = _objectNameString;
	
	UIAnimationPool[objIndex] = UIAnimationPool[objIndex] or {};
	
	if(UIAnimationPool[objIndex].IsAnimating ~= true) then
		-- set up new animation
		UIAnimationPool[objIndex].File = file; -- e.g "Test_UIAnimFile.lua.table"
		UIAnimationPool[objIndex].Seq = ID; -- e.g "Bounce"
		
		UIAnimationPool[objIndex].currentSeqID = 1; -- "Bounce": 1
		UIAnimationPool[objIndex].animationID = animationID;
		UIAnimationPool[objIndex].isLooping = bLooping;
		UIAnimationPool[objIndex].nCurrentFrame = file.UIAnimation[animationID]:GetStartFrame(file.UIAnimSeq[ID].Seq[1]);
		UIAnimationPool[objIndex].nStartFrame = file.UIAnimation[animationID]:GetStartFrame(file.UIAnimSeq[ID].Seq[1]);
		UIAnimationPool[objIndex].nEndFrame = file.UIAnimation[animationID]:GetEndFrame(file.UIAnimSeq[ID].Seq[1]);
		
		UIAnimationPool[objIndex].IsAnimating = true;
		
		UIAnimationPool[objIndex].SetBackVisible = obj.visible;
		UIAnimationPool[objIndex].SetBackEnable = obj.enable;
		
		-- set the UI object visible during the animation and setback when finished
		obj.visible = true;
	else
		-- blending the animation to the new one
		
		--UIAnimationPool[objIndex].BlendingFactor = 1;
		----fileName, ID, bLooping
		--if(UIAnimationPool[objIndex].isLooping == true) then
			--if( UIAnimationPool[objIndex].File.FileName == fileName
					--and UIAnimationPool[objIndex].Seq == ID) then
				--UIAnimationPool[objIndex].isLooping = false;
			--end
		--end
	end
	
end

-- @param bForceStop: force the ui object animation to stop, unless the animation will be animated to endframe or blended with the next one
--						NOTE: if bForceStop is true, fileName and ID could be nil
function UIAnimManager.StopLoopingUIAnimationSequence(obj, fileName, ID, bForceStop)
	if(not obj or not obj:IsValid()) then
		return;
	end
	if(not UIAnimationPool) then
		UIAnimationPool = {};
	end
	
	local _objectNameString;
	_objectNameString = UIAnimManager.GetPathStringFromUIObject(obj)
	
	local objIndex = _objectNameString;
	
	UIAnimationPool[objIndex] = UIAnimationPool[objIndex] or {};
	
	if(bForceStop == true) then
		UIAnimationPool[objIndex] = nil;
		obj.translationx = 0;
		obj.translationy = 0;
		obj.scalingx = 1;
		obj.scalingy = 1;
		obj.rotation = 0;
		obj.color = "255 255 255 255";
		return;
	end
	
	local file = AllFiles[fileName];
	if(file == nil) then
		log("warning: animation file is not yet opened: "..fileName.."\n");
		return;
	end
	local animationID = file.UIAnimSeq[ID].AnimationID;
	local seq = file.UIAnimSeq[ID].Seq;
	
	if(UIAnimationPool[objIndex].IsAnimating ~= true) then
		-- the ui object is not yet animating
	else
		-- NOTE: directly stop the ui animation in the stop function
		--		original version only set the isLooping to false and wait until the next DoAnimation call to stop animation
		-- stop the animating ui object
		if(UIAnimationPool[objIndex].isLooping == true) then
			if( UIAnimationPool[objIndex].File.FileName == fileName and UIAnimationPool[objIndex].Seq == ID) then
				UIAnimationPool[objIndex].IsAnimating = false;
				UIAnimationPool[objIndex].isLooping = false;
				local v = UIAnimationPool[objIndex];
				v.nCurrentFrame = v.nEndFrame;
				local _uiObject = UIAnimManager.GetUIObjectFromPathString(objIndex);
				_uiObject.visible = v.SetBackVisible;
				_uiObject.enable = v.SetBackEnable;
				
				local animID = file.UIAnimSeq[v.Seq].Seq[v.currentSeqID];
				local _TX = file.UIAnimation[v.animationID]:GetTranslationXValue(animID, v.nCurrentFrame);
				local _TY = file.UIAnimation[v.animationID]:GetTranslationYValue(animID, v.nCurrentFrame);
				local _SX = file.UIAnimation[v.animationID]:GetScalingXValue(animID, v.nCurrentFrame);
				local _SY = file.UIAnimation[v.animationID]:GetScalingYValue(animID, v.nCurrentFrame);
				local _R = file.UIAnimation[v.animationID]:GetRotationValue(animID, v.nCurrentFrame);
				local _A = file.UIAnimation[v.animationID]:GetAlphaValue(animID, v.nCurrentFrame);
				local _CR = file.UIAnimation[v.animationID]:GetColorRValue(animID, v.nCurrentFrame);
				local _CG = file.UIAnimation[v.animationID]:GetColorGValue(animID, v.nCurrentFrame);
				local _CB = file.UIAnimation[v.animationID]:GetColorBValue(animID, v.nCurrentFrame);
				
				_uiObject.translationx = _TX;
				_uiObject.translationy = _TY;
				_uiObject.scalingx = _SX;
				_uiObject.scalingy = _SY;
				
				_uiObject.rotation = _R;
				_uiObject.color = string.format("%d %d %d %d", _CR, _CG, _CB, _A);
			end
		end
	end
end

-- get the ui object from object path string
-- path string format: [@index][@index]..
-- @param path: object path string
-- @return nil if not found
function UIAnimManager.GetUIObjectFromPathString(path)
	if(type(path) == "string") then
		path = tonumber(path);
	end
	if(path) then
		local obj = ParaUI.GetUIObject(path);
		if(obj:IsValid()) then
			return obj;
		end
	end	
end

-- get the object path string from the ui object
-- path string format: [name@][name@]..
-- @param obj: ui object
-- @return nil if not found
function UIAnimManager.GetPathStringFromUIObject(obj)
	if(obj and obj:IsValid()) then
		return obj.id;
	end	
end

-- animate the ui objects in the UIAnimationPool
function UIAnimManager.DoAnimation(timer)
	local dTimeDelta = timer.delta;
	
	-- animate the ui object in the direct animation pool
	UIAnimManager.DoDirectAnimation(dTimeDelta);
	
	-- animation in custom animation pool
	UIAnimManager.DoCustomAnimation(dTimeDelta);
	
	local k, v;
	if(not UIAnimationPool) then
		UIAnimationPool = {};
	end
	local delete_pool;
	for k, v in pairs(UIAnimationPool) do
			
		local _uiObject = UIAnimManager.GetUIObjectFromPathString(k);
		if(not _uiObject or _uiObject:IsValid() == false) then
			-- remove from the pool. 
			delete_pool = delete_pool or {};
			delete_pool[k] = true;
		else
			if(v.IsAnimating == true) then
				--local animID = v.AnimID;
				local file = v.File; -- e.g "Test_UIAnimFile.lua.table"
				local seq = v.Seq; -- -- e.g "Bounce"
				
				local nToDoFrame = v.nCurrentFrame + dTimeDelta;
				
				if(nToDoFrame > v.nEndFrame) then
					
					nToDoFrame = nToDoFrame - (v.nEndFrame - v.nStartFrame); -- wrap to the beginning
					
					if(file.UIAnimSeq[seq].Seq[v.currentSeqID + 1] == nil) then
						-- end of animation
						if(v.isLooping) then
							-- loop to the front of animation sequence
							v.currentSeqID = 1;
							local animationID = file.UIAnimSeq[seq].AnimationID;
							v.nCurrentFrame = file.UIAnimation[animationID]:GetStartFrame(file.UIAnimSeq[seq].Seq[1]);
							v.nStartFrame = file.UIAnimation[animationID]:GetStartFrame(file.UIAnimSeq[seq].Seq[1]);
							v.nEndFrame = file.UIAnimation[animationID]:GetEndFrame(file.UIAnimSeq[seq].Seq[1]);
						else
							-- NOTE: original implementation
							--	Animaiton logic fails in the following code:
							--		UIAnimManager.StopLoopingUIAnimationSequence(_waiting, fileName, "WaitingSpin");
							--		_waiting.visible = false;
							--
							---- end of animation
							--v.nCurrentFrame = v.nEndFrame;
							--v.IsAnimating = false;
							--_uiObject.visible = v.SetBackVisible;
							--_uiObject.enable = v.SetBackEnable;
						end
					else
						-- continue with sequence
						v.currentSeqID = v.currentSeqID + 1;
						local animID = file.UIAnimSeq[seq].Seq[v.currentSeqID];
						v.animationID = file.UIAnimSeq[seq].AnimationID;
						v.nCurrentFrame = nToDoFrame - v.nStartFrame;
						v.nStartFrame = file.UIAnimation[v.animationID]:GetStartFrame(animID);
						v.nEndFrame = file.UIAnimation[v.animationID]:GetEndFrame(animID);
						v.nCurrentFrame = v.nCurrentFrame + v.nStartFrame;
					end
				else
					-- continue with current animation
					v.nCurrentFrame = nToDoFrame;
				end
				
				local animID = file.UIAnimSeq[seq].Seq[v.currentSeqID];
				local anim_data = file.UIAnimation[v.animationID];
				local nCurFrame = v.nCurrentFrame;
				local _TX = anim_data:GetTranslationXValue(animID, nCurFrame);
				local _TY = anim_data:GetTranslationYValue(animID, nCurFrame);
				local _SX = anim_data:GetScalingXValue(animID, nCurFrame);
				local _SY = anim_data:GetScalingYValue(animID, nCurFrame);
				local _R = anim_data:GetRotationValue(animID, nCurFrame);
				local _A = anim_data:GetAlphaValue(animID, nCurFrame);
				local _CR = anim_data:GetColorRValue(animID, nCurFrame);
				local _CG = anim_data:GetColorGValue(animID, nCurFrame);
				local _CB = anim_data:GetColorBValue(animID, nCurFrame);
				
				_uiObject.translationx = _TX;
				_uiObject.translationy = _TY;
				_uiObject.scalingx = _SX;
				_uiObject.scalingy = _SY;
				
				_uiObject.rotation = _R;
				_uiObject.color = format("%d %d %d %d", _CR, _CG, _CB, _A);
			
			end -- if(v.IsAnimating = true) then
		end 
	end -- for k, v in pairs(UIAnimationPool) do
	
	if(delete_pool) then
		local id, _
		for id, _ in pairs(delete_pool) do
			UIAnimationPool[id] = nil;
		end
	end	
end

----------------------------------------------------
-- direct x, y, width, height animation
----------------------------------------------------

-- direct animation block
-- NOTE: this kind of animation block contains x, y, width and height data required during animation
--		and a callback function that is called after the animation is complete
if(not UIDirectAnimBlock) then UIDirectAnimBlock = {}; end

function UIDirectAnimBlock:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	return o;
end

function UIDirectAnimBlock:Destroy()
end

-- set direct animation UI object target
-- NOTE: the direct animation block object only stores the UI object path string
-- @param obj: the UI object to be animated
function UIDirectAnimBlock:SetUIObject(obj)
	local pathStr = UIAnimManager.GetPathStringFromUIObject(obj);
	self.PathString = pathStr;
	
	-- set the default source and destination values of the x, y, width and height
	self.XSrc = self.XSrc or obj.x;
	self.XDst = self.XDst or obj.x;
	self.YSrc = self.YSrc or obj.y;
	self.YDst = self.YDst or obj.y;
	self.WidthSrc = self.WidthSrc or obj.width;
	self.WidthDst = self.WidthDst or obj.width;
	self.HeightSrc = self.HeightSrc or obj.height;
	self.HeightDst = self.HeightDst or obj.height;
	self.TranslationXSrc = self.TranslationXSrc or  0;
	self.TranslationXDst = self.TranslationXDst or  0;
	self.TranslationYSrc = self.TranslationYSrc or  0;
	self.TranslationYDst = self.TranslationYDst or  0;
	self.ScalingXSrc = self.ScalingXSrc or  1;
	self.ScalingXDst = self.ScalingXDst or  1;
	self.ScalingYSrc = self.ScalingYSrc or  1;
	self.ScalingYDst = self.ScalingYDst or  1;
	self.RedSrc = self.RedSrc or  1;
	self.RedDst = self.RedDst or  1;
	self.GreenSrc = self.GreenSrc or  1;
	self.GreenDst = self.GreenDst or  1;
	self.BlueSrc = self.BlueSrc or  1;
	self.BlueDst = self.BlueDst or  1;
	self.AlphaSrc = self.AlphaSrc or  1;
	self.AlphaDst = self.AlphaDst or  1;
	self.RotationSrc = self.RotationSrc or  0;
	self.RotationDst = self.RotationDst or  0;
	self.ApplyAnim = self.ApplyAnim or false;
end

-- set the animation time duration
-- @param time: time to complete the animation block
function UIDirectAnimBlock:SetTime(time)
	-- NOTE: the direct animation uses a remaining time to record the time remaining for the animation
	self.DurationTime = time;
end

-- set the animation X animation
-- @param src: source position
-- @param dst: destination position
function UIDirectAnimBlock:SetXRange(src, dst)
	self.XSrc = src;
	self.XDst = dst;
end

-- set the animation Y animation
-- @param src: source position
-- @param dst: destination position
function UIDirectAnimBlock:SetYRange(src, dst)
	self.YSrc = src;
	self.YDst = dst;
end

-- set the animation width animation
-- @param src: source width
-- @param dst: destination width
function UIDirectAnimBlock:SetWidthRange(src, dst)
	self.WidthSrc = src;
	self.WidthDst = dst;
end

-- set the animation height animation
-- @param src: source height
-- @param dst: destination height
function UIDirectAnimBlock:SetHeightRange(src, dst)
	self.HeightSrc = src;
	self.HeightDst = dst;
end

-- set the animation translationx and translationy animation
function UIDirectAnimBlock:SetTranslationXRange(src, dst)
	self.TranslationXSrc = src;
	self.TranslationXDst = dst;
end
function UIDirectAnimBlock:SetTranslationYRange(src, dst)
	self.TranslationYSrc = src;
	self.TranslationYDst = dst;
end

-- set the animation scalingx and scalingy animation
function UIDirectAnimBlock:SetScalingXRange(src, dst)
	self.ScalingXSrc = src;
	self.ScalingXDst = dst;
end
function UIDirectAnimBlock:SetScalingYRange(src, dst)
	self.ScalingYSrc = src;
	self.ScalingYDst = dst;
end

-- set the animation color mask animation R, G, B
function UIDirectAnimBlock:SetRedRange(src, dst)
	self.RedSrc = src;
	self.RedDst = dst;
end
function UIDirectAnimBlock:SetGreenRange(src, dst)
	self.GreenSrc = src;
	self.GreenDst = dst;
end
function UIDirectAnimBlock:SetBlueRange(src, dst)
	self.BlueSrc = src;
	self.BlueDst = dst;
end

-- set the animation alpha animation
function UIDirectAnimBlock:SetAlphaRange(src, dst)
	self.AlphaSrc = src;
	self.AlphaDst = dst;
end

-- set the animation rotation animation
function UIDirectAnimBlock:SetRotationRange(src, dst)
	self.RotationSrc = src;
	self.RotationDst = dst;
end

-- set whether the animation is applied to child objects
function UIDirectAnimBlock:SetApplyAnim(bApply)
	self.ApplyAnim = bApply;
end

-- callback function to call BEFORE the animation is started
-- @param callfrontFunc: if type function direct call function(obj)  end, where obj is a valid binded UI object. 
--		if type string DoString
function UIDirectAnimBlock:SetCallfront(callfrontFunc)
	self.CallfrontFunc = callfrontFunc;
end

-- callback function to call after the animation is complete
-- @callbackFunc: if type function direct call
--		if type string DoString
function UIDirectAnimBlock:SetCallback(callbackFunc)
	self.CallbackFunc = callbackFunc;
end

-- direct animation pool
-- ui object in this pool is directly manipulated on the x, y, width, height
-- NOTE: there is a performance issue if you use this kind of animation instead of 
--		the standard tranlation, scaling, rotation, alpha and color animation.
--		Events and other interaction related data will be reset on every move.
if(not UIDirectAnimationPool) then UIDirectAnimationPool = {}; end

-- return if the ui object is animating
function UIAnimManager.IsDirectAnimating(uiobject)
	local pathStr = UIAnimManager.GetPathStringFromUIObject(uiobject);
	if(UIDirectAnimationPool[pathStr] ~= nil) then
		local nCount = #(UIDirectAnimationPool[pathStr]);
		if(nCount > 0) then
			return true;
		end
	end
	return false;
end

-- stop the direct animation
function UIAnimManager.StopDirectAnimation(uiobject)
	local pathStr = UIAnimManager.GetPathStringFromUIObject(uiobject);
	if(UIDirectAnimationPool[pathStr] ~= nil) then
		local nCount = #(UIDirectAnimationPool[pathStr]);
		if(nCount > 0) then
			local obj = uiobject;
			-- the tail block in queue
			local block = UIDirectAnimationPool[pathStr][nCount];
			obj.x = block.XDst;
			obj.y = block.YDst;
			obj.width = block.WidthDst;
			obj.height = block.HeightDst;
			--obj.translationx = block.TranslationXDst;
			--obj.translationy = block.TranslationYDst;
			--obj.scalingx = block.ScalingXDst;
			--obj.scalingy = block.ScalingYDst;
			--obj.rotation = block.RotationDst;
			obj.translationx = 0;
			obj.translationy = 0;
			obj.scalingx = 1;
			obj.scalingy = 1;
			obj.rotation = 0;
			--local red = math_floor(block.RedDst*255);
			--local green = math_floor(block.GreenDst*255);
			--local blue = math_floor(block.BlueDst*255);
			--local alpha = math_floor(block.AlphaDst*255);
			--obj.colormask = red.." "..green.." "..blue.." "..alpha;
			obj.colormask = "255 255 255 255";
			
			-- NOTE: reset to default attributes, 
			--		otherwise child objects' translation, rotation, scaling will still be calculated
			
			if(block.ApplyAnim == true) then
				obj:ApplyAnim();
			end
			
			-- call the callback function
			if(type(block.CallbackFunc) == "function") then
				block.CallbackFunc();
			elseif(type(block.CallbackFunc) == "string") then
				NPL.DoString(block.CallbackFunc);
			end
		end
		UIDirectAnimationPool[pathStr] = nil;
	end
end

-- play direct animation
-- @param block: of type UIDirectAnimBlock
-- NOTE: one can call this funciton multiple times to append animation block to the previous ones
function UIAnimManager.PlayDirectUIAnimation(block)
	if(block.PathString ~= nil) then
		local anim_queue = UIDirectAnimationPool[block.PathString];
		if(not anim_queue) then
			anim_queue = {};
			UIDirectAnimationPool[block.PathString] = anim_queue;
		end
		-- append to anim block. 
		anim_queue[#anim_queue + 1] = block;
	else
		log("warning: UI object PathString is not specified in UIAnimManager.PlayDirectUIAnimation.\n");
	end
end

-- apply the animation.
-- @param obj: must be a valid uiobject
-- @param block: must be a valid block data. 
-- @param dTimeDelta: the delta time to frame move
-- @return true if animation is finished. 
local function FrameMoveBlockAnim(obj, block, dTimeDelta)
	if(block.elapsedTime == nil) then
		block.elapsedTime = 0;
		-- call the CallfrontFunc function
		if(type(block.CallfrontFunc) == "function") then
			block.CallfrontFunc(obj);
		elseif(type(block.CallfrontFunc) == "string") then
			NPL.DoString(block.CallfrontFunc);
		end
	end
	if((block.elapsedTime + dTimeDelta) < block.DurationTime) then 
		block.elapsedTime = block.elapsedTime + dTimeDelta;
		local percentage = block.elapsedTime / block.DurationTime;
		obj.x = block.XSrc + (block.XDst - block.XSrc) * percentage;
		obj.y = block.YSrc + (block.YDst - block.YSrc) * percentage;
		obj.width = block.WidthSrc + (block.WidthDst - block.WidthSrc) * percentage;
		obj.height = block.HeightSrc + (block.HeightDst - block.HeightSrc) * percentage;
		obj.translationx = block.TranslationXSrc + (block.TranslationXDst - block.TranslationXSrc) * percentage;
		obj.translationy = block.TranslationYSrc + (block.TranslationYDst - block.TranslationYSrc) * percentage;
		obj.scalingx = block.ScalingXSrc + (block.ScalingXDst - block.ScalingXSrc) * percentage;
		obj.scalingy = block.ScalingYSrc + (block.ScalingYDst - block.ScalingYSrc) * percentage;
		obj.rotation = block.RotationSrc + (block.RotationDst - block.RotationSrc) * percentage;
		local red = block.RedSrc + (block.RedDst - block.RedSrc) * percentage;
		local green = block.GreenSrc + (block.GreenDst - block.GreenSrc) * percentage;
		local blue = block.BlueSrc + (block.BlueDst - block.BlueSrc) * percentage;
		local alpha = block.AlphaSrc + (block.AlphaDst - block.AlphaSrc) * percentage;
		local red = math_floor(red*255);
		local green = math_floor(green*255);
		local blue = math_floor(blue*255);
		local alpha = math_floor(alpha*255);
		obj.colormask = red.." "..green.." "..blue.." "..alpha;
						
		if(block.ApplyAnim == true) then
			obj:ApplyAnim();
		end
	else
		-- finished
		-- the tail block in queue
		obj.x = block.XDst;
		obj.y = block.YDst;
		obj.width = block.WidthDst;
		obj.height = block.HeightDst;
		--obj.translationx = block.TranslationXDst;
		--obj.translationy = block.TranslationYDst;
		--obj.scalingx = block.ScalingXDst;
		--obj.scalingy = block.ScalingYDst;
		--obj.rotation = block.RotationDst;
		obj.translationx = 0;
		obj.translationy = 0;
		obj.scalingx = 1;
		obj.scalingy = 1;
		obj.rotation = 0;
		--local red = math_floor(block.RedDst*255);
		--local green = math_floor(block.GreenDst*255);
		--local blue = math_floor(block.BlueDst*255);
		--local alpha = math_floor(block.AlphaDst*255);
		--obj.colormask = red.." "..green.." "..blue.." "..alpha;
		obj.colormask = "255 255 255 255";
							
		-- NOTE: reset to default attributes, 
		--		otherwise child objects' translation, rotation, scaling will still be calculated
		if(block.ApplyAnim == true) then
			obj:ApplyAnim();
		end
							
		-- call the callback function
		if(type(block.CallbackFunc) == "function") then
			block.CallbackFunc();
		elseif(type(block.CallbackFunc) == "string") then
			NPL.DoString(block.CallbackFunc);
		end
		return true;
	end
end

-- return true if there is remaining unplayed anim in the queue. 
local function FrameMoveBlockQueue(obj, blockQueue, dTimeDelta)
	local block = blockQueue[1];
	if(block ~= nil) then
		local is_finished = FrameMoveBlockAnim(obj, block, dTimeDelta)
		if(is_finished) then 
			-- animate the next block in queue
			block = blockQueue[2];
			if(block ~= nil) then
				-- pop the finished block
				local nCount = #(blockQueue);
				local i;
				for i = 2, nCount do
					blockQueue[i-1] = blockQueue[i];
				end
				blockQueue[nCount] = nil;

				-- apply the next block
				-- NOTE: some error here is the elapsedTime is nil, some bug in the init process
				if(block.DurationTime and block.elapsedTime) then
					dTimeDelta = dTimeDelta - (block.DurationTime - block.elapsedTime);
				else
					dTimeDelta = dTimeDelta;
				end

				return FrameMoveBlockQueue(obj, blockQueue, dTimeDelta)
			else
				blockQueue[1] = nil;
				return true;
			end
		else
			return true;
		end
	end
end

-- animate the ui object in the direct animation pool
-- this will directly manipulate the ui object's x, y, width, height
-- NOTE: this function is called by the original UIAnimManager.DoAnimation on every timer animation.
-- TODO: test performance on some old GPUs
function UIAnimManager.DoDirectAnimation(dTimeDelta)
	local delete_pool;
	local k, v;
	for k, v in pairs(UIDirectAnimationPool) do
		-- get the first object in the animation block queue
		local blockQueue = v;
		local block = blockQueue[1];
		if(block ~= nil) then
			if(block.PathString ~= nil and block.DurationTime ~= nil) then
				local obj = UIAnimManager.GetUIObjectFromPathString(block.PathString);
				if(not obj) then
					-- remove from the pool. 
					delete_pool = delete_pool or {};
					delete_pool[k] = true;
				else
					-- now frame move the block queue.
					FrameMoveBlockQueue(obj, blockQueue, dTimeDelta);
				end	
			else
				log("warning: invalid block found in UIDirectAnimationPool when calling UIAnimManager.DoDirectAnimation\n");
			end
		end
	end
	
	if(delete_pool) then
		local id, _
		for id, _ in pairs(delete_pool) do
			UIDirectAnimationPool[id] = nil;
		end
	end	
end

-- custom animation pool
local CustomAnimationPool = {};
local New_CustomAnimationPool = {};
local next_anim_id = 0;
-- play custom animation
-- @param time: time to complete the animation block
-- @param callbackFunc: function (elapsedTime) end
-- @param id of the custom animation, string recommanded for external animation. if nil a default one will be generated. 
--  id [0,10000] is internally reserved. use larger than 10000 value for external animation id. 
-- @param period: The time interval between invocations of the callback method in milliseconds. if nil, it defaults to rendering frame rate
function UIAnimManager.PlayCustomAnimation(time, callbackFunc, id, period)
	if(type(time) == "number" and type(callbackFunc) == "function") then
		if(not id or CustomAnimationPool[id] or New_CustomAnimationPool[id]) then
			while(CustomAnimationPool[next_anim_id] or New_CustomAnimationPool[next_anim_id]) do
				next_anim_id = next_anim_id + 1;
				if(next_anim_id>10000) then
					next_anim_id = 0;
				end
			end
			id = next_anim_id;
		end
		New_CustomAnimationPool[id] = {durationTime = time, callbackFunc = callbackFunc, period = period};
	end
end

-- stop custom animation
-- @param id of the custom animation, specified in PlayCustomAnimation
function UIAnimManager.StopCustomAnimation(id)
	if(id) then
		CustomAnimationPool[id] = nil;
		New_CustomAnimationPool[id] = nil;
	end
end

-- animation in the custom animation pool
-- NOTE: this function is called by the original UIAnimManager.DoAnimation on every timer animation.
function UIAnimManager.DoCustomAnimation(dTimeDelta)
	local delete_pool = {};

	for id, block in pairs(New_CustomAnimationPool) do
		CustomAnimationPool[id] = block;
	end
	New_CustomAnimationPool = {};

	for id, block in pairs(CustomAnimationPool) do
		if(not block.elapsedTime) then
			block.elapsedTime = 0;
			block.last_elapsedTime = 0;
			block.callbackFunc(block.elapsedTime);
		else
			block.elapsedTime = block.elapsedTime + dTimeDelta;
			if(block.elapsedTime < block.durationTime) then
				if(not block.period or (block.elapsedTime-block.last_elapsedTime) >= block.period) then
					block.last_elapsedTime = block.elapsedTime;
					block.callbackFunc(block.elapsedTime);	
				end
			else
				block.callbackFunc(block.durationTime);
				table.insert(delete_pool, id);
			end
		end
	end
	
	for _, id in pairs(delete_pool) do
		CustomAnimationPool[id] = nil;
	end
end


-----------------------------
-- simple fade in/out alpha animation using color_mask attribute
-----------------------------

local alpha_pools = {};

local function get_alpha_timer(name)
	local alpha_timer = alpha_pools[name];
	if(not alpha_timer) then
		alpha_timer = commonlib.Timer:new({callbackFunc = function(timer) 
			local _parent = ParaUI.GetUIObject(timer.alpha_obj_id);
			if(_parent:IsValid()) then
				local current_alpha = timer.current_alpha;
				local target_alpha = timer.target_alpha;
				local delta = timer:GetDelta()*0.001*(timer.alpha_speed or 512);
				
				if(current_alpha > target_alpha) then
					current_alpha = current_alpha - delta;
					if(current_alpha<target_alpha) then
						current_alpha = target_alpha;
					end
				elseif(current_alpha < target_alpha) then
					current_alpha = current_alpha + delta;
					if(current_alpha>target_alpha) then
						current_alpha = target_alpha;
					end
				end
				timer.current_alpha = current_alpha;
				_parent.colormask = format("255 255 255 %d", math_floor(current_alpha));
				if(timer.apply_to_children ~= false) then
					_parent:ApplyAnim();
				end

				if(current_alpha == target_alpha) then
					timer:Change();
				end
			else
				timer:Change();
			end
		end})
		alpha_pools[name] = alpha_timer;
	end

	return alpha_timer;
end

-- animate alpha to the target value 
-- @param name: a globally unique name. if nil, the _parent.id is used. 
-- @param _parent: the parent control to animate.  
-- @param target_alpha: the target alpha value in the range [0,255]. default to 255. 
-- @param alpha_speed: the alpha speed. default to 512 per second, which changes from 0 to 255 in 0.5 seconds.  
-- @param delay_time: delay in milliseconds before we perform alpha animation. 
-- @param apply_to_children: if nil or true, we will apply animation recursively to its children. 
function UIAnimManager.ChangeAlpha(name, _parent, target_alpha, alpha_speed, delay_time, apply_to_children )
	if(_parent) then
		target_alpha = target_alpha or 255.
		local timer = get_alpha_timer(name or _parent.id);
		timer.alpha_obj_id = _parent.id;
		timer.apply_to_children = apply_to_children;
		timer.current_alpha = tonumber(_parent.colormask:match("%d+$")) or 255;
		if(current_alpha ~= target_alpha) then
			timer.target_alpha = target_alpha;
			timer.alpha_speed = alpha_speed or 512;
			timer:Change(delay_time or 30,30);
		end
	end
end