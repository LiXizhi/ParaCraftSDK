---++ ParacraftSrc
| Author: LiXizhi			|
| Email: lixizhi@yeah.net	|
| Date: 2015.4.8			|

---++ Introduction
   * ParacraftSrc is only for documentation purposes. DO NOT modify any source here, since it will not take effect. 
   * file with *.class.lua are header only NPL files. Meaning that it is closed source at the moment. 
   * In visual studio, it is recommended to turn on "Show All Files" in the solution explorer, as it will show files in original hierachy instead of flat directories. 
   * CMakeLists.txt is only used for me to sync latest source code from the real source repository. One can read sync_src.bat for details. 

---++ Getting started
	The best way to learn is to read the source code in this project.  Both mobile and win32 share the same code base. But mobile version uses different bootstraping file. 

---+++ Bootstrapping
	when application start, we need to specify the first npl file to load. This file is called the bootstraper. 
The file can be specified via command line, or from config.txt on mobile platform (i.e. android/iOS).
For example: 
	script/mobile/paracraft/main.lua

The bootstrapper NPL file must be associated with an activation function, which is called 2 times per second. 
<verbatim>
local function activate()
	-- this is first function to be called when application start. 
end
NPL.this(activate);
</verbatim>

---++ Basic terminologies 

---+++ NPL files 
	NPL is short for Neural parallel language. npl files are lua files that will be compiled to bytecode in main*.pkg during release. All source code are recommended to be written in NPL. 
Each npl file has a unique address(like email address) and can be associated with an activation function. 
NPL files can communicate with each other asynchrounously via activation function in the same thread, or cross multiple NPL threads, or cross networks.

---+++ mcml files 
	MCML is a HTML alike markup language, which is written in NPL. It can also be extended by NPL per application. All user interface are recommended to be written in mcml. 
NPL Code behind is supported in mcml, just like HTML/Javascript. 

---+++ Block/item/Entity
	There are three major base object types in paracraft: block, item, entity. 
Their type template are defined in "config/Aries/creator/block_types.xml". You can add your own types there or do it programmactically later on.
Their intances are described below: 

	"Item" is normally the interactive icon you see in paracraft. You can click it to activate it or create a block or entity from it. 
You can also drag, drop, stack or throw it into the 3d scene. 

	"Block" is a static block which is batch rendered by the block engine. There are millions of them in a world. 

	"Entity" is anything that can move in the scene. They are animated and rendered individually. You can not have too many of them in the world. 
The main character, mob, camera, etc are all entities. 



