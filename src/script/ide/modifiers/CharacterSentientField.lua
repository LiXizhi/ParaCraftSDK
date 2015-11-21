--[[
Title: Character-Sentient-Field modifier class
Author(s): Liuweili
Date: 2006/6/20
Desc: This modifier sets the group ID and sentient fields of the current character.
	It's based on the CSampleModifier;
Use Lib:
Test OK!!
-------------------------------------------------------
local ctl=CommonCtrl.ModifierCtrl.GetModifier("CharacterSentientFieldModifier"):new{
	-- the object which is being modified. Protected. Don't modify it directly.
	binding = nil,
	title = "Character Sentient Field",
	-- modifier name, this is read-ony
	name = "CharacterSentientFieldModifier1",

	-- the ModifierItems object to store the values of this modifier, inheritance need to initialize this value
	-- this field stores setting which DoModifer() function will apply to the current object.
	items = CommonCtrl.ModifierItems:new{
		items={
			{
			name="GroupID",
			type="int",
			schematic=":int",
			},
			{
			name="SentientField",
			type="int",
			schematic=":int",
			}
		},
	values={
		GroupID=1,SentientField=0
		}
	},
	-- this field stores the old settings which UnDoModifer() function will apply to the current object to restore it to an old state.
	olditems = nil,
	
	-- this is a identifier, always true
	ismodifier = true
}
-- remember not to use ctl.binding=XXXX, use Databind()
ctl:DataBind(player);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/modifier_items.lua");

NPL.load("(gl)script/ide/modifiers/sampleModifier.lua");
-- default member attributes
local CharacterSentientFieldModifier=CommonCtrl.ModifierCtrl.GetModifier("CSampleModifier"):new{
	-- the object which is being modified.
	binding = nil,
	title = "Character Sentient Field",
	-- modifier name, this is read-ony
	name = "CharacterSentientFieldModifier",

	-- the ModifierItems object to store the values of this modifier, inheritance need to initialize this value
	-- this field stores setting which DoModifer() function will apply to the current object.
	items = CommonCtrl.ModifierItems:new{
		items={
			{
			name="GroupID",
			type="int",
			schematic=":int",
			},
			{
			name="SentientField",
			type="int",
			schematic=":int",
			}
		},
	values={
		GroupID=0,SentientField=1
		}
	},
	-- indicate the specific type of object's SentientField and GroupID
	IDS_Table={
		--player senses anything
		player={GroupID=0,SentientField=65535},
		--actor senses only player
		actor={GroupID=1,SentientField=1},
		--static senses nothing
		static={GroupID=2,SentientField=0},
		--npc senses almost every body else except its own kind
		npc={GroupID=3,SentientField=7}
		},
	-- this field stores the old settings which UnDoModifer() function will apply to the current object to restore it to an old state.
	olditems = nil,
	type=nil,
	-- this is a identifier, always true
	ismodifier = true
}
-- this modifier will automatically register itself in the modifier control when it is loaded. 
CommonCtrl.ModifierCtrl.RegisterModifier(CharacterSentientFieldModifier.name, CharacterSentientFieldModifier);
if(not _IDE_Modifiers) then _IDE_Modifiers={}; end
_IDE_Modifiers.CharacterSentientFieldModifier = CharacterSentientFieldModifier;
-- @return: return true if it can modify the given object; and return nil if otherwise,
function CharacterSentientFieldModifier.CanModify(o)
	if(o.GetAttributeObject~=nil) then
		local att = o:GetAttributeObject();
		local className = att:GetClassName();
		if(className == "RPG Character") then
			return true;
		end
	end
end

-- draws the GUI of this modifier
--
function CharacterSentientFieldModifier:OwnerDraw(__parent)
	-- create all sub control items.
	local __this;
	local ctrl_x,ctrl_y = 2,0;
	local cellspacing = 3;
	local width,height = __parent.width-cellspacing, 25;
	local labelWidth = 100;
	local valueWidth = width - labelWidth - cellspacing*3 - 20;
	local valueLeft = ctrl_x+labelWidth+cellspacing;
	local att = self:GetAttributeObject();

	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth,height);
	__parent:AddChild(__this);
	__this.text="GroupID";
	__this.autosize=false;

	local ctl = CommonCtrl.CCtrlIntegerEditor:new {
		name = self.name..1,
		parent = __parent,
		left = valueLeft, top = ctrl_y, 
		value = att:GetField("GroupID", 0),
		onchange = string.format([[local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.OnIntegerChangeHandler~=nil)then _mod.OnIntegerChangeHandler("%s");end;]],self.name,self.name)
	};
	ctl.minvalue, ctl.maxvalue = att:GetSchematicsMinMax(1, ctl.minvalue, ctl.maxvalue);
	ctl:Show();

	ctrl_y = ctrl_y + height + cellspacing;
	__this=ParaUI.CreateUIObject("text","static", "_lt",ctrl_x,ctrl_y,labelWidth+100,height);
	__parent:AddChild(__this);
	__this.text="SentientField";
	__this.autosize=false;
	ctrl_y = ctrl_y + height + cellspacing;
	local sf=att:GetField("SentientField",0);
	local a,b;
	for a=0,1 do
		ctrl_x=10;
		for b=0,7 do
			__this=ParaUI.CreateUIObject("button",string.format([[%s_btn%d]],self.name,a*8+b), "_lt",ctrl_x,ctrl_y,height,height);
			__parent:AddChild(__this);
			__this.text=tostring(a*8+b);
			if(math.mod(sf,2)==1)then
				__this.background="Texture/pressedbox.png;";
			else
				__this.background="Texture/box.png;";
			end
			__this.onclick = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UpdateButton~=nil)then _mod.UpdateButton("%s",%d);end;]],self.name,self.name, a*8+b);
			sf=math.floor(sf/2);
			ctrl_x=ctrl_x+30;
		end
		ctrl_y = ctrl_y + height + cellspacing;
	end
	ctrl_x=10;
	__this=ParaUI.CreateUIObject("button",string.format([[%s_btnplayer]],self.name), "_lt",ctrl_x,ctrl_y,50,height);
	__parent:AddChild(__this);
	__this.text="玩家";
	__this.background="Texture/box.png;";
	__this.onclick = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UpdateCharacter~=nil)then _mod.UpdateCharacter("%s","player");end;]],self.name,self.name);
	ctrl_x=ctrl_x+55;
	__this=ParaUI.CreateUIObject("button",string.format([[%s_btnactor]],self.name), "_lt",ctrl_x,ctrl_y,50,height);
	__parent:AddChild(__this);
	__this.text="电影人";
	__this.background="Texture/box.png;";
	__this.onclick = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UpdateCharacter~=nil)then _mod.UpdateCharacter("%s","actor");end;]],self.name,self.name);
	ctrl_x=ctrl_x+55;

	__this=ParaUI.CreateUIObject("button",string.format([[%s_btnstatic]],self.name), "_lt",ctrl_x,ctrl_y,50,height);
	__parent:AddChild(__this);
	__this.text="木头人";
	__this.background="Texture/box.png;";
	__this.onclick = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UpdateCharacter~=nil)then _mod.UpdateCharacter("%s","static");end;]],self.name,self.name);
	ctrl_x=ctrl_x+55;

	__this=ParaUI.CreateUIObject("button",string.format([[%s_btnnpc]],self.name), "_lt",ctrl_x,ctrl_y,50,height);
	__parent:AddChild(__this);
	__this.text="NPC";
	__this.background="Texture/box.png;";
	__this.onclick = string.format([[;local _mod=CommonCtrl.ModifierCtrl.GetModifier("%s");if(_mod~=nil and _mod.UpdateCharacter~=nil)then _mod.UpdateCharacter("%s","npc");end;]],self.name,self.name);
end

function CharacterSentientFieldModifier.UpdateButton(sCtrlName,btnIndex)
	local self = CommonCtrl.ModifierCtrl.GetModifier(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting modifier %s
		]],sCtrlName));
		return;
	end
	local att=self:GetAttributeObject();
	local sf=0;
	if(btnIndex)then
		sf=att:GetField("SentientField",0);
		local v=1;
		for a=1,btnIndex do
			sf=math.floor(sf/2);
			v=v*2;
		end
		if(math.mod(sf,2)==1)then
			sf=att:GetField("SentientField",0);
			att:SetField("SentientField",sf-v);
		else
			sf=att:GetField("SentientField",0);
			att:SetField("SentientField",sf+v);
		end
	end
	--if you change it manually, the type will be nil
	self.type=nil;
	CharacterSentientFieldModifier.OwnerUpdate(sCtrlName);
end

-- Load data from the binded object to the modifier, so that when the modifier shows up, it shows the recent data of the binded object. 
function CharacterSentientFieldModifier:InitData()
	if(self.binding~=nil) then
		log("CharacterSentientFieldModifier init\r\n");
		local att_o=self.binding:GetAttributeObject();
		local att=self:GetAttributeObject();
		att:SetField("GroupID",att_o:GetField("GroupID", 0));
		att:SetField("SentientField",att_o:GetField("SentientField", 0));
	end
end

function CharacterSentientFieldModifier.UpdateCharacter(sCtrlName,sType)
	local self = CommonCtrl.ModifierCtrl.GetModifier(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting modifier %s
		]],sCtrlName));
		return;
	end
	local att=self:GetAttributeObject();
	if(self.IDS_Table[sType]~=nil)then
		att:SetField("GroupID",self.IDS_Table[sType].GroupID);
		att:SetField("SentientField",self.IDS_Table[sType].SentientField);
		self.type=sType;
	else
		--some unsupported type
	end
	
	CharacterSentientFieldModifier.OwnerUpdate(sCtrlName);
end

-- updates the values of this modifier
function CharacterSentientFieldModifier.OwnerUpdate(sCtrlName)
	local self = CommonCtrl.ModifierCtrl.GetModifier(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting modifier %s
		]],sCtrlName));
		return;
	end
	local att=self:GetAttributeObject();
	CommonCtrl.CCtrlIntegerEditor.InternalUpdate(sCtrlName..1,att:GetField("GroupID", 0));
	local sf=att:GetField("SentientField",0);
	local a,b;
	for a=0,1 do
		for b=0,7 do
			local __this=ParaUI.GetUIObject(string.format([[%s_btn%d]],sCtrlName,a*8+b));
			if(math.mod(sf,2)==1)then
				__this.background="Texture/pressedbox.png;";
			else
				__this.background="Texture/box.png;";
			end
			sf=math.floor(sf/2);
		end
	end
	local _this;
	_this=ParaUI.GetUIObject(string.format([[%s_btnplayer]],self.name));
	_this.background="Texture/box.png;";
	_this=ParaUI.GetUIObject(string.format([[%s_btnactor]],self.name));
	_this.background="Texture/box.png;";
	_this=ParaUI.GetUIObject(string.format([[%s_btnstatic]],self.name));
	_this.background="Texture/box.png;";
	_this=ParaUI.GetUIObject(string.format([[%s_btnnpc]],self.name));
	_this.background="Texture/box.png;";
	if(self.type~=nil)then
		_this=ParaUI.GetUIObject(string.format([[%s_btn%s]],self.name,self.type));
		if(_this:IsValid()==true)then
			_this.background="Texture/pressedbox.png;";
		else
			--some unsupported type
		end
	end
end

--[[ [static method] the event handler when the editor of a field should be invoked
@param sCtrlName: the global control name. ]]
function CharacterSentientFieldModifier.OnIntegerChangeHandler(sCtrlName)
	local self = CommonCtrl.ModifierCtrl.GetModifier(sCtrlName);
	if(not self) then 
		log(string.format([[err getting modifier %s
		]],sCtrlName));
		return;
	end
	local ctl = CommonCtrl.GetControl(sCtrlName..1);
	
	local att = self:GetAttributeObject();
	
	att:SetField("GroupID", ctl.value);
	self.type=nil;
	CharacterSentientFieldModifier.OwnerUpdate(sCtrlName);
end
