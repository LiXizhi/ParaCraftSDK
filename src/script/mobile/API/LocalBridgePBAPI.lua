--[[
replace:
local protobuf = require "protobuf"
to:
NPL.load("(gl)script/mobile/protobuf/protobuf.lua");
local protobuf = protobuf;
--]]
NPL.load("(gl)script/mobile/API/local_service_wrapper.lua");
local LocalService = commonlib.gettable("LocalService");
LocalService.create_wrapper = LocalService.CreateRPCWrapper;

NPL.load("(gl)script/mobile/NetWork/LocalBridgePB_pb.lua")
LocalService.create_wrapper("LocalBridgePBAPI.login",					LocalBridgePB_pb,	"login");
LocalService.create_wrapper("LocalBridgePBAPI.logout",					LocalBridgePB_pb,	"logout");
LocalService.create_wrapper("LocalBridgePBAPI.isLogin",					LocalBridgePB_pb,	"isLogin");

LocalService.create_wrapper("LocalBridgePBAPI.makeDir",					LocalBridgePB_pb,	"makeDir");
LocalService.create_wrapper("LocalBridgePBAPI.deleteFile",				LocalBridgePB_pb,	"deleteFile");
LocalService.create_wrapper("LocalBridgePBAPI.uploadFile",				LocalBridgePB_pb,	"uploadFile");
LocalService.create_wrapper("LocalBridgePBAPI.stopTransferring",		LocalBridgePB_pb,	"stopTransferring");
LocalService.create_wrapper("LocalBridgePBAPI.downloadFile",			LocalBridgePB_pb,	"downloadFile");
LocalService.create_wrapper("LocalBridgePBAPI.downloadFileFromStream",	LocalBridgePB_pb,	"downloadFileFromStream");
LocalService.create_wrapper("LocalBridgePBAPI.list",					LocalBridgePB_pb,	"list");
LocalService.create_wrapper("LocalBridgePBAPI.imageStream",				LocalBridgePB_pb,	"imageStream");
LocalService.create_wrapper("LocalBridgePBAPI.audioStream",				LocalBridgePB_pb,	"audioStream");
LocalService.create_wrapper("LocalBridgePBAPI.videoStream",				LocalBridgePB_pb,	"videoStream");
LocalService.create_wrapper("LocalBridgePBAPI.docStream",				LocalBridgePB_pb,	"docStream");
LocalService.create_wrapper("LocalBridgePBAPI.quota",					LocalBridgePB_pb,	"quota");
LocalService.create_wrapper("LocalBridgePBAPI.thumbnail",				LocalBridgePB_pb,	"thumbnail");

LocalService.create_wrapper("MobileDevice.vibrate",				LocalBridgePB_pb,	"vibrate");
LocalService.create_wrapper("MobileDevice.vibrateWithPattern",	LocalBridgePB_pb,	"vibrateWithPattern");
LocalService.create_wrapper("MobileDevice.cancelVibrate",		LocalBridgePB_pb,	"cancelVibrate");

LocalService.create_wrapper("MobileDevice.AudioManager_getStreamVolume",		LocalBridgePB_pb,	"AudioManager_getStreamVolume");
LocalService.create_wrapper("MobileDevice.AudioManager_setStreamVolume",		LocalBridgePB_pb,	"AudioManager_setStreamVolume");
LocalService.create_wrapper("MobileDevice.AudioManager_getStreamMaxVolume",		LocalBridgePB_pb,	"AudioManager_getStreamMaxVolume");
LocalService.create_wrapper("MobileDevice.AudioManager_setStreamMute",			LocalBridgePB_pb,	"AudioManager_setStreamMute");

--MobileDevice.openURL({url = "http://www.paracraft.cn"})
--NOTE:要用http://开头
LocalService.create_wrapper("MobileDevice.openURL",		LocalBridgePB_pb,	"openURL");

LocalService.create_wrapper("MobileDevice.getMemoryInfo",		LocalBridgePB_pb,	"getMemoryInfo");




