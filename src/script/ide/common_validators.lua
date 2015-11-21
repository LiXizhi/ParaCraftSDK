--[[
Title: common validators funcions
Author(s): Spring Yan
Date: 2011/4/13
Desc: basic validators functions, etc. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/common_validators.lua");
-------------------------------------------------------
]]

local date = commonlib.gettable("commonlib.validators.date");
local id = commonlib.gettable("commonlib.validators.id");

local tostring = tostring
local tonumber = tonumber

local math_mod = math.mod;
local string_sub = string.sub;
local string_len = string.len;
local string_match = string.match;
local string_lower = string.lower;

-- 根据输入的年月日,判断是否是一个正确的日期
-- @param: cYear: number, cMonth: number, cDay:number
-- @return: true or false
function date.IsDate(cYear,cMonth,cDay)
		if(cMonth>12 or cMonth<1) then
			return false;	
		end;

		if((cMonth==1 or cMonth==3 or cMonth==5 or cMonth==7 or cMonth==8 or cMonth==10 or cMonth==12) and (cDay>31 or cDay<1)) then
			return false;
		end

		if((cMonth==4 or cMonth==6 or cMonth==9 or cMonth==11) and (cDay>30 or cDay<1)) then
			return false;
		end

		if(cMonth==2) then
			if(cDay<1) then
				return false;
			end

			local boolLeapYear = false;
			if(math_mod(cYear,100)==0)then
				if(math_mod(cYear,400)==0) then
					boolLeapYear = true;
				end
			else		
				if(math_mod(cYear,4)==0) then
					boolLeapYear = true;
				end
			end

			if(boolLeapYear)then
				if(intDay>29) then
					return false;
				end
			else
				if(intDay>28) then
					return false;
				end
			end
		end
		return true;		
end

-- 判断身份证号是否正确
-- @param: idno:string
-- @return: true or false
function id.IsIDNO(idno)
	local IsDate = date.IsDate;

	if(string_len(idno)==15 or string_len(idno)==18) then
		local sareacode,sbirthdate,slastcode,slastchar;
		local areacode,birthdate,lastcode;
		if (string_len(idno)==15)then
			sareacode,sbirthdate,slastcode=string_match(idno,"^(%w%w%w%w%w%w)(%w%w%w%w%w%w)(%w%w%w)");
			sbirthdate="19"..sbirthdate;
		else
			sareacode,sbirthdate,slastcode,slastchar=string_match(idno,"^(%w%w%w%w%w%w)(%w%w%w%w%w%w%w%w)(%w%w%w)(%w)");
		end
		areacode=tonumber(sareacode);
		birthdate=tonumber(sbirthdate);
		lastcode=tonumber(slastcode);

		if((not areacode) or (not birthdate) or (not lastcode)) then
			return false;	
		else
			local sbirthyear,sbirthmonth,sbirthday = string_match(sbirthdate,"(%d%d%d%d)(%d%d)(%d%d)");
			local birth_year,birth_month,birth_day;

			birth_year = tonumber(sbirthyear);
			birth_month = tonumber(sbirthmonth);
			birth_day = tonumber(sbirthday);

			if (not IsDate(birth_year,birth_month,birth_day)) then
				return false;	
			else
				if (string_len(idno)==18) then
					local iW = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1};
					local verifyCode = {"1","0","x","9","8","7","6","5","4","3","2"};
					local i,iSum = 0,0;
					for i = 1,17 do
						local iVal = tonumber(string_sub(idno,i,i));
						iSum = iSum + iVal * iW[i];
					end		
					local iJYM = math_mod(iSum, 11);
					local sJYM = verifyCode[iJYM+1];
					local clastchar= string_lower(slastchar);
		
					if (clastchar ~= sJYM) then
						return false;	
					else
						return true;
					end
				else
					return true;
				end
			end
		end
	else
		return false;	
	end
end