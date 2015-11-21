--[[
Title: Object oriented programming 
Author(s): LiXizhi
Date: 2009/10/31
Desc: OO programming in lua. 

It provides class inheritance and C++ like class constructor mechanism. 

Alternatively, one can use the class in NPL.load("(gl)script/ide/ObjectOriented/class.lua"); 
which has better method performance and manual constructor implementation. 

note1: inside ctor function, parent class virtual functions are not available,since meta table of parent is not set yet. 
note2: In a class, all functions are virtual functions except the constructor self:ctor()

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/commonlib.lua");

-- define a base class with constructor
local myBaseClass = commonlib.inherit(function(o)
	o.myTable = o.myTable or {name="myBaseClass"}
	-- note: inside ctor function, parent class virtual functions(such as PrintMe) are not available,since meta table of parent is not set yet. 
	commonlib.log("in ctor of base: %s\n", o:PrintMe())
end)

function myBaseClass:PrintMe()
	log("base: PrintMe->")
	return commonlib.serialize(self.myTable);
end

local myDerivedClassA = commonlib.inherit(myBaseClass, {
	static_non_table_field = "default initializer", 
}, function(o)
	o.myTable.nameA = "A";
	commonlib.log("in ctor of A: %s\n", o:PrintMe())
end)

function myDerivedClassA:PrintMe()
	log("A: PrintMe->")
	return commonlib.serialize(self.myTable);
end

local myDerivedClassB = commonlib.inherit(myDerivedClassA, {
	static_non_table_field_B = "default initializer", 
})

-- we can alternatively define constructor function as ctor() at a later time. 
function myDerivedClassB:ctor()
	self.myTable.nameB = "B";
	commonlib.log("in ctor of B: %s\n", self:PrintMe())
end

function myDerivedClassB:PrintMe()
	log("B: PrintMe->")
	return commonlib.serialize(self.myTable);
end

local myB = myDerivedClassB:new();
myB.myTable.nameA = "A modified by B";
commonlib.echo(myB:PrintMe())
commonlib.echo(myDerivedClassA:new():PrintMe())
commonlib.echo(myDerivedClassB:new():PrintMe())

-------------------------------------------------------
]]

if(not commonlib) then commonlib={}; end
local type = type;

-- look up for `k' in list of tables `plist'
local function search (k, plist)
  for i=1, #(plist) do
    local v = plist[i][k]     -- try `i'-th superclass
    if v then return v end
  end
end

-- multiple inheritance
-- see. http://www.lua.org/pil/16.3.html
function commonlib.multi_inherit(...)
	local arg = {...};
	arg.n = select("#", ...);

	local c = {}        -- new class
	-- class will search for each method in the list of its
	-- parents (`arg' is the list of parents)
	setmetatable(c, {__index = function (t, k)
		-- With this trick, accesses to inherited methods are as fast as to local methods (except for the first access). 
		-- The drawback is that it is difficult to change method definitions after the system is running, because these changes do not propagate down the hierarchy chain
		local v = search(k, arg)
        t[k] = v       -- save for next access
        return v
	end})

	-- prepare `c' to be the metatable of its instances
	c.__index = c

	-- define a new constructor for this new class
	function c:new (o)
		o = o or {}
		setmetatable(o, c)
		return o
	end

	-- return new class
	return c
end

-- create a new class inheriting from a baseClass.
-- the new class has new(), _super, isa() function.
-- @param baseClass: the base class from which to inherit the new one. it can be nil if there is no base class.
-- @param new_class: nil or a raw table. 
-- @param ctor: nil or the constructor function(o) end, one may init dynamic table fields in it. One can also define new_class:ctor() at a later time. 
--  note: inside ctor function, parent class virtual functions are not available,since meta table of parent is not set yet. 
-- @return the new class is created. One can later create and instance of the new class by calling its new function(). 
function commonlib.inherit(baseClass, new_class, ctor)
	if(type(baseClass) == "string") then
		log("Fatal error: "..baseClass.." must be a table instead of string\n");
	end
	if(type(new_class) == "string") then
		new_class = commonlib.gettable(new_class);
		log("Fatal error: "..new_class.." must be a table instead of string\n");
	end
	if(not ctor and type(baseClass) == "function") then
		ctor = baseClass;
		baseClass = nil;
	end
	
	local new_class = new_class or {}
    local class_mt = { __index = new_class }

	-- this ensures that the base class new function is also called. 
    function new_class:new(o)
        local o = o or {}
        
        if(baseClass) then
			-- this ensures that the constructor of all base classes are called. 
			if(baseClass.new~=nil) then
				baseClass:new(o);
			end	
        end
        setmetatable( o, class_mt )
        
		-- please note inside ctor function, parent class virtual functions are not available,since meta table of parent is not set yet. 
		local ctor = rawget(new_class, "ctor");
		if(type(ctor) == "function") then
			ctor(o);
		end
		
        return o
    end
    new_class.ctor = ctor

    if (baseClass~=nil) then
        setmetatable( new_class, { __index = baseClass } )
    end
    

	--------------------------------
    -- Implementation of additional OO properties
    --------------------------------

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    new_class._super = baseClass
    
	--[[ Xizhi: having the Java like super() method is inefficient in lua. 
	-- the following commented code only provide read access to method. 
	-- Instead one should use class_name._super.Method(self, ...) instead. 
	
	-- Recursivly allocates the inheritance tree of the instance.
	-- @param mastertable The 'root' of the inheritance tree.
	-- @return Returns the instance with the allocated inheritance tree.
	function new_class.alloc_(mastertable)
		local instance = {}
		-- Any functions this instance does not know of will 'look up' to the superclass definition.
		setmetatable(instance, {__index = new_class, __newindex = mastertable})
		return instance;
	end

	-- only create the super object on demand, since it consumes one more table. 
	-- @note: THE USE OF SUPER ONLY GRANTS ACCESS TO METHODS, NOT TO DATA MEMBERS
	-- however it can write to data members.  
	-- added by Xizhi: 2013.12.31
	function new_class:super()
		local super_instance = self._super_instance;
		if(super_instance) then
			return super_instance;
		else
			if(baseClass) then
				super_instance = baseClass.alloc_(self);
				self._super_instance = super_instance;
				return super_instance;
			end
		end
	end
	]]

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class._super
            end
        end

        return b_isa
    end

    return new_class
end

-- this function can be called multiple times for the same target_class with different interface_class
-- It just copies all string_key, value pair from interface_class to target_class except for ctor and those that already exist in target_class.
-- This is faster than multiple inheritance or single inheritance because the target_class contains all interface functions on its own meta table. 
-- @note: interface_class's ctor function is NOT called in target_class's ctor, one has to do it manually if required. 
-- @param target_class: new class to which the interface functions are copied to. 
-- @param interface_class: base interface class table. please note that this table must be fully loaded when this function is called. 
function commonlib.add_interface(target_class, interface_class)
	for key, value in pairs(interface_class) do
		if(type(key) == "string" and key ~= "ctor") then
			if(target_class[key] == nil) then
				target_class[key] = value;
			end
		end
	end
end