--[[
Title: item system inventory
Author(s): WangTian
Date: 2009/5/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.inventory.lua");
-------------------------------------------------------
]]

-- create class
commonlib.setfield("paraworld.inventory", {});

local isLogInventoryTraffic = true;
local LOG = LOG;
--[[
	/// <summary>
	/// get all bag ids in the inventory that has at least one item in the bag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "bagids" ] = string  // bag ids separated with ","
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
-- NOTE: this service call is not commonly invoked, because the bag ids are implicitly defined in item system.
paraworld.create_wrapper("paraworld.inventory.GetMyBags", "%MAIN%/API/Items/GetMyBags.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetMyBags msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetMyBags msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// get all items in the specific bag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "nid" ] = int  // nid of the user, if nid is provided, sessionkey is omited
	///		[ "sessionkey" ] = string  // session key
	///		[ "bag" ] = string  // bag to be searched
	/// }
	/// </param>
	/// <returns>
	///		[ "items" ] = list{
	///			guid = int  // item instance id
	///			gsid = int
	///			obtaintime = string
	///			position = int
	///			clientdata = string
	///			serverdata = string
	///			copies = int
	///			}  // item count depending on the bag item count
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
local getitemsinbag_cache_policy = "access plus 10 minutes";
paraworld.create_wrapper("paraworld.inventory.GetItemsInBag", "%MAIN%/API/Items/GetItemsInBag.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	msg.nid = tonumber(msg.nid or Map3DSystem.User.nid);
	msg.bag = tonumber(msg.bag);
	
	-- cache policy
	local cache_policy = msg.cache_policy or getitemsinbag_cache_policy;
	if(type(cache_policy) == "string") then
		cache_policy = Map3DSystem.localserver.CachePolicy:new(cache_policy);
	end
	msg.cache_policy = nil;
	
	msg.isfirstinvokeincurrentloginsession = nil;
	
	-- always get from local server if offline mode
	if(paraworld.OfflineMode) then
		cache_policy = Map3DSystem.localserver.CachePolicies["always"];
	end
	
	local ls = Map3DSystem.localserver.CreateStore(nil, 3);
	if(not ls) then
		return;
	end
	
	if(msg.bag) then
		-- if local server has an unexpired result, remove the uid from msg.uid and return the result to callbackFunc otherwise, continue. 
		local HasResult;
		-- make url
		local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "bag", msg.bag, "nid", msg.nid})
		local item = ls:GetItem(url)
		if(item and item.entry and item.payload) then
			if(not cache_policy:IsExpired(item.payload.creation_date)) then
				-- we found an unexpired result for gsid, return the result to callbackFunc
				HasResult = true;
				-- make output msg
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				
				LOG.std("", "debug","Inventory", "unexpired local version for : %s", url)
				
				if(callbackFunc) then
					callbackFunc(output_msg, callbackParams)
				end	
			end
		end
		if(HasResult) then
			-- don't require web API call
			return true;
		end	
		-- commonlib.echo("fetching : "..url)
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBag msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if((msg == nil or msg.items == nil) and inputMsg and inputMsg.bag) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(not ls) then
			return
		end
		local gsItems = {};
		-- if results are not found, we will try local server expired version
		if(inputMsg.bag) then
			-- if local server has an result, remove the gsid from msg.uid and return the result to callbackFunc
			-- make url
			local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "bag", inputMsg.bag, "nid", inputMsg.nid})
			local item = ls:GetItem(url)
			if(item and item.entry and item.payload) then
				-- make output msg
				local lsMsg = commonlib.LoadTableFromString(item.payload.data);
				if(lsMsg and lsMsg.items and lsMsg.items[1]) then
					lsMsg.isexpiredversion = true;
					LOG.std("", "warning","Inventory", "expired GetItemsInBag local version used for %s", tostring(url));
					return lsMsg;
				end	
			end
		end
	elseif(type(msg) == "table" and msg.items) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			-- make output msg
			local output_msg = msg;
			-- make url
			local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "bag", inputMsg.bag, "nid", inputMsg.nid});
			-- if this is the first call of the API skip the setback strategy of the clientdata
			if(not originalMsg.isfirstinvokeincurrentloginsession) then
				local item_ls = ls:GetItem(url)
				if(item_ls and item_ls.entry and item_ls.payload) then
					--
					----------------------------------------------------------------------------------
					-- NOTE: clientdata are implemented as a local priority manner, that is:
					--		1. SetClientData always valids immediately in ItemManager.SetClientData
					--		2. clientdata is updated to the local server in pre function of SetClientData
					--		3. if failed setting afterwards, wait for the next GetItemsInBag
					--			in the next GetItemsInBag post function, newly fetched items are checked with 
					--			the same bag items in local version. if different, 
					--			SetClientData is invoked again to set the clientdata to local version
					--		4. clientdata setting utilizes a lazy setting strategy, only set invoke the call 
					--			when needed: first SetClientData after ItemManager.SetClientData and 
					--			GetItemsInBag on every new coming web traffic
					-- NOTE 2009/12/6: local priority clientdata setting only valids only if the GetItemsInBag API 
					--		is NOT the first call of the current login session
					--		First GetItemsInBag API will always updates the localserver with the server
					----------------------------------------------------------------------------------
					--
					-- make local server version msg
					local msg_ls = commonlib.LoadTableFromString(item_ls.payload.data);
					local clientdata_in_msg_ls = {};
					if(msg_ls and msg_ls.items and msg_ls.items[1]) then
						-- find all non-empty clientdata in local server version
						local _, item_t;
						for _, item_t in pairs(msg_ls.items) do
							if(item_t.guid and item_t.clientdata and item_t.clientdata ~= "") then
								clientdata_in_msg_ls[item_t.guid] = item_t.clientdata;
							end
						end
					end
					if(output_msg and output_msg.items and output_msg.items[1]) then
						-- for currently logged in user bag
						if(inputMsg.nid == Map3DSystem.User.nid) then
							-- traverse through all newly fetched items in bag
							local _, item_t;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.guid and clientdata_in_msg_ls[item_t.guid] 
									and clientdata_in_msg_ls[item_t.guid] ~= item_t.clientdata) then
									-- re-set the clientdata if local version is different to the remote version
									output_msg.items[_].clientdata = clientdata_in_msg_ls[item_t.guid];
									local msg_re_set = {
										guid = item_t.guid,
										bag = inputMsg.bag, 
										clientdata = clientdata_in_msg_ls[item_t.guid],
									};
									local id = ParaGlobal.GenerateUniqueID();
									paraworld.inventory.SetClientData(msg_re_set, "ResetClientData_"..id, function(msg)
										if(msg.issuccess == false) then
											LOG.std("", "error","Inventory", "failed re-set clientdata of item (guid:"..tostring(item_t.guid)..")");
										end
									end);
								end
							end
						end
					end
					commonlib.echo(output_msg);
				end
			end
			
			-- make entry
			local item = {
				entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({
					url = url,
				}),
				payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
					status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
					data = commonlib.serialize_compact(output_msg),
				}),
			}
			-- save to database entry
			local res = ls:PutItem(item);
			if(res) then 
				LOG.std("", "debug","Inventory", {url, inputMsg, msg, })
				LOG.std("", "debug","Inventory", tostring(#(msg.items)).." Bag Items of %s saved to local server", tostring(url));
			else	
				LOG.std("", "warning","Inventory", "failed saving global store template info of %s to local server", tostring(url))
				LOG.std("", "warning","Inventory", output_msg);
			end
			if(isLogInventoryTraffic) then
				LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBag msg_out:");
				LOG.std("", "debug","Inventory", msg);
			end
		end -- if(ls) then
	else
		LOG.std("", "error","Inventory", "paraworld.inventory.GetItemsInBag: unsupported message format")	
		LOG.std("", "error","Inventory", msg);
	end
end);


--[[
http://pedn/KidsDev/Items
        /// <summary>
        /// 取得指定用户指定的一组包中的所有数据
        /// 接收参数：
        ///     nid
        ///     bags  包ID，多个包ID之间用英文逗号分隔
        /// 返回值：
        ///     list [list]
        ///         bag  包ID
        ///         items [list]
        ///             guid = int  // item instance id
        ///             gsid = int
        ///             obtaintime = string yyyy-MM-dd HH:mm:ss
        ///             position = int
        ///             clientdata = string
        ///             serverdata = string
        ///             copies = int
        ///      [ errorcode ]
        /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.GetItemsInBags", "%MAIN%/API/Items/GetItemsInBags", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	msg.nid = tonumber(msg.nid or Map3DSystem.User.nid);
	
	-- we don't allow GetItemsInBags to be called with cache_policy
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBags msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg and not msg.errorcode) then
		-- if no items in bag, the message doesn't contain the bag item block
		-- keep a record of the unreturned bags
		local emptybags = {};
        local bag;
        for bag in string.gfind(inputMsg.bags, "([^,]+)") do 
			bag = tonumber(bag);
			emptybags[bag] = true;
        end
		
		local _, onebagmsg;
		for _, onebagmsg in ipairs(msg.list) do
			local msg = onebagmsg;
			if(msg == nil or msg.items == nil) then
				-- skip the unexpired local server data
			elseif(type(msg) == "table" and msg.items and msg.bag) then
				-- remove from the empty bags
				emptybags[msg.bag] = nil;
				local ls = Map3DSystem.localserver.CreateStore(nil, 3);
				if(ls) then
					-- make output msg
					local output_msg = {items = msg.items};
					-- make url
					local url = NPL.EncodeURLQuery(paraworld.inventory.GetItemsInBag.GetUrl(), {"format", 1, "bag", msg.bag, "nid", inputMsg.nid});
					-- if this is the first call of the API skip the setback strategy of the clientdata
					-- NOTE: no set back clientdata is supported for GetItemsInBags
					
					-- make entry
					local item = {
						entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({
							url = url,
						}),
						payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
							status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
							data = commonlib.serialize_compact(output_msg),
						}),
					}
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "debug","Inventory", {url, {nid = inputMsg.nid, bag = msg.bag}, msg, })
						LOG.std("", "debug","Inventory", tostring(#(msg.items)).." Bag Items of %s saved to local server during GetItemsInBags", tostring(url));
					else	
						LOG.std("", "warning","Inventory", "failed saving global store template info of %s to local server during GetItemsInBags", tostring(url))
						LOG.std("", "warning","Inventory", output_msg);
					end
				end -- if(ls) then
			else
				LOG.std("", "error","Inventory", "paraworld.inventory.GetItemsInBags: unsupported message format")	
				LOG.std("", "error","Inventory", msg);
			end
		end
		
		local bag;
		for bag, _ in pairs(emptybags) do
			local ls = Map3DSystem.localserver.CreateStore(nil, 3);
			if(ls) then
				-- make output msg
				local output_msg = {items = {}};
				-- make url
				local url = NPL.EncodeURLQuery(paraworld.inventory.GetItemsInBag.GetUrl(), {"format", 1, "bag", bag, "nid", inputMsg.nid});
				-- if this is the first call of the API skip the setback strategy of the clientdata
				-- NOTE: no set back clientdata is supported for GetItemsInBags
				
				-- make entry
				local item = {
					entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({
						url = url,
					}),
					payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
						status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
						data = commonlib.serialize_compact(output_msg),
					}),
				}
				-- save to database entry
				local res = ls:PutItem(item);
				if(res) then 
					LOG.std("", "debug","Inventory", "Empty Bag Items of %s saved to local server during GetItemsInBags", tostring(url));
				else	
					LOG.std("", "warning","Inventory", "warning: failed saving global store template info of %s to local server during GetItemsInBags", tostring(url))
					LOG.std("", "warning","Inventory", output_msg);
				end
			end -- if(ls) then
		end
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInBags msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end);



--[[
	/// <summary>
	/// purchase the item directly through global store id
	/// the item is then put into the default bag specified in BagFamily
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "gsid" ] = int  // global store id
	///		[ "count" ] = int  // purchase count
	///		[ "clientdata" ] = string  // (optional) clientdata that set to the newly purchased item
	///									NOTE: the clientdata is not garanteed, since the item could be stacked on existing item and respawn new entry
	///											if exceeds MaxCopiesInStack. Although in Aries project we assume all items is MaxCopiesInStack == MaxCount
	///											The only exception is the homeland bag 10001 ~ 10009, items distribute as single copy items even stackable. 
	///											No bagfamily is homeland bag.
	///											Clientdata is only set if the item is a NEW entry.
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "guid" ] = int   // the newly purchased item guid
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								not enough money, p&/e cash
	///								for monthly paid user only
	///								too many copies, exceed MaxCount (mostly unique items)
	///								too many items, exceed the category capacity
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.PurchaseItem", "%MAIN%/API/Items/PurchaseItem.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.PurchaseItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(inputMsg.gsid);
			if(gsItem) then
				local bagfamily = gsItem.template.bagfamily;
				local inventorytype = gsItem.template.inventorytype;
				
				-- pass 1: update the items in bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									break;
								end
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after PurchaseItem", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after PurchaseItem", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- find the largest position in the bag
							local _, item_t;
							local max_position = 0;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.position > max_position) then
									max_position = item_t.position;
								end
							end
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								local position = max_position + 1;
								if(inventorytype ~= 0 and bagfamily == 0) then
									-- inventorytype specifies the position of the item if bagfamily is 0
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0) then
									LOG.std("", "error","Inventory", " inventorytype and bagfamily are both 0 for gsid:"..inputMsg.gsid..", check global store item template");
									return;
								end
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = inputMsg.gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = position,
									clientdata = inputMsg.clientdata or "",
									serverdata = "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s added to local server after PurchaseItem", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding bag items of %s to local server after PurchaseItem", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 2: update the user info
				local url_getinfo = paraworld.users.getInfo.GetUrl();
				local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
				fields = string.lower(commonlib.Encoding.SortCSVString(fields));
				local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid, "fields", fields})
				local item = ls:GetItem(url_getinfo)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(type(output_msg) == "table" and output_msg.users) then
						-- NOTE 2010/1/21: update the emoney update source from globalstore to purchaseitem return message
						-- update the $E, using the return message
						local _, user;
						for _, user in ipairs(output_msg.users) do
							if(user.nid == Map3DSystem.User.nid) then
								output_msg.users[_].emoney = user.emoney + msg.deltaemoney;
							end
						end
						---- update the $P and $E, using the global store item price
						--local _, user;
						--for _, user in ipairs(output_msg.users) do
							--if(user.nid == Map3DSystem.User.nid) then
								--local gsItem = paraworld.globalstore.gettemplateinlocalserver(inputMsg.gsid);
								--if(gsItem) then
									--output_msg.users[_].emoney = user.emoney - gsItem.ebuyprice * inputMsg.count;
									--output_msg.users[_].pmoney = user.pmoney - gsItem.pbuyprice * inputMsg.count;
									--break;
								--end
							--end
						--end
						-- make entry
						local item = {
							entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
							payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
								status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
								data = commonlib.serialize_compact(output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "User info of %s updated to local server after PurchaseItem", tostring(url_getinfo));
						else	
							LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after PurchaseItem", tostring(url_getinfo))
							LOG.std("", "warning","Inventory", output_msg);
						end
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.PurchaseItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);



--[[
	/// <summary>
	/// move the item from one bag to another, NOTE: all items must be in the same srcbag and move to the same dstbag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "items" ] = string  // item instance ids separated with "," and "|", e.x. guid1,count1|guid2,count2|guid3,count3|guid4,count4
	///		[ "srcbag" ] = int  // source bag   <---  NOTE: CYF require this field for cache optimization, 2009/5/31
	///		[ "dstbag" ] = int  // destination bag
	///		[ "clientdata" ] = string  // clientdata to be set to the item if and only the item created a new instance on the dstbag
	///		
	///		NOTE: suppose we have items:"1001,1|2002,10|3003,2" srcbag:"21" dstbag:"10001" 
	///		the service call will move 1 copy of item 1001 to bag 21, 10 copy of item 2002 to bag 21 and 2 copy of item 3003 from bag 21 to bag 10001
	///		
	///		NOTE: 
	///		maximum types of items per request is 10
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								guids and counts number don't match
	///								request item count exceed existing count
	///								target bag is full, exceed the category capacity
	///								too many item counts
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.MoveItems", "%MAIN%/API/Items/MoveItems.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.MoveItems msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			-- parse items into guid and count pairs
			local guid, count;
			for guid, count in string.gfind(inputMsg.items, "([^,^|]+),([^,^|]+)") do
				guid = tonumber(guid);
				count = tonumber(count);
				local sourceItem_gsid;
				-- pass 1: remove the item in the source bag
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.srcbag, "nid", Map3DSystem.User.nid});
				local item = ls:GetItem(url);
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.guid == guid) then
								item.copies = item.copies - count;
								sourceItem_gsid = item.gsid;
								break;
							end
						end
						-- make entry
						local item = {
							entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url,}),
							payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
								status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
								data = commonlib.serialize_compact(output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "Source Bag Items of %s updated to local server after MoveItems", tostring(url));
						else	
							LOG.std("", "warning","Inventory", "failed updating source bag items of %s to local server after MoveItems", tostring(url))
							LOG.std("", "warning","Inventory", output_msg);
						end
					end
				end
				if(not sourceItem_gsid) then
					LOG.std("", "error","Inventory", " couldn't find source item gsid in local server cache after MoveItems");
					return;
				end
				-- pass 2: update the items in the destination bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									break;
								end
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Dest Bag Items of %s updated to local server after MoveItems", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating dest bag items of %s to local server after MoveItems", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				-- pass 3: append the items in the destination bag
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = sourceItem_gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = add.position,
									clientdata = inputMsg.clientdata or "",
									serverdata = "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Dest Bag Items of %s added to local server after MoveItems", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding dest bag items of %s to local server after MoveItems", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.MoveItems msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// equip the item in character slot
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = int  // item instance id
	///		[ "bag" ] = int  // NOTE: CYF require this field for cache optimization
	///		[ "clientdata" ] = string  // (optional) clientdata to be set
	///		[ "position" ] = int // NOTE: for local server optimization, added by andy 2009/8/4 
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								the item can't be mount to character slot, not clothes or hand-held items
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.EquipItem", "%MAIN%/API/Items/EquipItem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	msg.position = nil;
	msg.fromposition = nil;
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.EquipItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg.issuccess == true) then
		-- if originalMsg.fromposition is nil, skip local server write
		if(originalMsg.fromposition ~= nil) then
			local ls = Map3DSystem.localserver.CreateStore(nil, 3);
			if(ls) then
				-- unequip the item if position slot has item
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url_0 = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", 0, "nid", Map3DSystem.User.nid})
				local item = ls:GetItem(url_0)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						local unEquipedItem;
						-- remove from the equip bag
						local newOutput = {};
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.position == originalMsg.position) then
								unEquipedItem = commonlib.deepcopy(item);
								output_msg.items[_] = nil;
							else
								table.insert(newOutput, commonlib.deepcopy(item));
							end
						end
						output_msg = {items = newOutput};
						if(unEquipedItem and unEquipedItem.guid) then
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_0,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_0));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_0))
								LOG.std("", "warning","Inventory", output_msg);
							end
							
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(unEquipedItem.gsid);
							if(gsItem) then
								local bagfamily = gsItem.template.bagfamily;
								-- put in the bagfamily bag
								local url_bagfamily = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", bagfamily, "nid", Map3DSystem.User.nid})
								local item = ls:GetItem(url_bagfamily);
								if(item and item.entry and item.payload) then
									local output_msg = commonlib.LoadTableFromString(item.payload.data);
									if(output_msg and output_msg.items) then
										-- find the largest position in the bag
										local guid_t, item_t;
										local max_position = 0;
										for guid_t, item_t in pairs(output_msg.items) do
											if(item_t.position > max_position) then
												max_position = item_t.position;
											end
										end
										if(inputMsg.bag == bagfamily) then
											-- use the original item position to perform an item swap
											unEquipedItem.position = originalMsg.fromposition;
										else
											-- append to the tail of the bag items
											unEquipedItem.position = max_position + 1;
										end
										table.insert(output_msg.items, unEquipedItem);
										-- make entry
										local item = {
											entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_bagfamily,}),
											payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
												status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
												data = commonlib.serialize_compact(output_msg),
											}),
										}
										-- save to database entry
										local res = ls:PutItem(item);
										if(res) then 
											LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_bagfamily));
										else	
											LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_bagfamily));
											LOG.std("", "warning","Inventory", output_msg);
										end
									end
								end
							end
						end
					end
				end
				-- equip the item
				local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
				local url_bag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.bag, "nid", Map3DSystem.User.nid})
				local item = ls:GetItem(url_bag)
				if(item and item.entry and item.payload) then
					local output_msg = commonlib.LoadTableFromString(item.payload.data);
					if(output_msg and output_msg.items) then
						local equipedItem;
						-- remove from the original bag
						local newOutput = {};
						local _, item;
						for _, item in ipairs(output_msg.items) do
							if(item.guid == inputMsg.guid) then
								equipedItem = commonlib.deepcopy(item);
								output_msg.items[_] = nil;
							else
								table.insert(newOutput, commonlib.deepcopy(item));
							end
						end
						output_msg = {items = newOutput};
						if(equipedItem.guid) then
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_bag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_bag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_bag))
								LOG.std("", "warning","Inventory", output_msg);
							end
							
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(equipedItem.gsid);
							if(gsItem) then
								local bagfamily = gsItem.template.bagfamily;
								-- put in the bagfamily bag
								local url_0 = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", 0, "nid", Map3DSystem.User.nid})
								local item = ls:GetItem(url_0);
								if(item and item.entry and item.payload) then
									local output_msg = commonlib.LoadTableFromString(item.payload.data);
									if(output_msg and output_msg.items) then
										equipedItem.position = originalMsg.position;
										equipedItem.bag = 0;
										table.insert(output_msg.items, equipedItem);
										-- make entry
										local item = {
											entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_0,}),
											payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
												status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
												data = commonlib.serialize_compact(output_msg),
											}),
										}
										-- save to database entry
										local res = ls:PutItem(item);
										if(res) then 
											LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after EquipItem", tostring(url_0));
										else	
											LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after EquipItem", tostring(url_0));
											LOG.std("", "warning","Inventory", output_msg);
										end
									end
								end
							end
						end
					end
				end
			end -- if(ls) then
		end
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.EquipItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// unequip the item in character slot
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "position" ] = int  // position in character slot bag 0
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.UnEquipItem", "%MAIN%/API/Items/UnEquipItem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.UnEquipItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
			local url_0 = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", 0, "nid", Map3DSystem.User.nid})
			local item = ls:GetItem(url_0)
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(output_msg and output_msg.items) then
					local unEquipedItem;
					-- remove from the equip bag
					local newOutput = {};
					local _, item;
					for _, item in ipairs(output_msg.items) do
						if(item.position == inputMsg.position) then
							unEquipedItem = commonlib.deepcopy(item);
							output_msg.items[_] = nil;
						else
							table.insert(newOutput, commonlib.deepcopy(item));
						end
					end
					output_msg = {items = newOutput};
					if(unEquipedItem.guid) then
						-- make entry
						local item = {
							entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_0,}),
							payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
								status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
								data = commonlib.serialize_compact(output_msg),
							}),
						}
						-- save to database entry
						local res = ls:PutItem(item);
						if(res) then 
							LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after UnEquipItem", tostring(url_0));
						else	
							LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after UnEquipItem", tostring(url_0))
							LOG.std("", "warning","Inventory", output_msg);
						end
						
						local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(unEquipedItem.gsid);
						if(gsItem) then
							local bagfamily = gsItem.template.bagfamily;
							-- put in the bagfamily bag
							local url_bagfamily = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", bagfamily, "nid", Map3DSystem.User.nid})
							local item = ls:GetItem(url_bagfamily);
							if(item and item.entry and item.payload) then
								local output_msg = commonlib.LoadTableFromString(item.payload.data);
								if(output_msg and output_msg.items) then
									-- find the largest position in the bag
									local guid_t, item_t;
									local max_position = 0;
									for guid_t, item_t in pairs(output_msg.items) do
										if(item_t.position > max_position) then
											max_position = item_t.position;
										end
									end
									unEquipedItem.position = max_position + 1;
									table.insert(output_msg.items, unEquipedItem);
									-- make entry
									local item = {
										entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_bagfamily,}),
										payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
											status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
											data = commonlib.serialize_compact(output_msg),
										}),
									}
									-- save to database entry
									local res = ls:PutItem(item);
									if(res) then 
										LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after UnEquipItem", tostring(url_bagfamily));
									else	
										LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after UnEquipItem", tostring(url_bagfamily));
										LOG.std("", "warning","Inventory", output_msg);
									end
								end
							end
						end
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.UnEquipItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);


--[[
	/// <summary>
	/// destroy the item directly through item instance id
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = int  // item instance id
	///		[ "count" ] = int  // destroy count
	///		[ "bag" ] = int  // NOTE: CYF require this field for cache optimization, 2009/5/27
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								item doesn't exist
	///								request item count exceed existing count
	///								item can't be destroyed
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.DestroyItem", "%MAIN%/API/Items/DestroyItem.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.DestroyItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	
	if(msg.issuccess == true) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
			local url = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.bag, "nid", Map3DSystem.User.nid})
			local item = ls:GetItem(url)
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(output_msg and output_msg.items) then
					local _, item;
					for _, item in ipairs(output_msg.items) do
						if(item.guid == inputMsg.guid) then
							item.copies = item.copies - inputMsg.count;
							break;
						end
					end
					-- make entry
					local item = {
						entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url,}),
						payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
							status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
							data = commonlib.serialize_compact(output_msg),
						}),
					}
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after DestroyItem", tostring(url));
					else	
						LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after DestroyItem", tostring(url))
						LOG.std("", "warning","Inventory", output_msg);
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.DestroyItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);



--[[
	/// <summary>
	/// purchase item with non monetary price, be it profession items, monthly owned items or any combination of the above
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "buy_gsids" ] = string  // global store ids separated with ","
	///		[ "buy_counts" ] = string  // buy item counts separated with ","
	///		[ "cost_guids" ] = string  // item instance ids separated with ","
	///		[ "cost_counts" ] = string  // item counts separated with ","
	///		CYF: 用cost_guids来换buy_gsids这里的物品, 这里先做一个秘密的API专门干这件事的
	///			比如cost_guids "12,34", cost_counts "1,1", buy_gsids "38432,2082,98021", buy_counts "1,2,1"
	///			用一个12(guid) 一个34(guid) 换一个38432(gsid) 两个2082(gsid) 一个98021(gsid)
	///			比如cost_guids "12,34", cost_counts "1,-1", buy_gsids "38432", buy_counts "1"
	///			用一个12(guid) 一个34(guid) 换一个38432(gsid), 但是34不删除, 34 -1的意思是交换时要有1个34,而34不删除
	///			或者上面的相当于cost_guids "12,34", cost_counts "1,1", buy_gsids "38432,3798", buy_counts "1,1" (假设guid12的gsid是5434, guid34的gsid是3798)
	///				5434是白菜 3798是菜刀 38432是白菜丁
	///			注意分别是guid和gsid, 
	///				再注意 这里的得到的物品也要象purchase一样,比如通过PurchaseItemExtended购买坐骑的初始化,如果在这里得到也要初始化
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								cost item doesn't exist
	///								not enough cost item count
	///								too many buy item copies, exceed MaxCount (mostly unique items)
	///								too many buy items, exceed the category capacity
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
-- TODO: M3
--paraworld.create_wrapper("paraworld.inventory.PurchaseItemExtended", "%MAIN%/API/Items/PurchaseItemExtended.ashx");


--[[
        /// <summary>
        /// 当前登录用户执行某个兑换
        /// 接收参数：
        ///     nid
        ///     exID 定制的兑换的ID
        ///     froms 客户端选定的用户兑换的物品，guid,cnt|guid,cnt|guid,cnt|......
        /// 返回值：
        ///     issuccess
        ///     [ updates ][list] 输出兑换后叠加在旧数据上的物品
        ///         guid
        ///         bag
        ///         cnt
        ///     [ adds ][list] 输出兑换后新增的数据
        ///         guid
        ///         gsid
        ///         bag
        ///         cnt
        ///         position
        ///     [ stats ][list] 输出兑换后各属性值的变化
        ///         gsid  -1:P币；0:E币；-2:亲密度；-3:爱心值；-4:力量值；-5:敏捷值；-6:智慧值；-7:建筑熟练度
        ///         cnt
        ///     [ errorcode ]
        /// </summary>
        
paraworld.inventory.Test_ExtendedCost return:
echo:return { adds={  }, issuccess=true, updates={ { bag=12, cnt=1, guid=557 } } }
]]
paraworld.create_wrapper("paraworld.inventory.ExtendedCost", "%MAIN%/API/Items/ExtendedCost.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end
	local exTemplate = paraworld.inventory.getextendedcostinlocalserver(msg.exid);
	if(not exTemplate) then
		LOG.std("", "debug","Inventory", "warning: empty extended cost template not valid in local server when trying to invoke paraworld.inventory.ExtendedCost service call");
		LOG.std("", "debug","Inventory", "    exid:"..msg.exid.."")
	end
	-- remove the frombags field of the input message
	msg.frombags = nil;
	msg.mymountpetguid = nil;
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ExtendedCost msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	if(msg.issuccess == true) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			local exTemplate = paraworld.inventory.getextendedcostinlocalserver(inputMsg.exid);
			if(exTemplate) then
				--local bagfamily = gsItem.template.bagfamily;
				--local inventorytype = gsItem.template.inventorytype;
				
				-- pass 1: remove the items in bag, according to the froms section of exTemplate
				local froms = {};
				local i = 1;
				local guid, cnt;
				for guid, cnt in string.gmatch(originalMsg.froms, "(%d+),(%d+)|") do
					-- if guid == 0 stands for $E cash
					guid = tonumber(guid);
					cnt = tonumber(cnt);
					if(guid > 0) then
						froms[i] = {guid = guid, cnt = cnt, bag = originalMsg.frombags[i]};
					end
					i = i + 1;
				end
				local _, from;
				for _, from in pairs(froms) do
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", from.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- remove the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == from.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies - from.cnt;
									if(output_msg.items[_].copies < 0) then
										LOG.std("", "error","Inventory", " negitive copies got in ExtendedCost remove process");
										LOG.std("", "debug","Inventory", "original message:");
										commonlib.echo(originalMsg);
										LOG.std("", "debug","Inventory", "receive message:");
										LOG.std("", "debug","Inventory", msg);
									end
									break;
								end
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s removed to local server after ExtendedCost", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed removing bag items of %s to local server after ExtendedCost", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 2: update the items in bag
				local _, update;
				for _, update in ipairs(msg.updates) do
					-- stack to existing items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", update.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- update the copies
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == update.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + update.cnt;
									update.gsid_fromlocalserver = item.gsid;
									break;
								end
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after ExtendedCost", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after ExtendedCost", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				-- pass 3: add the items in bag
				local _, add;
				for _, add in ipairs(msg.adds) do
					-- newly created items
					local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
					local url_getitemsinbag = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", add.bag, "nid", Map3DSystem.User.nid})
					local item = ls:GetItem(url_getitemsinbag);
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.items) then
							-- find the largest position in the bag
							local _, item_t;
							local max_position = 0;
							for _, item_t in pairs(output_msg.items) do
								if(item_t.position > max_position) then
									max_position = item_t.position;
								end
							end
							-- add item into bag
							local isExist = false;
							local _, item;
							for _, item in ipairs(output_msg.items) do
								if(item.guid == msg.guid) then
									output_msg.items[_].copies = output_msg.items[_].copies + add.cnt;
									-- item already exist in bag with the same guid
									LOG.std("", "error","Inventory", " item already exist in bag with the same guid:"..tostring(add.guid).." Count appended.");
									isExist = true;
									break;
								end
							end
							if(isExist == false) then
								local position = max_position + 1;
								local bagfamily;
								local inventorytype;
								local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(add.gsid);
								if(gsItem) then
									bagfamily = gsItem.template.bagfamily;
									inventorytype = gsItem.template.inventorytype;
								end
								if(inventorytype ~= 0 and bagfamily == 0) then
									-- inventorytype specifies the position of the item if bagfamily is 0
									position = inventorytype;
								elseif(inventorytype == 0 and bagfamily == 0) then
									LOG.std("", "error","Inventory", " inventorytype and bagfamily are both 0 for gsid:"..add.gsid..", check global store item template");
									return;
								end
								table.insert(output_msg.items, {
									guid = add.guid, 
									gsid = add.gsid,
									obtaintime = ParaGlobal.GetDateFormat("yyyy-MM-dd").." "..ParaGlobal.GetTimeFormat("HH:mm:ss"),
									-- use the local time as the temporary obtain time, "8/3/2009 7:06:43 PM"
									position = position,
									clientdata = "",
									serverdata = "",
									copies = add.cnt,
								});
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getitemsinbag,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "Bag Items of %s added to local server after ExtendedCost", tostring(url_getitemsinbag));
							else	
								LOG.std("", "warning","Inventory", "failed adding bag items of %s to local server after ExtendedCost", tostring(url_getitemsinbag))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 4: update the user info
				local pmoney_delta = 0;
				local emoney_delta = 0;
				if(msg.stats) then
					local _, stat;
					for _, stat in pairs(msg.stats) do
						if(stat.gsid == 0) then
							emoney_delta = stat.cnt;
						end
					end
				end
				--local _, entry;
				--for _, entry in pairs(exTemplate.froms or {}) do
					--if(entry.key == -1) then -- $p cash
						--pmoney_delta = pmoney_delta - entry.value;
					--elseif(entry.key == 0) then -- $e cash
						--emoney_delta = emoney_delta - entry.value;
					--end
				--end
				--local _, entry;
				--for _, entry in pairs(exTemplate.tos or {}) do
					--if(entry.key == -1) then -- $p cash
						--pmoney_delta = pmoney_delta + entry.value;
					--elseif(entry.key == 0) then -- $e cash
						--emoney_delta = emoney_delta + entry.value;
					--end
				--end
				if(pmoney_delta ~= 0 or emoney_delta ~= 0) then
					-- if no money changed, skip the user info update
					local url_getinfo = paraworld.users.getInfo.GetUrl();
					local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
					fields = string.lower(commonlib.Encoding.SortCSVString(fields));
					local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid, "fields", fields})
					local item = ls:GetItem(url_getinfo)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(type(output_msg) == "table" and output_msg.users) then
							-- update the $P and $E
							local _, user;
							for _, user in ipairs(output_msg.users) do
								if(user.nid == Map3DSystem.User.nid) then
									output_msg.users[_].emoney = user.emoney + emoney_delta;
									output_msg.users[_].pmoney = user.pmoney + pmoney_delta;
									break;
								end
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "User info of %s updated to local server after ExtendedCost", tostring(url_getinfo));
							else	
								LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after ExtendedCost", tostring(url_getinfo))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end -- if(pmoney_delta ~= 0 or emoney_delta ~= 0) then
				
				-- pass 5: update the user mount pet info if necessary
				local mymountpetguid = originalMsg.mymountpetguid;
				if(mymountpetguid and msg.stats) then
					-- update the petevolved.get infomation
					local url_petevolved_get = paraworld.homeland.petevolved.Get.GetUrl();
					url_petevolved_get = NPL.EncodeURLQuery(url_petevolved_get, {"format", 1, "nid", Map3DSystem.User.nid, "id", mymountpetguid});
					local item = ls:GetItem(url_petevolved_get)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(output_msg and output_msg.health) then
							local _, stat;
							for _, stat in pairs(msg.stats) do
								if(stat.gsid == -3) then
									output_msg.kindness = output_msg.kindness + stat.cnt;
								elseif(stat.gsid == -4) then
									output_msg.strength = output_msg.strength + stat.cnt;
								elseif(stat.gsid == -5) then
									output_msg.agility = output_msg.agility + stat.cnt;
								elseif(stat.gsid == -6) then
									output_msg.intelligence = output_msg.intelligence + stat.cnt;
								elseif(stat.gsid == -7) then
									output_msg.archskillpts = output_msg.archskillpts + stat.cnt;
								end
							end
							
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_petevolved_get,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then
								LOG.std("", "debug","Inventory", "Pet info of %s updated to local server after ExtendedCost", tostring(url_petevolved_get));
							else
								LOG.std("", "warning","Inventory", "failed updating pet info of %s to local server after ExtendedCost", tostring(url_petevolved_get));
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
				end
				
				-- pass 6: calculate all obtains
				local obtains = {};
				local _, update;
				for _, update in ipairs(msg.updates) do
					if(update.gsid_fromlocalserver) then
						local gsid = update.gsid_fromlocalserver;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + update.cnt;
					end
				end
				local _, add;
				for _, add in ipairs(msg.adds) do
					if(add.gsid) then
						local gsid = add.gsid;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + add.cnt;
					end
				end
				local _, stat;
				for _, stat in pairs(msg.stats) do
					if(stat.gsid) then
						local gsid = stat.gsid;
						obtains[gsid] = obtains[gsid] or 0;
						obtains[gsid] = obtains[gsid] + stat.cnt;
					end
				end
				msg.obtains = obtains;
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.ExtendedCost msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);

--[[
    /// <summary>
    /// 取得指定的物品兑换规则
    /// 接收参数：
    ///     exID 兑换规则的ID
    /// 返回值：
    ///     exname
    ///     froms[list]
    ///         key
    ///         value
    ///     tos[list]
    ///         key
    ///         value
    ///     pres[list] 先决条件
    ///         key
    ///         value
    ///     [ errorcode ]
    /// </summary>
sample return
paraworld.inventory.Test_GetExtendedCost return:
echo:return {
  exname="test_17008_HoneyCrystal_to_17009_BeehiveWorm",
  froms={ { key=17008, value=1 } },
  pres={ { key=17010, value=1 } },
  tos={ { key=17009, value=1 } } 
}
]]
local get_extendedcost_cache_policy = Map3DSystem.localserver.CachePolicies["always"];
paraworld.create_wrapper("paraworld.inventory.GetExtendedCost", "%MAIN%/API/Items/GetExtendedCost.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	-- make sure exid is number
	if(type(msg.exid) == "string") then
		msg.exid = tonumber(msg.exid);
	end
	
	-- cache policy
	local cache_policy = msg.cache_policy or get_extendedcost_cache_policy;
	if(type(cache_policy) == "string") then
		cache_policy = Map3DSystem.localserver.CachePolicy:new(cache_policy);
	end
	msg.cache_policy = nil;
	
	-- always get from local server if offline mode
	if(paraworld.OfflineMode) then
		cache_policy = Map3DSystem.localserver.CachePolicies["always"];
	end
	
	local HasResult = false;
	local ls = Map3DSystem.localserver.CreateStore(nil, 3, "extendedcost");
	if(ls) then
		-- make url
		local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "exid", msg.exid, })
		local item = ls:GetItem(url)
		if(item and item.entry and item.payload) then
			if(not cache_policy:IsExpired(item.payload.creation_date)) then
				-- we found an unexpired result for exid, return the result to callbackFunc
				HasResult = true;
				-- make output msg
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				-- LOG.std("", "debug","Inventory", "unexpired extended cost template for url:"..url.."");
				--commonlib.echo(output_msg);
				if(output_msg and not output_msg.errorcode) then
					if(callbackFunc) then
						callbackFunc(output_msg, callbackParams);
					end
				end
			end
		end
	end
	if(HasResult == true) then
		-- don't require web API call
		return true;
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(type(msg) == "table" and not msg.errorcode) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3, "extendedcost");
		if(ls) then
			-- make output msg
			local output_msg = msg;
			-- make url
			local url = NPL.EncodeURLQuery(self.GetUrl(), {"format", 1, "exid", inputMsg.exid, })
			
			-- make entry
			local item = {
				entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({
					url = url,
				}),
				payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
					status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
					data = output_msg,
				}),
			}
			-- save to database entry
			local res = ls:PutItem(item);
			if(res) then 
				LOG.std("", "debug","Inventory", "extended cost template info of %s saved to local server", tostring(url));
			else	
				LOG.std("", "warning","Inventory", "failed saving extended cost template info of %s to local server", tostring(url))
				LOG.std("", "warning","Inventory", output_msg);
			end
		end -- if(ls) then
	end
end);

-- read the extended cost template in local server
-- @return: extended cost template in table or nil if not valid in local server
function paraworld.inventory.getextendedcostinlocalserver(exid)
	exid = tonumber(exid);
	local url_get = paraworld.inventory.GetExtendedCost.GetUrl();
	local url_get = NPL.EncodeURLQuery(url_get, {"format", 1, "exid", exid, })
	local ls = Map3DSystem.localserver.CreateStore(nil, 3, "extendedcost");
	if(ls) then
		local item = ls:GetItem(url_get);
		if(item and item.entry and item.payload) then
			local output_msg = commonlib.LoadTableFromString(item.payload.data);
			if(output_msg and not output_msg.errorcode) then
				return output_msg;
			end
		end
	end
end


--[[
    /// <summary>
    /// 取得所有的物品兑换规则（分页）
    /// 接收参数：
    ///     pageIndex
    ///     pageSize 最大20
    /// 返回值：
    ///     pageCnt 共多少页
    ///     exs[list]
    ///         exname
    ///         froms[list]
    ///             key
    ///             value
    ///         tos[list]
    ///             key
    ///             value
    ///         pres[list] 先决条件
    ///             key
    ///             value
    ///     [ errorcode ]
    /// </summary>
]]
paraworld.create_wrapper("paraworld.inventory.GetExtendedCostOfPage", "%MAIN%/API/Items/GetExtendedCostOfPage.ashx");

--[[
	/// <summary>
	/// use the item directly through global store id
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = int  // item instance id
	///		[ "count" ] = int  // use count, this field should always be "1"
	///		[ "targetguid" ] = int  // target item guid(optional), this could be optional if the gsid requires a target
	///		CYF: 这里最经典的例子就是消耗品, 比如给坐骑吃的, 消耗掉一个物品, 然后变成目标宠物guid的食物, 沐浴露 玩具的数值等等
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								item doesn't exist
	///								request item count exceed existing count
	///								item can't be destroyed
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
-- TODO: M3
--paraworld.CreateRESTJsonWrapper("paraworld.inventory.UseItem", "%MAIN%/API/Items/UseItem.ashx");


--[[
	/// <summary>
	/// get the items equipped on user(all bag 0 items)
	/// pay attention that this information can be accessed by every users in the community
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "uids" ] = string  // uids separated by ","    maximum uids per request is 10
	///		or [ "nids" ] = string  // nids separated by ","    maximum nids per request is 10
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "equips" ] = list{
	///				uid/nid = string, 
	///				gsids = string, // comma separated global store ids
	///				NOTE: if we have "102,0,0,205,0,0,0,0,32" as gsids, the user have an global store item 102 on character slot position 1, 
	///					item 205 on character slot position 4, and item 32 on character slot position 9.
	///			}
	///			NOTE: equips count depends on the request uid or nid count
	///		}
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								invalid uid or nid
	///								too many user count 
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
paraworld.create_wrapper("paraworld.inventory.GetEquips", "%MAIN%/API/Items/GetEquips.ashx");

--[[
    /// <summary>
    /// 清空用户家园中的物品（不包括宠物），植物直接删除，其它物品回收到其BagFamily包中，只可清空自己家园中的物品
    /// 接收参数：
    ///     nid  当前登录用户的NID
    /// 返回值：
    ///     issuccess
    ///     [ errorcode ]
    /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.RecycleHomelandItems", "%MAIN%/API/Items/RecycleHomelandItems.ashx");


--[[
	/// <summary>
	/// set the client data of the item instances
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "guid" ] = string  // item instance id
	///		[ "clientdata" ] = string  // item instance client data
	///		[ "bag" ] = int  // NOTE: CYF require this field for cache optimization, 2009/6/15
	/// }
	/// </param>
	/// <returns>
	///		[ "issuccess" ] = boolean   // is success
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///								// the error code should as least provide the following errors:
	///								wrong item ownership, only the owner of the item can move items
	///								item not exists
	///								item count is not 1, we don't provide client data for stackable and stacked items 
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]]
paraworld.create_wrapper("paraworld.inventory.SetClientData", "%MAIN%/API/Items/SetClientData.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	local ls = Map3DSystem.localserver.CreateStore(nil, 3);
	if(ls) then
		local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl(); 
		local url_bagfamily = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", msg.bag, "nid", Map3DSystem.User.nid})
		local item = ls:GetItem(url_bagfamily)
		if(item and item.entry and item.payload) then
			--
			----------------------------------------------------------------------------------
			-- NOTE: clientdata are implemented as a local priority manner, that is:
			--		1. SetClientData always valids immediately in ItemManager.SetClientData
			--		2. clientdata is updated to the local server in pre function of SetClientData
			--		3. if failed setting afterwards, wait for the next GetItemsInBag
			--			in the next GetItemsInBag post function, newly fetched items are checked with 
			--			the same bag items in local version. if different, 
			--			SetClientData is invoked again to set the clientdata to local version
			--		4. clientdata setting utilizes a lazy setting strategy, only set invoke the call 
			--			when needed: first SetClientData after ItemManager.SetClientData and 
			--			GetItemsInBag on every new coming web traffic
			----------------------------------------------------------------------------------
			--
			local output_msg = commonlib.LoadTableFromString(item.payload.data);
			if(output_msg and output_msg.items) then
				-- find the item with the right guid
				local _, item;
				for _, item in ipairs(output_msg.items) do
					if(item.guid == msg.guid) then
						output_msg.items[_].clientdata = msg.clientdata;
						break;
					end
				end
				-- make entry
				local item = {
					entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_bagfamily,}),
					payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
						status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
						data = commonlib.serialize_compact(output_msg),
					}),
				}
				-- save to database entry
				local res = ls:PutItem(item);
				if(res) then 
					LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after SetClientData", tostring(url_bagfamily));
				else	
					LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after SetClientData", tostring(url_bagfamily))
					LOG.std("", "warning","Inventory", output_msg);
				end
			end
		end
	end -- if(ls) then

	if(msg.bmemorydbonly) then
		-- don't require web API call
		return true;
	end

	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SetClientData msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
	end
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SetClientData msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);



--[[
	/// <summary>
	/// get all items in the specific bag
	/// </summary>
	/// <param name="msg">
	/// msg = {
	///		[ "sessionkey" ] = string  // session key
	///		[ "nid" ] = string  // user to be searched
	///		[ "bag" ] = string  // bag to be searched, we only allow bagid from 10001 to 19999 visible to other user such as homeland items
	/// }
	/// </param>
	/// <returns>
	///		[ "items" ] = list{
	///			guid = int  // item instance id
	///			gsid = int
	///			obtaintime = string
	///			position = int
	///			clientdata = string
	///			serverdata = string
	///			copies = int
	///			}  // item count depending on the bag item count
	///		[ "errorcode" ] = int   // errorcode if issuccess is false
	///		[ "info" ] = string  // error info if issuccess is false
	/// </returns>
]] 
local getitemsinotheruserbag_cache_policy = "access plus 10 minutes";
paraworld.create_wrapper("paraworld.inventory.GetItemsInOtherUserBag", "%MAIN%/API/Items/GetItemsInOtherUserBag.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInOtherUserBag msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.GetItemsInOtherUserBag msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);

--[[
    /// <summary>
    /// 当前用户出售物品
    /// 接收参数：
    ///     sessionkey  当前登录用户的sessionKey
    ///     guid  出售物品的GUID
    ///     bag  出售物品所在的包ID
    ///     cnt  出售数量
    /// 返回值：
    ///     issuccess  是否成功
    ///     [ deltaemoney ]  出售物品获得的E币数量
    ///     [ errorcode ]  (数据不存在或已被删除[用户不存在或物品不存在]  条件不符[拥有的物品数量不够])
    /// </summary>
]] 
paraworld.create_wrapper("paraworld.inventory.SellItem", "%MAIN%/API/Items/SellItem.ashx", 
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	if(not paraworld.use_game_server) then
		msg.sessionkey = msg.sessionkey or Map3DSystem.User.sessionkey;
	end	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SellItem msg_in:");
		LOG.std("", "debug","Inventory", msg);
	end
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	if(msg.issuccess == true) then
		local ls = Map3DSystem.localserver.CreateStore(nil, 3);
		if(ls) then
			local url_getitemsinbag = paraworld.inventory.GetItemsInBag.GetUrl();
			local url = NPL.EncodeURLQuery(url_getitemsinbag, {"format", 1, "bag", inputMsg.bag, "nid", Map3DSystem.User.nid})
			local item = ls:GetItem(url)
			if(item and item.entry and item.payload) then
				local output_msg = commonlib.LoadTableFromString(item.payload.data);
				if(output_msg and output_msg.items) then
					-- pass 1: update the bag items
					local _, item;
					for _, item in ipairs(output_msg.items) do
						if(item.guid == inputMsg.guid) then
							item.copies = item.copies - inputMsg.cnt;
							break;
						end
					end
					-- pass 2: update the emoney in user info
					local url_getinfo = paraworld.users.getInfo.GetUrl();
					local fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family";
					fields = string.lower(commonlib.Encoding.SortCSVString(fields));
					local url_getinfo = NPL.EncodeURLQuery(url_getinfo, {"format", 1, "nids", Map3DSystem.User.nid, "fields", fields})
					local item = ls:GetItem(url_getinfo)
					if(item and item.entry and item.payload) then
						local output_msg = commonlib.LoadTableFromString(item.payload.data);
						if(type(output_msg) == "table" and output_msg.users) then
							-- update the $E
							local _, user;
							for _, user in ipairs(output_msg.users) do
								if(user.nid == Map3DSystem.User.nid) then
									output_msg.users[_].emoney = user.emoney + msg.deltaemoney;
								end
							end
							-- make entry
							local item = {
								entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url_getinfo,}),
								payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
									status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
									data = commonlib.serialize_compact(output_msg),
								}),
							}
							-- save to database entry
							local res = ls:PutItem(item);
							if(res) then 
								LOG.std("", "debug","Inventory", "User info of %s updated to local server after SellItem", tostring(url_getinfo));
							else	
								LOG.std("", "warning","Inventory", "failed updating uesr info of %s to local server after SellItem", tostring(url_getinfo))
								LOG.std("", "warning","Inventory", output_msg);
							end
						end
					end
					-- make entry
					local item = {
						entry = Map3DSystem.localserver.WebCacheDB.EntryInfo:new({url = url,}),
						payload = Map3DSystem.localserver.WebCacheDB.PayloadInfo:new({
							status_code = Map3DSystem.localserver.HttpConstants.HTTP_OK,
							data = commonlib.serialize_compact(output_msg),
						}),
					}
					-- save to database entry
					local res = ls:PutItem(item);
					if(res) then 
						LOG.std("", "debug","Inventory", "Bag Items of %s updated to local server after SellItem", tostring(url));
					else	
						LOG.std("", "warning","Inventory", "failed updating bag items of %s to local server after SellItem", tostring(url))
						LOG.std("", "warning","Inventory", output_msg);
					end
				end
			end
		end -- if(ls) then
	end
	
	if(isLogInventoryTraffic) then
		LOG.std("", "debug","Inventory", "paraworld.inventory.SellItem msg_out:");
		LOG.std("", "debug","Inventory", msg);
	end
end
);