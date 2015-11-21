--[[
Title: 
Author(s): Leio
Date: 2009/11/5
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");


室外
"Grid" 花圃
"PlantE" 可种植的植物
"OutdoorHouse" 房屋
"OutdoorOther" 其他
	"ChristmasSocks" 圣诞袜子
	"MusicBox" 音乐盒
室内
"Furniture" 家具
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");

local HomeLandCommonNode = commonlib.inherit(CommonCtrl.Display3D.SceneNode, {
	type = "HomeLandCommonNode",
}, function(o)
	
end)
commonlib.setfield("CommonCtrl.Display3D.HomeLandCommonNode",HomeLandCommonNode);
function HomeLandCommonNode:GetType()
	return self.type;
end
--音乐盒的音乐是否播放
function HomeLandCommonNode:SetMusicBoxPlaying(v)
	self.music_isplaying = v;
end
function HomeLandCommonNode:GetMusicBoxPlaying()
	return self.music_isplaying;
end

--属性是否有改变
function HomeLandCommonNode:SetPropertyIsChanged(v)
	self.property_is_changed = v;
end
function HomeLandCommonNode:GetPropertyIsChanged()
	return self.property_is_changed;
end
--关联花圃的uid
function HomeLandCommonNode:SetSeedGridNodeUID(uid)
	self.seedGridUID = uid;
end
function HomeLandCommonNode:GetSeedGridNodeUID()
	return self.seedGridUID;
end
--物体关联的item guid
function HomeLandCommonNode:GetGUID()
	return self.item_guid;
end	
function HomeLandCommonNode:SetGUID(guid)
	self.item_guid = guid;
end
--物体关联的item gsid
function HomeLandCommonNode:GetGSID()
	return self.item_gsid;
end	
function HomeLandCommonNode:SetGSID(gsid)
	self.item_gsid = gsid;
end
--物体关联的远程数据
function HomeLandCommonNode:GetBean()
	return self.bean;
end	
function HomeLandCommonNode:SetBean(bean)
	self.bean = bean;
end
----在植物属性上设置 GridInfo=\"20091015T084400.953125-295|1\"
--function HomeLandCommonNode:SetGrid(gridInfo)
	--self.gridInfo = gridInfo;
--end
----在进入家园的时候 会从这里获取 植物关联的花圃uid
--function HomeLandCommonNode:GetGrid()
	--return self.gridInfo;
--end
--在室内模型上设置 它是属于哪个室外房屋的
function HomeLandCommonNode:SetOutdoorNodeUID(uid)
	self.belongto_outdoor_uid = uid;
end
function HomeLandCommonNode:GetOutdoorNodeUID()
	return self.belongto_outdoor_uid;
end
--@params args:一些可变的参数
function HomeLandCommonNode:ClassToMcml(args)
	local params = self:GetEntityParams();
	
	if(args and args.origin)then
		--从绝对坐标转换为相对坐标
		params.x = params.x - args.origin.x;
		params.y = params.y - args.origin.y;
		params.z = params.z - args.origin.z;
	end
	local k,v;
	local result = "";
	for k,v in pairs(params) do
			if(type(v)~="table")then
				if(k == "x" or k == "y" or k == "z" or k == "facing" or k == "scaling")then
					if(type(v) == "number") then
						if(v == math.floor(v)) then
							v = string.format("%d", v);
						else
							v = string.format("%.2f", v);
						end
					end
				end
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
	end
	local title = self.type;
	local HomeLandObj = string.format('%s="%s" ',"HomeLandObj",title);
	result =  result..HomeLandObj;
	--local gridInfo = self.gridInfo or "";
	local gridInfo = "";
	--如果有关联的花圃
	--构造成这种形式：GridInfo=\"20091015T084400.953125-295|1\"
	if(self.seedGridUID)then
		gridInfo = self.seedGridUID.."|"..1;--放在第一个插件点的位置上
	end
	----在植物属性上设置 GridInfo=\"20091015T084400.953125-295|1\"
	gridInfo = string.format('%s="%s" ',"GridInfo",gridInfo or "");
	result =  result..gridInfo;
		
	--属于哪个室外房屋的
	local belongto_outdoor_uid = "";
	belongto_outdoor_uid = string.format('%s="%s" ',"belongto_outdoor_uid",self.belongto_outdoor_uid or "");
	result =  result..belongto_outdoor_uid;
	
	--物品系统的guid
	local guid = string.format('%s="%s" ',"guid",self.item_guid or "");
	result =  result..guid;
	--物品系统的gsid
	local gsid = string.format('%s="%s" ',"gsid",self.item_gsid or "");
	result =  result..gsid;
	
	--音乐盒的音乐是否播放
	local music_isplaying = "";
	if(self.music_isplaying)then
		music_isplaying = "true";
	else
		music_isplaying = "false";
	end
	local music_isplaying = string.format('%s="%s" ',"music_isplaying",music_isplaying);
	result =  result..music_isplaying;
	
	result =  string.format('<HomeLandObj_B %s/>',result);
	return result;
end
