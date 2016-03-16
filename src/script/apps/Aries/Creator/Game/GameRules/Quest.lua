--[[
Title: Quest
Author(s): LiXizhi
Date: 2016/3/15
Desc: 
Quest is a complex rule item, which is defined by an xml file.
A quest rule contains:
* preconditions: such as how many items must be collected by the 
 triggering entity before the quest is active. 
 * request_quests: quest to be completed before this quest can be activated. 
* goals: a list of goals to complete before the quest can be completed. 
* froms: a list of items to remove when rule is finished.  
* tos: a list of items to receive when rule is finished.
* start_dialog: dialogs to show to the user, when pre-condition is met, but froms and goals are not met, 
* end_dialog: dialogs to show to the user, when froms and goals are met, before rule is executed. 

use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GameRules/Quest.lua");
local Quest = commonlib.gettable("MyCompany.Aries.Game.Rules.Quest");
local quest = Quest:new():LoadFromFile("script/apps/Aries/Creator/Game/GameRules/test/1001_test.quest.xml");
local triggerEntity = nil;
quest:WriteQuestLogToEntity(triggerEntity, "finished");
assert(quest:IsFinishedByEntity(triggerEntity) == true)
-------------------------------------------------------
]]
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");

local Quest = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Rules.RuleBase"), commonlib.gettable("MyCompany.Aries.Game.Rules.Quest"));

function Quest:ctor()
end

function Quest:Init(rule_name, rule_params)
	return self;
end

-- @param filename: recommended format is "config/quests/[quest_id]_[quest_name].quest.xml"
-- if no quest_id is found in the filename, we will use the entire filename as unique id. 
-- such as "1001_helloquest.quest.xml"
-- @return string id, such as "1001"
function Quest:GetQuestIDFromFileName(filename)
	filename = filename:match("[^/\\]+$");
	if(filename) then
		local id = filename:match("^%d+");
		if(id) then
			return id;
		else
			return filename:match("[^%.]+")
		end
	end
end

function Quest:RewardXmlToTable(xmlnodes)
	if(not xmlnodes)then return end
	local result = {};
	for node in commonlib.XPath.eachNode(xmlnodes, "/items") do
		local items = {};
		for k,v in ipairs(node) do
			local attr = v.attr;
			if(attr)then
				attr.id = tonumber(attr.id);
				attr.count = tonumber(attr.value or attr.count);
				table.insert(items, attr);
			end
		end
		local attr = node.attr;
		if(attr)then
			items.id = tonumber(attr.id);
			items.choice = tonumber(attr.choice or -1) or -1;
		end
		table.insert(result,items);
	end
	return result;
end

function Quest:DialogXmlToTable(xmlnodes)
	if(not xmlnodes)then return end
	local result = {};
	for node in commonlib.XPath.eachNode(xmlnodes, "/dialog/item") do
		local item = {};
		for k,v in ipairs(node) do
			local name = v.name;
			if(name ~= "buttons")then
				local value;
				if(name == "avatar")then
					value = v[1];
				elseif(name == "content")then
					value = commonlib.Lua2XmlString(v[1]);
				end
				item[name] = value;
			else
				local buttons = {};
				item[name] = buttons;
				for kk,vv in ipairs(v) do
					local button = vv.attr;
					button.label = button.label or (vv[1] and commonlib.Lua2XmlString(vv[1]));
					table.insert(buttons,button);
				end
			end
		end
		table.insert(result,item);
	end
	return result;
end

-- all preconditions
function Quest:PreconditionXmlToTable(xmlnodes)
	if(not xmlnodes)then return end
	local result = {};
	for _, node in ipairs(xmlnodes) do
		local name = node.name;
		local item = node.attr;
		if(item) then
			item.name = name;
			if(name == "quest")then
				item.value = tonumber(item.value) or 1;
			elseif(name == "item")then
				item.id = item.id and tonumber(item.id);
				item.value = item.value and tonumber(item.value);
				item.topvalue = item.topvalue and tonumber(item.topvalue);
			end
			result[#result+1] = item;
		end			
	end
	return result;
end

-- load from a quest file. 
function Quest:LoadFromFile(filename)
	local filepath = Files.FindFile(filename);
	if(filepath) then
		self.id = self:GetQuestIDFromFileName(filename);
		if(not self.id) then
			LOG.std(nil, "warn", "Quest", "Id is not found %s", filename);
			return;
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(filepath);

		local node = commonlib.XPath.selectNode(xmlRoot, "/quest");
		for k,v in ipairs(node) do
			local name = v.name;
			if(name == "title" or name == "detail" or name == "icon")then
				self[name] = v[1] or "";
			elseif(name == "reward" or name == "cost")then
				self[name] = self:RewardXmlToTable(v);
			elseif(name == "startdialog" or name == "enddialog")then
				self[name] = self:DialogXmlToTable(v);
			elseif(name == "precondition")then
				self[name] = self:PreconditionXmlToTable(v);
			else
				self[name] = tonumber(v[1]);
			end
		end
	end
	return self;
end

function Quest:Print()
	echo(self, true);
end

-- @param bCreateGet: if true, we will create one if not exist. 
-- @return the QuestLog's itemstack if found or created. 
function Quest:GetQuestLogItemFromEntity(triggerEntity, bCreateGet)
	triggerEntity = triggerEntity or EntityManager.GetPlayer();
	if(not triggerEntity or not triggerEntity.inventory) then
		return;
	end
	local itemStack = triggerEntity.inventory:FindItem(block_types.names.QuestLog);
	if(not itemStack and bCreateGet) then
		itemStack = ItemStack:new():Init(block_types.names.QuestLog, 1);
		if(not triggerEntity.inventory:AddItemToInventory(itemStack)) then
			return;
		end
	end
	return itemStack;
end

-- finished quest is encoded in QuestLog item's text content. using `id`
-- @return a map table from finished quest id to true
function Quest:GetFinishedQuestsFromEntity(triggerEntity)
	local finished_map = {};
	local itemStack = self:GetQuestLogItemFromEntity(triggerEntity);
	if(itemStack) then
		local content = itemStack:GetData();
		if(type(content) == "string") then
			for quest_id in content:gmatch("`[^`]+`") do
				finished_map[quest_id] = true;
			end
		end
	end
	return finished_map;
end

-- return true if quest is already finished by the entity. 
function Quest:IsFinishedByEntity(triggerEntity)
	local finished_map = self:GetFinishedQuestsFromEntity(triggerEntity);
	if(finished_map[self.id]) then
		-- already finished, skip 
		return true;
	end
end

-- when quest is completed, we can write a text log to the entity's quest log item. 
-- @param text: optional text to write to the log, if nil, default string with quest title is used. 
-- @return true if log is written successfully
function Quest:WriteQuestLogToEntity(triggerEntity, text)
	if(self:IsFinishedByEntity(triggerEntity)) then
		return true;
	end

	local itemStack = self:GetQuestLogItemFromEntity(triggerEntity, true);
	if(itemStack) then
		local content = itemStack:GetData();
		if(type(content)~="string") then
			content = "";
		end

		if(not text) then
			text = format("finished quest: %s;date:%s;", self.title, ParaGlobal.GetDateFormat("yyyy-MM-dd"));
		end
		local full_text = format("`%s`%s\n", self.id, text);

		content = content..full_text;

		itemStack:SetData(content);
		return true;
	end
end

-- return true, if quest is active
function Quest:CheckPrecondition(triggerEntity)
	
end

-- call this function if self:CheckPrecondition() returns true. 
-- return activate according to the current entity states
function Quest:ShowDialog(triggerEntity)
end