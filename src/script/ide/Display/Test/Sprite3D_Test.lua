---------------------------------------------------------------
--[[
NPL.load("(gl)script/ide/Display/Test/Sprite3D_Test.lua");
local test = CommonCtrl.Display.Sprite3D_Test:new();
--test:Test_1();
--test:TestGlobalToLocal()
test:TestClone()
--]]
---------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");

local Sprite3D_Test = {};
commonlib.setfield("CommonCtrl.Display.Sprite3D_Test",Sprite3D_Test);
function Sprite3D_Test:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
function Sprite3D_Test:Test_1()
	local miniScene = CommonCtrl.Display.Containers.MiniScene:new()
	miniScene:Init();
	self.miniScene = miniScene;
	miniScene:SetPosition(245,0,234);
	
	
	local sprite3D = CommonCtrl.Display.Containers.Sprite3D:new();
	sprite3D:Init()
	sprite3D:SetPosition(0,0,0);
	
	local actor3D = CommonCtrl.Display.Objects.Actor3D:new()
	actor3D:Init();
	local params = actor3D:GetEntityParams();
	actor3D:SetEntityParams(params);
	sprite3D:AddChild(actor3D);	
	sprite3D:AddEventListener("left_mouse_down",Sprite3D_Test.MouseDownHandle,self)
	sprite3D:AddEventListener("left_mouse_up",Sprite3D_Test.MouseUpHandle,self)
	
	actor3D:SetPosition(0,0,0);
	actor3D:AddEventListener("left_mouse_down",Sprite3D_Test.MouseDownHandle,self)
	actor3D:AddEventListener("left_mouse_up",Sprite3D_Test.MouseUpHandle,self)

	
	local building3D = CommonCtrl.Display.Objects.Building3D:new()
	building3D:Init();
	local params = building3D:GetEntityParams();
	building3D:SetEntityParams(params);
	sprite3D:AddChild(building3D);	
	
	building3D:SetPosition(2,0,0);
	building3D:AddEventListener("left_mouse_down",Sprite3D_Test.MouseDownHandle,self)
	building3D:AddEventListener("left_mouse_up",Sprite3D_Test.MouseUpHandle,self)
	
	building3D = CommonCtrl.Display.Objects.Building3D:new()
	building3D:Init();
	local params = building3D:GetEntityParams();
	building3D:SetEntityParams(params);
	sprite3D:AddChild(building3D);	
	
	building3D:SetPosition(4,0,0);
	building3D:AddEventListener("left_mouse_down",Sprite3D_Test.MouseDownHandle,self)
	building3D:AddEventListener("left_mouse_up",Sprite3D_Test.MouseUpHandle,self)
	
	miniScene:AddChild(sprite3D);
	miniScene:UpdateEntity();
	
	local x,y,z = sprite3D:GetPosition();
	x = x + 2;
	y = y + 0;
	sprite3D:SetPosition(x,y,z);
	
	return miniScene,sprite3D,actor3D,building3D
end
function Sprite3D_Test.MouseDownHandle(funcHolder,event)
	local self = funcHolder;
	local type = event.type;
	local currentTarget = event.currentTarget;
	if(currentTarget)then
		commonlib.echo(currentTarget:GetUID()..":"..currentTarget.CLASSTYPE);
		local obj = self.miniScene:GetEntity(currentTarget);
		if(obj and obj:IsValid())then
			obj:GetAttributeObject():SetField("showboundingbox", true);
		end
	end
end
function Sprite3D_Test.MouseUpHandle(funcHolder,event)
	local self = funcHolder;
	local type = event.type;
	local currentTarget = event.currentTarget;
	if(currentTarget)then
		local obj = self.miniScene:GetEntity(currentTarget);
		if(obj and obj:IsValid())then
			obj:GetAttributeObject():SetField("showboundingbox", false);
		end
	end
end

function Sprite3D_Test:TestGlobalToLocal()
	local miniScene = CommonCtrl.Display.Containers.MiniScene:new()
	miniScene:Init();
	miniScene:SetPosition(5,0,5);
	
	local sprite3D = CommonCtrl.Display.Containers.Sprite3D:new();
	sprite3D:Init()
	sprite3D:SetPosition(10,0,10);
	
	local actor3D = CommonCtrl.Display.Objects.Actor3D:new()
	actor3D:Init();
	actor3D:SetPosition(20,0,20);

	sprite3D:AddChild(actor3D);

	miniScene:AddChild(sprite3D);
	
	commonlib.echo(actor3D:GlobalToLocal({x = 40, y = 0, z = 40})); -- { x=5, y=0, z=5 } 
	commonlib.echo(actor3D:LocalToGlobal({x = 40, y = 0, z = 40})); -- { x=75, y=0, z=75 }
	local x,y,z = actor3D:GetPosition();
	commonlib.echo({x = x, y = y, z = z}); -- { x=20, y=0, z=20 }
	commonlib.echo(actor3D:LocalToGlobal({x = 0, y = 0, z = 0})); --{ x=35, y=0, z=35 }
end
function Sprite3D_Test:TestClone()
	local miniScene,sprite3D,actor3D,building3D = self:Test_1();
	
	local clone_miniScene = miniScene:CloneNoneID();
	local clone_sprite3D = sprite3D:CloneNoneID();
	local clone_actor3D = actor3D:CloneNoneID();
	local clone_building3D = building3D:CloneNoneID();
	
	-- clone miniScene
	local x,y,z = miniScene:GetPosition();	
	clone_miniScene:SetPosition(x,y,z-1);
	
	-- clone a sprite3D
	local x,y,z = sprite3D:GetPosition();
	clone_sprite3D:SetPosition(x,y,z-2);
	miniScene:AddChild(clone_sprite3D);
	clone_sprite3D:UpdateEntity();
	
	-- clone a actor3D
	local x,y,z = actor3D:GetPosition();	
	clone_actor3D:SetPosition(x,y,z-5);
	sprite3D:AddChild(clone_actor3D);
	clone_actor3D:UpdateEntity();

	-- clone a building3D
	local x,y,z = building3D:GetPosition();
	clone_building3D:SetPosition(x,y,z-5);
	sprite3D:AddChild(clone_building3D);
	clone_building3D:UpdateEntity();
	
	clone_building3D:AddEventListener("left_mouse_down",Sprite3D_Test.MouseDownHandle,self)
	clone_building3D:AddEventListener("left_mouse_up",Sprite3D_Test.MouseUpHandle,self)
end