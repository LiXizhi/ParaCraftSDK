--[[
Title: CardMovieHelper
Author(s): Leio
Date: 2012/09/27
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/CardMovieHelper.lua");
local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local default_playername = "CardMovieHelper_player"
local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
CardMovieHelper.mcmlNode_cache = {};
CardMovieHelper.card_state = {
	["SendCard"] = "config/Aries/StaticMovies/MotionTemplate/SendCard.xml",
	["RemoveCard"] = "config/Aries/StaticMovies/MotionTemplate/RemoveCard.xml",
	["HideCard"] = "config/Aries/StaticMovies/MotionTemplate/HideCard.xml",
	["RecoverCard"] = "config/Aries/StaticMovies/MotionTemplate/RecoverCard.xml",
}
function CardMovieHelper.GoalActived(runtime_datasource,end_func)
	local file = "config/Aries/StaticMovies/MotionTemplate/GoalActived.xml";
	CardMovieHelper._Play("CardMovieHelper.GoalActived",file,runtime_datasource,end_func)
end
--获取物品
--[[
local runtime_datasource = {
	gsid= 23135,--物品描述
	start_x = 0,
	start_y = 0,
	end_x = 400,
	end_y = 400,
	version = "item",
}
--]]
function CardMovieHelper.GotItem(runtime_datasource,end_func)
	if(not runtime_datasource)then return end
	local file = "config/Aries/StaticMovies/MotionTemplate/GotItem.xml";
	CardMovieHelper._Play("CardMovieHelper.GotItem",file,runtime_datasource,end_func)
end
--recover
--[[
NPL.load("(gl)script/ide/Director/CardMovieHelper.lua");
local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
local oldcards_datasource = {
	[1] = {gsid = 23135, Time = nil,dx = nil, dy = nil,}, --dx dy 和模板位置的偏移
	[2] = {gsid = 23135, },
	[3] = nil,
	[4] = {gsid = 23135, },
	[5] = nil,
	[6] = nil,
	[7] = {gsid = 23135, },
	[8] = {gsid = 23135, },
	duration_delta = 0,--替换后时间增量
	start_dx = 0,--起始位置偏移
	start_dy = 0,
}
local newcards_datasource = {
	[3] = {gsid = 23135, },
	[5] = {gsid = 23135, },
	[6] ={gsid = 23135, },
	duration_delta = 0,--替换后时间增量
	start_dx = 0,--起始位置偏移
	start_dy = 0,
}
CardMovieHelper.RecoverCard(oldcards_datasource,newcards_datasource);
--]]
function CardMovieHelper.RecoverCard(oldcards_datasource,newcards_datasource,end_func)
	local oldcards_playername = "RecoverCard_Player";
	local player = Movie.CreateOrGetPlayer(oldcards_playername);
	player:Clear();
	local default_player = Movie.CreateOrGetPlayer(default_playername);
	default_player:Clear();
	player.end_to_clear = false;
	CardMovieHelper.PlayCardByState(oldcards_playername,"RecoverCard",oldcards_datasource,function()
		CardMovieHelper.PlayCardByState(nil,"SendCard",newcards_datasource,function()
			player:Clear();
			if(end_func)then
				end_func();
			end
		end);
	end);
end
--[[
local runtime_datasource = {
	[1] = {gsid = 23135, },
	[2] = {gsid = 23135, },
	[3] = nil,
	[4] = {gsid = 23135, },
	[5] = nil,
	[6] = nil,
	[7] = {gsid = 23135, },
	[8] = {gsid = 23135, },
}
--]]
function CardMovieHelper.PlayCardByState(playername,state,runtime_datasource,end_func)
	local file = CardMovieHelper.card_state[state];
	if(not file or not runtime_datasource)then return end
	local time_step = 100;
	local dx = 20 + 79;
	local i;
	local index = 0;
	local duration_delta = 0;
	for i = 1,8 do
		local node = runtime_datasource[i];
		if(node)then
			duration_delta = index * time_step;
			node.Time = time_step * index;
			node.dx = dx * (i-1);
			node.dy = 0;
			index = index + 1;
		end

	end
	duration_delta = duration_delta - time_step;
	runtime_datasource.duration_delta = duration_delta;

	CardMovieHelper._Play(playername,file,runtime_datasource,end_func);
end
function CardMovieHelper._Play(playername,file,runtime_datasource,end_func)
	playername = playername or default_playername;
	local player = Movie.CreateOrGetPlayer(playername);
	local function before_play_func(holder,event,movie_mcmlNode)
		local movie_mcmlNode = event.movie_mcmlNode;--数据源 可以动态替换数据
		if(not movie_mcmlNode)then return end
		CardMovieHelper.Replace(movie_mcmlNode,runtime_datasource);
	end
	local function movie_end_func(holder,event)
		if(end_func)then
			end_func();
		end
	end
	player:AddEventListener("before_play",before_play_func,nil,"CardMovieHelper.DoCardMotion before_play");
	player:AddEventListener("movie_end",movie_end_func,nil,"CardMovieHelper.DoCardMotion movie_end");

	local xmlRoot = CardMovieHelper.mcmlNode_cache[file];
	if(not xmlRoot)then
		xmlRoot = ParaXML.LuaXML_ParseFile(file);
		--CardMovieHelper.mcmlNode_cache[file] = xmlRoot;
	end
	xmlRoot = commonlib.deepcopy(xmlRoot);
	player.runtime_datasource = runtime_datasource;
	Movie.DoPlay_ByMcmlNode(playername,xmlRoot);
end
--[[
local runtime_datasource = {
	version = "version", --解析规则
	customdata = customdata,--自定义数据
}
动态替换 <MotionLine Label="CardMotionTemplate"/>

	version = "card"
	tag 命名规则 变量_变量_变量
	1 noreplace(不替换) replace(替换时间和位置) replacexy(只替换位置)
	2 cover(反面) content(正面)
	3 replacedindex(对应 runtime_datasource的索引)

	示例
	local runtime_datasource = {
		[1] = {gsid = 23135, Time = nil,dx = nil, dy = nil,}, --dx dy 和模板位置的偏移
		[2] = {gsid = 23135, },
		[3] = nil,
		[4] = {gsid = 23135, },
		[5] = nil,
		[6] = nil,
		[7] = {gsid = 23135, },
		[8] = {gsid = 23135, },
		duration_delta = 0,--替换后时间增量
		start_dx = 0,--起始位置偏移
		start_dy = 0,
	    version = "card",
	}
	card#noreplace_cover_replacedindex 不替换时间和位置 显示反面 第几张卡牌
	card#replace_content_replacedindex 替换时间和位置 显示正面  第几张卡牌
	card#replacexy_content_replacedindex 只替换位置 显示正面  第几张卡牌

	version = "item"
	tag 命名规则 变量_变量

	示例
	 local runtime_datasource = {
	    gsid= 23135,--物品描述
	    start_x = 0,
	    start_y = 0,
		start_align = "_lt",
	    end_x = 400,
	    end_y = 400,
		end_align = "_lt",
	    version = "item",
    }
	startpos_gsid 替换开始位置
	endpos_gsid 替换结束位置
--]]
function CardMovieHelper.Replace(movie_mcmlNode,runtime_datasource)
	if(not movie_mcmlNode or not runtime_datasource)then return end
	local motion_line_template;
		local node;
		local parent_node;
		for node in commonlib.XPath.eachNode(movie_mcmlNode, "//Motion") do
			parent_node = node;
			break;
		end
		
		for node in commonlib.XPath.eachNode(movie_mcmlNode, "//Motion/MotionLine") do
			local Label = node.attr.Label or "";
			local TargetType = node.attr.TargetType;
			if(TargetType == "Mcml" and Label == "CardMotionTemplate")then
				motion_line_template = node;
				break;
			end
		end
		if(not parent_node or not motion_line_template)then
			return
		end
		local len = #parent_node;
		while(len > 0)do
			local node = parent_node[len];
			local Label = node.attr.Label or "";
			local TargetType = node.attr.TargetType;
			if(TargetType == "Mcml" and Label == "CardMotionTemplate")then
				table.remove(parent_node,len);
			end
			len = len - 1;
		end
		local duration = Movie.GetNumber(parent_node,"Duration");
		local duration_delta = runtime_datasource.duration_delta or 0;
		local version = runtime_datasource.version or "card";
		if(motion_line_template)then
			if(version == "item")then
				local motion_line = commonlib.deepcopy(motion_line_template);
				local frame_node;
				for frame_node in commonlib.XPath.eachNode(motion_line, "/Frame") do
					local tag = Movie.GetString(frame_node,"tag") or "";
					local body_list = Movie.ParseTag(tag);
					local param_1 = body_list[1] or "";
					if(param_1 == "startpos")then
						frame_node.attr.Align = runtime_datasource.start_align or "_lt";
						frame_node.attr.X = runtime_datasource.start_x or 0;
						frame_node.attr.Y = runtime_datasource.start_y or 0;
					elseif(param_1 == "endpos")then
						frame_node.attr.Align = runtime_datasource.end_align or "_lt";
						frame_node.attr.X = runtime_datasource.end_x or 0;
						frame_node.attr.Y = runtime_datasource.end_y or 0;
					end
				end
				table.insert(parent_node,motion_line);
			elseif(version == "card")then
				local has_value = false;
				for i = 1,8 do
					local node = runtime_datasource[i];
					if(node)then
						has_value = true;
						local motion_line = commonlib.deepcopy(motion_line_template);
						local frame_node;
						for frame_node in commonlib.XPath.eachNode(motion_line, "/Frame") do
							local tag = Movie.GetString(frame_node,"tag") or "";
							local body_list = Movie.ParseTag(tag);
							local replace_str,card_state_str,data_index_str = body_list[1],body_list[2],body_list[3];
							replace_str = replace_str or "";
							card_state_str = card_state_str or "";
							data_index_str = data_index_str or "";
							if(replace_str == "replace")then
								frame_node.attr.Time = Movie.GetNumber(frame_node,"Time") + (node.Time or 0);
								frame_node.attr.X = (runtime_datasource.start_dx or 0) + Movie.GetNumber(frame_node,"X")+ (node.dx or 0);
								frame_node.attr.Y = (runtime_datasource.start_dy or 0) + Movie.GetNumber(frame_node,"Y")+ (node.dy or 0);
							elseif(replace_str == "replacexy")then
								frame_node.attr.X = (runtime_datasource.start_dx or 0) + Movie.GetNumber(frame_node,"X")+ (node.dx or 0);
								frame_node.attr.Y = (runtime_datasource.start_dy or 0) + Movie.GetNumber(frame_node,"Y")+ (node.dy or 0);
							end
							frame_node.attr.tag = string.format("%s_%s_%d",replace_str,card_state_str,i);	
						
						end
						table.insert(parent_node,motion_line);
					end
				end
				if(has_value)then
					duration = duration + duration_delta;
					parent_node.attr.Duration = duration;
				else
					parent_node.attr.Duration = 0;
				end
			end
		end
end
function CardMovieHelper.BuildMovieSource_Sequence(old_list,card_source_list)
	if(not old_list or not card_source_list)then return end
	local len = 8;
	local index = 0;
	local function pop()
		index = index + 1;
		return card_source_list[index];
	end
	local result = {};
	local k;
	local empty_cont = 0;
	for k = 1,len do
		local gsid = old_list[k];
		if(not gsid)then
			empty_cont = empty_cont + 1;
		else
			table.insert(result,{
				gsid = gsid,
				from_index = k,
				empty_cont = empty_cont,
			});
		end
	end
	for k = 1,empty_cont do
		local gsid = pop();
		if(gsid)then
			table.insert(result,{
					gsid = gsid,
					from_index = len + 1,
					empty_cont = empty_cont - k + 1,
					is_new = true,
				});
		end
	end
	return result;
end
CardMovieHelper.max_pvp_cnt = 50;
function CardMovieHelper.PreHoldCards(mode,cnt)
	CardMovieHelper.last_cnt = cnt;
	if(mode == "pve")then
		if(cnt <= 0)then
			CardMovieHelper.last_cards = nil;
		end
	elseif(mode == "pvp")then
		if(cnt >= CardMovieHelper.max_pvp_cnt)then
			CardMovieHelper.last_cards = nil;
		end
	end
end
function CardMovieHelper.ResetHoldCards()
	CardMovieHelper.last_cnt = -1;
	CardMovieHelper.last_cards = nil;
end
function CardMovieHelper.HoldCards(cards)
	CardMovieHelper.last_cards = cards;
end
--从卡牌真实的数据源 生成动画数据源
--[[
local old_cards = {
{cooldown_pic_digit1="",gsid=22158,cooldown_pic="",key="Life_SingleAttack_Level1",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=1,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22178,cooldown_pic="",key="Life_LifeDamageTrap",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=2,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=3,bAvailable=false,},
{cooldown_pic_digit1="",gsid=22159,cooldown_pic="",key="Life_SingleAttack_Level2",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=4,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22180,cooldown_pic="",key="Life_LifeGreatShield",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=5,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22158,cooldown_pic="",key="Life_SingleAttack_Level1",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=7,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=8,bAvailable=false,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=9,bAvailable=false,},
Count=8,}
local new_cards = {
{cooldown_pic_digit1="",gsid=22158,cooldown_pic="",key="Life_SingleAttack_Level1",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=1,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22178,cooldown_pic="",key="Life_LifeDamageTrap",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=2,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22159,cooldown_pic="",key="Life_SingleAttack_Level2",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=4,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22180,cooldown_pic="",key="Life_LifeGreatShield",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=5,bAvailable=true,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=8,bAvailable=false,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=9,bAvailable=false,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=10,bAvailable=false,},
{cooldown_pic_digit1="",gsid=22160,cooldown_pic="",key="Life_SingleAttack_Level3",cooldown_pic_digit2="",discarded=false,cooldown=0,seq=11,bAvailable=false,},
Count=8,}

NPL.load("(gl)script/ide/Director/CardMovieHelper.lua");
local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
local old_list,card_source_list = CardMovieHelper.BuildMovieSource(old_cards,new_cards)
echo(old_list);
echo("======card_source_list");
echo(card_source_list);
--]]
function CardMovieHelper.BuildMovieSource(old_cards,new_cards)
	if(not new_cards)then
		return
	end
	if(not old_cards or (#old_cards == 0) )then
		local old_list = {};
		local card_source_list = {};
		local k;
		for k = 1,8 do 
			local node = new_cards[k];
			if(node and node.gsid)then
				table.insert(card_source_list,node.gsid);
			end
		end
		return old_list,card_source_list;
	end
	local old_list = {};
	local card_source_list = {};
	local checked_map = {};
	local old_card_count = #old_cards;
	local max_seq;
	if(old_card_count > 0) then
		max_seq = old_cards[old_card_count].seq or -1;
	end
	local k,new_node;
	for k,new_node in ipairs(new_cards) do
		local new_node_seq = new_node.seq;
		local new_node_gsid = new_node.gsid;
		--新的卡牌
		if(new_node_seq > max_seq)then
			table.insert(card_source_list,new_node_gsid);
		else
			local kk,old_node;
			for kk,old_node in ipairs(old_cards) do
				local old_seq = old_node.seq;
				local old_node_gsid = old_node.gsid;
				--如果没有检查过
				if(new_node_seq == old_seq and not old_list[kk])then
					old_list[kk] = old_node_gsid;
				end
			end
		end
	end
	return old_list,card_source_list;
end
--@param old_list:上一轮卡牌 {[1] = 22102,[3] = 22102,[4] = 22102,}
--@param card_source_list:新的卡牌 {22102,22103,22104,22105,22106,22107,22108,22109,22110,22111,22112,22113,};
function CardMovieHelper.LoadMovieSource(old_list,card_source_list)
	old_list = old_list or {};
	card_source_list = card_source_list or {};
    local len = 8;
    local card_width = 79;
    local card_height = 121;
    local dx = 9;
    local duration = 400;
    local step = 150;
    local result = CardMovieHelper.BuildMovieSource_Sequence(old_list,card_source_list);
    local k;
    local all_str="";
    local RenderParent="movie_item_parent";
    local AssetFile="script/apps/Aries/Animation/CardContent.html"; 
    local index = 0;
    local total_time = 0;
    for k = 1,len do
        local node = result[k];
        if(node)then
            local from_index = node.from_index;
            local empty_cont = node.empty_cont or 0;
            local gsid = node.gsid;
            local is_new = node.is_new;
            local from_x;
            local to_x;
            local from_time = 0;
            local wait_time = 0;
            local to_time = 0;
            local s;
            from_x = (from_index - 1) * (card_width + dx);
            zorder = 1000-k;
            if(empty_cont > 0)then
                to_x = (from_index - empty_cont - 1) * (card_width + dx);
                from_time = index * step;
                wait_time = from_time + step * 2;
                to_time = wait_time+ duration;

                total_time = to_time;
                index = index + 1;
            end
            
            all_str = all_str.. CardMovieHelper.BuildFrames(RenderParent,from_time,wait_time,to_time,from_x,to_x,0,0,card_width,card_height,k,AssetFile,is_new,zorder)
        end
    end
    total_time = total_time + duration + step;
    all_str = string.format([[
     <Motions>
        <Motion Duration="%d" >
             %s
        </Motion>
    </Motions>
    ]],total_time,all_str);
    return all_str;
end
function CardMovieHelper.BuildFrames(RenderParent,from_time,wait_time,to_time,from_x,to_x,from_y,to_y,card_width,card_height,source_index,AssetFile,is_new,zorder)
    local from_str = "";
    local to_str = "";
	--card_width = 151;
	--card_height = 230;
	--local scale_x = 79/151;
	--local scale_y = 120/230;
	local scale_x = 1;
	local scale_y = 1;
    if(from_x)then
        local visible;
        if(is_new)then
            visible = "false";
			from_y = -121;
        else
            visible = "true";
        end
         from_str = string.format([[
<Frame Time="%d" Visible="%s" X="%d" Y="%d" ScaleX="%f" ScaleY="%f" Width="%d" Height="%d" tag="%d" AssetFile="%s" ZOrder="%d" FrameType="easeInQuad"/>
    ]],0,visible,from_x,from_y,scale_x,scale_y,card_width,card_height,source_index,AssetFile,zorder);
    end
   if(to_x)then
         local to_str_1 = string.format([[
<Frame Time="%d" Visible="true" X="%d" Y="%d" ScaleX="%f" ScaleY="%f" Width="%d" Height="%d" tag="%d" AssetFile="%s" ZOrder="%d" />
    ]],wait_time,from_x,from_y,scale_x,scale_y,card_width,card_height,source_index,AssetFile,zorder);
     local to_str_2 = string.format([[
<Frame Time="%d" Visible="true" X="%d" Y="%d" ScaleX="%f" ScaleY="%f" Width="%d" Height="%d" tag="%d" AssetFile="%s" ZOrder="%d" FrameType="easeInQuad"/>
    ]],to_time,to_x,to_y,scale_x,scale_y,card_width,card_height,source_index,AssetFile,zorder);
    to_str = to_str_1..to_str_2;
    end
     local s = string.format([[
<MotionLine TargetType="Mcml" RenderParent="%s" DisableAnim="true">
    %s%s
</MotionLine>
    ]],RenderParent,from_str,to_str);
    return s;
end
