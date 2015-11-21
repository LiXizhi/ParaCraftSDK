--[[
Title: constants used by web services, such as return values
Author(s): LiXizhi, Andy @ParaEngine
Date: 2008/1/21
Desc: 
]]
-- create class
local LocalService = commonlib.gettable("LocalService");


-- various error code of paraworld api. 
LocalService.errorcode = {
	----------------------------------------
	-- general service error (1-100)
	----------------------------------------
	-- An unknown error occurred. Please try again later
	unknown = nil, 
	-- The service is not available at this time. 
	ServiceNotAvailable = 1,
	-- The application has reached the maximum number of requests allowed. More requests are allowed once the time window has completed. 
	MaxAppRequestsReached = 2,
	-- returned when calling the same RPC twice with the same id, if the previous one does not response. 
	RepeatCall = 3,	
	-- RPC times out. server does not respond
	Timeout = 4,
	-- general access denied 
	AccessDenied = 5,
	-- The request came from a remote address not allowed by this application.
	IPDenied = 6,
	-- The api key submitted is not associated with any known application. 
	Unknownappkey = 7,
	-- The user is not logged in, should direct user to login page
	LoginRequired = 8,
	
	----------------------------------------
	-- general validation error (100-200)
	----------------------------------------
	-- One of the parameters specified was missing or invalid. 
	InvalidParameters = 100,
	-- The session key was improperly submitted or has reached its timeout. Direct the user to log in again to obtain another key. 
	Invalidsessionkey = 101,
	-- The submitted call_id was not greater than the previous call_id for this session.
	InvalidCall_id = 102,
	-- Incorrect signature. (md5 sig is wrong)
	InvalidSig = 103,
	
	----------------------------------------
	-- per RPC error (400-500)
	----------------------------------------
	-- if value is larger than 400, it is a per RPC specific error message. one needs to check the declaration of each RPC for exact meaning. 
	PerCallError = 400,
};
