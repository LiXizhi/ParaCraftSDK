--[[
Title: 
Author(s): Leio	
Date: 2011/06/10
Desc: based on script/apps/Aries/Pipeline/SpellCastViewer/SpellCastViewerPage.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_SpellCastViewer.lua");
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");

-- create class
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");

local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");

local page;
local SpellCast = MyCompany.Aries.Combat.SpellCast;
MotionRender_SpellCastViewer.play_id_map = {};
function MotionRender_SpellCastViewer.BuildID()
	local self = MotionRender_SpellCastViewer;
	local uid = ParaGlobal.GenerateUniqueID();
	self.play_id_map[uid] = uid;
	return uid;
end
-- on init show the current avatar in pe:avatar
function MotionRender_SpellCastViewer.OnInit()
	-- some code driven audio files for backward compatible
	AudioEngine.Init();
	-- set max concurrent sounds
	AudioEngine.SetGarbageCollectThreshold(10)
	-- load wave description resources
	AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");
end

function MotionRender_SpellCastViewer.RemoveTestArena()
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	MyCompany.Aries.Combat.ObjectManager.DestroyArenaObj(9991);

	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10091);
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10092);
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10093);
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10094);

	local i = 1;
	for i = 1, 4 do
		local _obj = ParaScene.GetCharacter(tostring(1234560 + i));
		if(_obj and _obj:IsValid() == true) then
			ParaScene.Delete(_obj);
		end
		local _obj = ParaScene.GetCharacter(tostring(1234560 + i).."+driver");
		if(_obj and _obj:IsValid() == true) then
			ParaScene.Delete(_obj);
		end
	end
end
--NOTE:added by leio 2011/05/21
--[[
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
CombatCameraView.enabled = true;
NPL.load("(gl)script/ide/MotionEx/MotionRender_SpellCastViewer.lua");
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");
local character_list = {
	[1] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml", Scale="1" },
	[2] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml",Scale="1" },
	[3] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml",Scale="1" },
	[4] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml",Scale="1" },
	[5] = {AssetFile = "character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x",Scale="1" },
	[6] = {AssetFile = "character/v5/10mobs/HaqiTown/EvilSnowman/EvilSnowman.x",Scale="1" },
	[7] = {AssetFile = "character/v5/10mobs/HaqiTown/FireRockyOgre/FireRockyOgre_02.x",Scale="1" },
	[8] = {AssetFile = "character/v5/10mobs/HaqiTown/RedCrab/RedCrab.x",Scale="1" },
}
MotionRender_SpellCastViewer.RemoveTestArena()
-- some code driven audio files for backward compatible
AudioEngine.Init();
-- set max concurrent sounds
AudioEngine.SetGarbageCollectThreshold(10)
-- load wave description resources
AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");
MotionRender_SpellCastViewer.CreateArena(x, y, z,character_list,function()
	MotionRender_SpellCastViewer.TestSpellFromFile("config/Aries/Spells/Storm_SingleAttack_Level1.xml",1,5);
end);
--]]
function MotionRender_SpellCastViewer.CreateArena(x, y, z,character_list,callbackFunc)
	if(not character_list)then
		return
	end
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	
	if(SystemInfo.GetField("name") == "Taurus") then -- for taurus only
		NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
		Map3DSystem.Item.ItemManager.GlobalStoreTemplates[10001] = {
			assetfile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml",
		};
	end
	
	-- for SentientGroupIDs
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	
	--MyCompany.Aries.Combat.ObjectManager.SyncEssentialCombatResource(function()
		
		local p_x, p_y, p_z;
		if(x and y and z) then
			p_x = x;
			p_y = y;
			p_z = z;
		else
			p_x, p_y, p_z = ParaScene.GetPlayer():GetPosition();
		end

		NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
		local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

		local arena_meta = MsgHandler.Get_arena_meta_data_by_id(9991);
		arena_meta.mode = "pve"

		MyCompany.Aries.Combat.ObjectManager.CreateArenaObj(9991, {x = p_x, y = p_y, z = p_z}, true, true); -- bForceVisible, bMovieArena
		-- if nid is not available it is a Taurus project character
		-- create a character 
		local i;
		for i = 1, 8 do
			local node = character_list[i];
			if(node)then
				if(node.CCSInfoStr == "myself") then
					if(SystemInfo.GetField("name") == "Taurus") then -- for taurus only
						node.CCSInfoStr = nil;
					else
						node.CCSInfoStr = Map3DSystem.UI.CCS.GetCCSInfoString();
					end
				end
				local Scale = tonumber(node.Scale) or 1;
				if( i <= 4)then
					local nid_name = tostring(1234560 + i);
					local AssetFile = node.AssetFile or "character/v3/Elf/Female/ElfFemale.xml";
					local CCSInfoStr = node.CCSInfoStr or "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#";
					local player = ParaScene.GetObject(nid_name);
					if(player:IsValid() == false) then
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
							silentmode = true,
							SkipHistory = true,
							obj_params = {
								name = nid_name,
								AssetFile = AssetFile,
								CCSInfoStr = CCSInfoStr,
								x = p_x,
								-- y = p_y,
								y = -10000, -- this will fix a bug when the arena model is not fully loaded, the character will not be visible. 
								z = p_z,
								IsCharacter = true,
								IsPersistent = false, -- do not save an GSL agent when saving scene
								scaling = Scale,
							},
						})
						--local player = ParaScene.GetObject(nid_name);
						--if(player:IsValid() == true) then
							--Map3DSystem.UI.CCS.ApplyCCSInfoString(player, CCSInfoStr);
						--end
					end
			
					MyCompany.Aries.Combat.ObjectManager.MountPlayerOnSlot(1234560 + i, 9991, i);
				else
					local AssetFile = node.AssetFile or "character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x";
					local params = {
						position = {p_x, p_y, p_z},
						assetfile_char = AssetFile,
						instance = 10090 + i - 4,
						name = "",
						scaling = Scale,
						--scale_char = Scale,
					};
					local NPC = MyCompany.Aries.Quest.NPC;
					local char_buffslot = NPC.CreateNPCCharacter(39001, params);
					MyCompany.Aries.Combat.ObjectManager.MountNPCOnSlot(39001, 10090 + i - 4, 9991, i);
				end
			end
		end
		if(callbackFunc)then
			callbackFunc();
		end
	--end)
end
function MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
	-- if the arena is created use the arena object to play spell effect
		
		local caster;
		local target;
		if(not caster_id) then
			caster = {isPlayer = true, nid = 1234561, slotid = caster_id};
		else
			if(caster_id >= 1 and caster_id <= 4) then
				caster = {isPlayer = true, nid = 1234560 + caster_id, slotid = caster_id};
			elseif(caster_id >= 5 and caster_id <= 8) then
				caster = {isPlayer = false, npc_id = 39001, instance = 10090 + (caster_id - 4), slotid = caster_id};
			end
		end
		if(not target_id) then
			target = {isPlayer = false, npc_id = 39001, instance = 10091, slotid = target_id};
		else
			if(target_id >= 1 and target_id <= 4) then
				target = {isPlayer = true, nid = 1234560 + target_id, slotid = target_id};
			elseif(target_id >= 5 and target_id <= 8) then
				target = {isPlayer = false, npc_id = 39001, instance = 10090 + (target_id - 4), slotid = target_id};
			end
		end
	return caster,target;
end

local charm_key_id_mapping = {
	["Fire_FireDamageBlade"] = 11,
	["Fire_AreaAccuracyWeakness"] = 12,
	["Fire_FireDispellWeakness"] = 13,
	["Storm_StormAccuracyBlade"] = 14,
	["Storm_StormDamageBlade"] = 15,
	["Storm_StormDispellWeakness"] = 16,
	["Ice_IceDamageBlade"] = 17,
	["Ice_IceDispellWeakness"] = 18,
	["Life_LifeDamageBlade"] = 19,
	["Life_AreaAccuracyBlade"] = 20,
	["Life_HealBlade"] = 21,
	["Life_LifeDispellWeakness"] = 22,
	["Death_DeathDamageBlade"] = 23,
	["Death_AreaDamageWeakness"] = 24,
	["Death_HealWeakness"] = 25,
	["Death_DeathDispellWeakness"] = 26,
};

local ward_key_id_mapping = {
	["Fire_FireDamageTrap"] = 21,
	["Fire_FirePrism"] = 22,
	["Fire_FireGreatShield"] = 23,
	["Storm_StormDamageTrap"] = 24,
	["Storm_AreaDamageTrap"] = 25,
	["Storm_StormGreatShield"] = 26,
	["Ice_GlobalShield"] = 27,
	["Ice_IceDamageTrap"] = 28,
	["Ice_IcePrism"] = 29,
	["Ice_Absorb_LevelX"] = 30,
	["Ice_StunAbsorb"] = 31,
	["Ice_IceGreatShield"] = 32,
	["Life_Absorb_Level3"] = 33,
	["Life_LifePrism"] = 34,
	["Life_Absorb_Level3"] = 35,
	["Life_LifeDamageTrap"] = 36,
	["Life_LifeGreatShield"] = 37,
	["Death_SymmetryGlobalTrap_Target"] = 38,
	["Death_SymmetryGlobalTrap_Caster"] = 39,
	["Death_DeathDamageTrap"] = 40,
	["Death_DeathPrism"] = 41,
	["Death_GlobalDamageTrap"] = 42,
	["Death_DeathGreatShield"] = 43,
};

function MotionRender_SpellCastViewer.TestSpellFromFile(file, caster_id, target_id)
	 --force load all cameras motion file
	CombatCameraView.ForceLoadAllCameras();
	local key = string.match(file, [[([^/]-)%.xml$]]);
	if(not key) then
		log("error: invalid key name for MotionRender_SpellCastViewer.TestSpellFromFile file="..file.."\n")
		return;
	end

	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	NPL.load("(gl)script/apps/Aries/Combat/SpellPlayer.lua");
	local SpellPlayer = MyCompany.Aries.Combat.SpellPlayer;
	---- test destory arena object
	--MyCompany.Aries.Combat.ObjectManager.DestroyArenaObj(9991)
	
	local bArenaCreated = MyCompany.Aries.Combat.ObjectManager.IsArenaObjCreated(9991);

	local commentfile = string.gsub(file, "%.xml$", ".comment.xml");
	MotionRender_SpellCastViewer.StopSpellCasting();
	local playing_id = MotionRender_SpellCastViewer.BuildID();
	if(bArenaCreated == true) then
		if(key == "Death_SymmetryGlobalTrap") then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{
				target_wards = tostring(ward_key_id_mapping[key.."_Target"])..",6,6,", last_target_wards = "0,6,6", 
				target_charms = "1,2,", last_target_charms = "0,2", 
				caster_wards = tostring(ward_key_id_mapping[key.."_Caster"])..",6,6,", last_caster_wards = "0,6,6", 
				caster_charms = "1,2,", last_caster_charms = "0,2"
			}}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
			
		elseif(string.find(string.lower(file), "area") and (string.find(string.lower(file), "blade") or string.find(string.lower(file), "weakness"))) then
			-- area attack or area heal
			local targets = {};
			if(target_id <= 4) then
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 1);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 2);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 3);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 4);
				table.insert(targets, target);
			elseif(target_id >= 5) then
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 5);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 6);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 7);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 8);
				table.insert(targets, target);
			end
			local caster, __ = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400}}, {
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "area") and (string.find(string.lower(file), "shield") or string.find(string.lower(file), "prism") or 
				string.find(string.lower(file), "absorb") or string.find(string.lower(file), "trap"))) then
			-- area attack or area heal
			local targets = {};
			if(target_id <= 4) then
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 1);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 2);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 3);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 4);
				table.insert(targets, target);
			elseif(target_id >= 5) then
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 5);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 6);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 7);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 8);
				table.insert(targets, target);
			end
			local caster, __ = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400}}, {
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "area")) then
			-- area attack or area heal
			local targets = {};
			if(target_id <= 4) then
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 1);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 2);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 3);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 4);
				table.insert(targets, target);
			elseif(target_id >= 5) then
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 5);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 6);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 7);
				table.insert(targets, target);
				local _, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, 8);
				table.insert(targets, target);
			end
			local caster, __ = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400}}, nil, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "singleattackwithlifetap")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100},{25}}, nil, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "singleattackwithpercent")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{200},{100}}, nil, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "singleattackwithimmolate")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{600},{250}}, nil, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "singlehealwithimmolate")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{700},{250}}, nil, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "stealpositivecharm")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = "0,2,", last_target_charms = "1,2", caster_wards = "6,6,6,", last_caster_wards = "0,0,6", caster_charms = "1,2,", last_caster_charms = "0,2"}}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "stealpositiveward")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{target_wards = "0,6,6,", last_target_wards = "6,6,6", target_charms = "0,2,", last_target_charms = "1,2", caster_wards = "6,6,6,", last_caster_wards = "0,6,6", caster_charms = "1,2,", last_caster_charms = "0,2"}}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "blade") or string.find(string.lower(file), "weakness")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{
				target_wards = "6,6,6,", last_target_wards = "0,6,6", 
				target_charms = tostring(charm_key_id_mapping[key])..",2,", last_target_charms = "0,2", 
				caster_wards = "6,6,6,", last_caster_wards = "0,6,6", 
				caster_charms = "1,2,", last_caster_charms = "0,2"
			}}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "shield") or string.find(string.lower(file), "trap") or 
				string.find(string.lower(file), "prism") or string.find(string.lower(file), "absorb")) then
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{
				target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", 
				target_charms = "0,2,", last_target_charms = "0,2", 
				caster_wards = "6,6,6,", last_caster_wards = "0,6,6", 
				caster_charms = "1,2,", last_caster_charms = "0,2"
			}}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		else
			-- single spell
			local caster, target = MotionRender_SpellCastViewer.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = "1,2,", last_target_charms = "0,2", caster_wards = "6,6,6,", last_caster_wards = "0,0,6", caster_charms = "1,2,", last_caster_charms = "0,2"}}, MotionRender_SpellCastViewer.SpellFinishedCallback, nil, true, nil, playing_id);
		end
	else
		-- if the arena is not created, use the character and the selected object as the caster and the target
		local caster_char = ParaScene.GetPlayer();
		local target_char = System.obj.GetObject("selection");
		if(caster_char and caster_char:IsValid() == true and target_char and target_char:IsValid() == true) then
			--SpellCast.FaceEachOther(caster_char, target_char)
			SpellCast.EntitySpellCast(nil, caster_char, nil, target_char, nil, file);
		end
	end
end
function MotionRender_SpellCastViewer.StopSpellCasting()
	local self = MotionRender_SpellCastViewer;
	ParaScene.GetAttributeObject():CallField("ClearParticles");
	local k,uid;
	for k,uid in pairs(self.play_id_map) do
		SpellCast.StopSpellCasting(uid);
	end
	self.play_id_map = {};
end
function MotionRender_SpellCastViewer.SpellFinishedCallback()
	--do nothing
end


