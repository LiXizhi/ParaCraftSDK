--[[
Author: LiXizhi
Date: 2010/12/1
Desc: Configure NPL state options
-----------------------------------------------
-- set the NPL input message queue size
NPL.activate("script/ide/config/NPLStateConfig.lua", {type="SetAttribute", attr={MsgQueueSize=5000,}});
-----------------------------------------------
]]
NPL.load("(gl)script/ide/log.lua");

local function activate()
	local msg = msg;
	if(type(msg) ~= "table") then
		return
	end
	local msg_type = msg.type;
	if(msg_type == "SetAttribute") then
		if(type(msg.attr) == "table") then
			local key, value
			
			for key, value in pairs(msg.attr) do
				if(key == "MsgQueueSize") then
					if(__rts__.SetMsgQueueSize and type(value) == "number") then
						__rts__:SetMsgQueueSize(value);
						LOG.std(nil, "system", "NPL", "NPL input queue size of thread (%s) is changed to %d", __rts__:GetName(), value);
					end
				end
			end
		end
	end
end
NPL.this(activate)