--[[
Title: reading/writing editor files
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_files.lua");
local wm_files = commonlib.gettable("PETools.WindowManager.wm_files");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Taurus/WindowManager/wm.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_global.lua");
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");

local wm_files = commonlib.gettable("PETools.WindowManager.wm_files");
local G = commonlib.gettable("PETools.Global");
local RNA = commonlib.gettable("PETools.RNA");

---------------------------
-- singleton
---------------------------

-- called on startup,  (context entirely filled with NULLs)
-- the screen object is loaded or called for 'New File'
-- @param context: the context object 
-- @param op: the operator object; op can be nil
function wm_files.WM_read_homefile(context, op)
	local from_memory;
	if(op) then
		from_memory = RNA.boolean_get(op.ptr, "factory");
	end
	local filename;
	G.relbase_valid = 0;
	if (not from_memory) then
		G.sce = wm_main.gethome_dir();
		filename = "script/apps/Taurus/WindowManager/default.petools.xml";
		wm_files.PETools_read_file(context, filename);
	else
		assert(false, "not implemented yet"); 
		wm_files.PETools_read_file_from_memory(context);
	end

	-- match the read WM with current WM
	wm_files.wm_window_match_do(context, nil); 
	-- opens window(s), checks keymaps
	wm_files.WM_check(context); 

	-- TODO: we may need to match and reuse old windows
	-- for now, we just destroy and recreate all. 
	local success;
end

function wm_files.wm_window_match_do(context, oldwmlist)
	local screen = context:get_screen();
	local wm = G.main.wm:first();
	local win;
	for win in wm.windows:each() do
		-- all windows get active screen from file
		win.screen = screen;
		win.screen.winid = win.winid;
	end
end

-- call this function to ensure that window and screen are all properly created and linked. 
function wm_files.WM_check(context)
	local wm = context:get_manager();
	
	-- wm context
	if(not wm) then
		wm = context:get_main().wm:first();
		context:set_manager(wm);
	end
	if(not wm) then return end
	if( not wm.windows:first() ) then return end

	if (not G.background) then
		-- case: fileread 
		if(not wm.initialized_window)  then
			wm_main.keymap_init(context);
		end

		if(not wm.initialized_window)  then
			wm_files.ED_screens_initialize(wm);
			wm.initialized_window = true;
		end
	end
end

-- file read, set all screens, areas(space) etc ... 
function wm_files.ED_screens_initialize(wm)
	local win;
	for win in wm.windows:each() do
		-- all windows get active screen from file
		if(not win.screen) then
			win.screen = G.main.screen:first();
		end
		wm_files.ED_screen_refresh(wm, win)
	end
end

-- TODO: create all areas, etc. 
function wm_files.ED_screen_refresh(wm, win)
	--if(win.screen.mainwin==0) then
		--win.screen.mainwin= wm_subwindow_open(win, &winrct);
	--else
		--wm_subwindow_position(win, win->screen->mainwin, &winrct);
	--
	--for(sa= win->screen->areabase.first; sa; sa= sa->next) {
		--/* set spacetype and region callbacks, calls init() */
		--/* sets subwindows for regions, adds handlers */
		--ED_area_initialize(wm, win, sa);
	--}
--
	--/* wake up animtimer */
	--if(win->screen->animtimer)
		--WM_event_timer_sleep(wm, win, win->screen->animtimer, 0);
	--
	--win.screen.do_refresh= 0;
--
	--win.screen.context= ed_screen_context;
end


-- TODO: read pe tools file: the screen layout is read.
function wm_files.PETools_read_file(context, filename)
	NPL.load("(gl)script/apps/Taurus/WindowManager/wm_loader_readfile.lua");
	local readfile = commonlib.gettable("PETools.Loader.readfile");
	local fileData = readfile.read_from_file(filename);
	if(fileData) then
		wm_files.setup_app_data(context, fileData, filename);
	end
end

-- TODO: read pe tools file: the screen layout is read.
function wm_files.PETools_read_file_from_memory(context)
	-- wm_files.setup_app_data();
end

-- context matching (handle no UI case). assign file data to the given context object. 
-- @param context: wmContext object
-- @param fileData: data read from file. 
-- @param filename: filename where the file data is read. 
function wm_files.setup_app_data(context, fileData, filename)
	local mode = "default";
	local curscreen, curscene;

	if(not fileData.main.screen:first()) then
		-- if there is no screen loaded from the file, we will enter no user interface mode. 
		mode = "NO_UI"; 
	end
	-- XXX here the complex windowmanager matching 
	-- no load screens?
	if(mode == "NO_UI") then
		-- we re-use current screen
		curscreen = context:get_screen();
		-- but use new Scene pointer 
		curscene = fileData.curscene;
		if(not curscene) then 
			curscene = fileData.main.scene:first();
		end
		-- we enforce curscene to be in current screen
		if(curscreen) then
			curscreen.scene = curscene;
		end
	end
	G.main = fileData.main;
	context:set_main(G.main);

	-- case no screens in file
	if(mode == "NO_UI") then
		-- leave entire context further unaltered
		context:set_scene(curscene);
	else
		G.winpos = fileData.winpos;
		G.displaymode = fileData.displaymode;
		G.fileflags = fileData.fileflags;
		
		context:set_screen(fileData.curscreen);
		context:set_scene(fileData.curscreen.scene);
		context:set_area(nil);
		context:set_region(nil);
	end
		
	-- this can happen when active scene was lib-linked, and doesnt exist anymore 
	if(not context:get_scene()) then
		context:set_scene(fileData.main.scene:first());
		context:get_screen().scene = context:get_scene();
		curscene = context:get_scene();
	end
end