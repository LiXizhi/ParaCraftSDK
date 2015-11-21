--[[
Title: It gives auto hide capability to any container one specifies.
Author(s): LiXizhi
Date: 2008/6/7
Desc: It gives auto hide capability to any container one specifies.
The idea is simple, a container autohides whenever a timer checks that the mouse is no longer on the container and there is no toplevel controls.
A autohidden window will leave an invisible control at its original place to receive mouse enter messages. 
When it receives mouse enter message, it will show up the control again and start the timer to check mouse position every interval seconds. 

---++ Overview
There is only one function to call to enable autohiding for that container. 
<verbatim>
	CommonCtrl.AutoHide.EnableAutoHide(uiobj, {leave_interval=2, height=5})
</verbatim>
The first parameter is a base UI container ParaUIObject which is usually attached to root. 
The second parameter is a table with the following fields. All fields are optional
| *name*		| *type*	| *description* |
| leave_interval| float		| how many seconds to wait before autohiding the base ui object when mouse is no longer on it. If nil, it is immediate.|
| enter_interval| float		| (not implemented yet) how many seconds to wait before showing up the base ui object when mouse stays in the detector region. If nil, it is immediate. |
| ontoggle		| function	| it is an function(bShow, uiobj) end, it is called whenever the autohidden or showed up. One can usually play an animation at these times. |
| x				| int		| screen position x of the detector region. if nil, it is read from the current base ui object |
| y				| int		| screen position y of the detector region. if nil, it is read from the current base ui object |
| rx			| int		| relative to base ui object screen position x of the detector region. if nil, it is read from the current base ui object |
| ry			| int		| relative to base ui object screen position y of the detector region. if nil, it is read from the current base ui object |
| width			| int		| screen position width of the detector region. if nil, it is read from the current base ui object |
| height		| int		| screen position height of the detector region. if nil, it is read from the current base ui object |
| detector_zorder| int		| z-order of the detector window, if nil, it will be set the same as the base ui object |

To disable just call. It will remove all intermediate objects for autohidding. 
<verbatim>
	CommonCtrl.AutoHide.DisableAutoHide(uiobj)
</verbatim>	

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/AutoHide.lua");
CommonCtrl.AutoHide.EnableAutoHide(uiobj, {leave_interval=2, height=5})
CommonCtrl.AutoHide.DisableAutoHide(uiobj)
-- advanced version
CommonCtrl.AutoHide.EnableAutoHide(uiobj, {leave_interval=2, enter_interval=0, ontoggle=function(bShow, uiobj) end, x, y, width, height, rx, ry})
-------------------------------------------------------
]]

-- define a new control in the common control libary
local AutoHide = {
	pools = {}, 
	error = "",
	print_error = commonlib.error,  
}
CommonCtrl.AutoHide = AutoHide;

-- enable autohide to a level 1 control. 
-- @param uiobject: a container which is attached to root. 
-- @param params: a clean new table of {leave_interval=2, enter_interval=0, ontoggle=nil, onhide=nil, x, y, width, height, rx, ry}
function AutoHide.EnableAutoHide(uiobj, params)
	if(uiobj and uiobj:IsValid()) then
		params = params or {};
		params.id = uiobj.id;
		
		if(AutoHide.pools[params.id]) then
			-- update parameters
		end	
		AutoHide.pools[params.id] = params;
		
		-- create the region detector 
		if(not params.detector_id)then
			params.alignment = params.alignment or "_lt"
			local x, y, width, height = uiobj:GetAbsPosition();
			params.x = params.x or x;
			params.y = params.y or y;
			params.width = params.width or width;
			params.height = params.height or height;
			
			local _this=ParaUI.CreateUIObject("container", "s", "_lt",0,0,0,0);
			_this.background="";
			_this.enabled=false;
			-- make same zorder or use input
			_this.zorder = params.detector_zorder or uiobj.zorder; 
			_this:AttachToRoot();
			
			params.detector_id = _this.id;
			commonlib.log("autohider detector created %s\n", tostring(params.detector_id));
			
			AutoHide.AdjustDetectorState(params);
		end
	end
end

-- disable autohiding for a previously autohide enabled control.
-- @param uiobject: a container which is attached to root. 
function AutoHide.DisableAutoHide(uiobj)
	if(uiobj and uiobj:IsValid()) then
		local uid = uiobj.uid;
		local params = AutoHide.pools[params.id];
		if(params) then
			-- remove autohide_detector. 
			if(params.detector_id) then
				ParaUI.DestroyUIObject(ParaUI.GetUIObject(params.detector_id))
			end
			AutoHide.pools[params.id] = nil;
		end
	end
end

-- private: adjust detector state according to the visibility of the base ui object
-- call this function whenever the visible property of the base uiobject changes. 
-- @param bVisible: if nil, the visible state of the base uiobject is used. otherwise this value is used. 
function AutoHide.AdjustDetectorState(params, bVisible)
	local detector = ParaUI.GetUIObject(params.detector_id)
	if(not detector:IsValid()) then return end
	
	local uiobj = ParaUI.GetUIObject(params.id)
	if(not uiobj:IsValid()) then 
		-- remove detector if base uiobject is not found. 
		ParaUI.DestroyUIObject(detector)
		return
	end
	
	if(bVisible or uiobj.visible) then
		-- when base ui object is visible, set the timer to check if mouse is not on the uiobject. 
		detector.enabled = false;detector.x=0;detector.y=0;detector.width=0;detector.height=0;
		detector.onframemove = string.format(";CommonCtrl.AutoHide.OnDetectorFrameMove(%d);", params.id);
		
		params.OnLeaveCountDown = params.leave_interval;
		--commonlib.echo("visible adjusted")
	else
		-- when base ui object is invisible, bring the detector at the same zorder as the uiobject and set the on enter event. 
		detector.enabled = true;
		detector.onframemove = "";
		local x,y, width, height = uiobj:GetAbsPosition();
		detector.x = params.x or (x + (params.rx or 0));
		detector.y = params.y or (y + (params.ry or 0));
		detector.width = params.width or width;
		detector.height = params.height or height;
		detector.onmouseenter = string.format(";CommonCtrl.AutoHide.OnDetectorMouseEnter(%d);", params.id);
		--commonlib.echo("Invisible adjusted")
	end
end

-- private: mouse enter function for all detectors.
-- adjust the state
function AutoHide.OnDetectorMouseEnter(id)
	local params = AutoHide.pools[id];
	if(not params) then 
		commonlib.log("warning: detector %d not found\n", id)	
	end
	if(not ParaUI.GetTopLevelControl():IsValid()) then
		-- show the ui object unpon enter. 
		AutoHide.ToggleVisibility(true, params)
	end
end

-- private: frame move function for all detectors.
-- check if mouse is not on the uiobject. if so, autohide the base ui object and adjust detector state. 
function AutoHide.OnDetectorFrameMove(id)
	local params = AutoHide.pools[id];
	if(not params) then 
		commonlib.log("warning: detector %d not found\n", id)	
	end
	
	if(params.OnLeaveCountDown) then
		params.OnLeaveCountDown = params.OnLeaveCountDown-deltatime;
	end	
	if(params.OnLeaveCountDown==nil or params.OnLeaveCountDown<=0) then
		-- check whether mouse in client, if there is no top level control
		if(not ParaUI.GetTopLevelControl():IsValid()) then
			local mouse_x, mouse_y = ParaUI.GetMousePosition()
			
			local uiobj = ParaUI.GetUIObject(params.id)
			if(not uiobj:IsValid() or not uiobj.visible) then 
				AutoHide.AdjustDetectorState(params);
				return;
			end
			
			local x,y, width, height = uiobj:GetAbsPosition();
			if(x>mouse_x or y>mouse_y or (x+width)<mouse_x or (y+height)<mouse_y) then
				-- if mouse is outside the detector. we will auto hide this base ui object. 
				if(params.OnLeaveCountDown==nil or params.OnLeaveCountDown<=-params.leave_interval) then
					-- this is tricky: it checks every params.leave_interval, but when params.OnLeaveCountDown is 0, it checks every frame for params.leave_interval time. 
					AutoHide.ToggleVisibility(false, params)
				end	
			else
				params.OnLeaveCountDown = params.leave_interval;
			end
		end	
	end	
end

-- private: toggle visiblity. It will call the onshow call back. and set the visiblity of the base ui object. 
function AutoHide.ToggleVisibility(bShow, params)
	local uiobj = ParaUI.GetUIObject(params.id)
	if(uiobj:IsValid()) then 
		uiobj.visible = bShow;
		
		if(type(params.ontoggle) == "function") then
			params.ontoggle(bShow, uiobj);
		end
		
		AutoHide.AdjustDetectorState(params);
		--commonlib.echo("ToggleVisibility")
	end
end