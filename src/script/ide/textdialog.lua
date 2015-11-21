--[[ 
Title: 3D text dialog lib 0.9 for ParaEngine
Author(s): LiuWeili
Date: 2005/10
desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/textdialog.lua");
-------------------------------------------------------
function list:
_textdialog.show(value)
_textdialog.clearall()
example:
	local value={};
	value.page={};
	value.page[1]="11111 first page";
	value.page[2]="22222 second page";
	value.toolbar=true;
	value.obj=ParaScene.GetObject("<player>")
	_textdialog.show(value);
]]
_textdialog={};
_textdialog.list={};
_textdialog.counter=0;
_textdialog.lastx=0;
_textdialog.lasty=0;

function _textdialog.clearall()
	local str,index;
	index=1;
	while(_textdialog.list[index]~=nil)do
		_textdialog.close(index);
		index=index+1;
	end
	_textdialog.counter=0;
end

function _textdialog.check(value)
	if(value~=nil)then
		if(value.width==nil) then
			value.width=150;
		end
		if(value.height==nil) then
			value.height=100;
		end
		if(value.x==nil) then
			value.x=-value.width/2;
		end
		if(value.y==nil) then
			value.y=-value.height/2;
		end
		if(value.obj==nil)then
			value.width=150;
			value.height=100;
			value.x=_textdialog.lastx;
			value.y=_textdialog.lasty;
		end
		if(value.scrollable==nil)then
			value.scrollable=false;
		end
		if(value.toolbar==nil)then
			value.toolbar=false;
		end
		if(value.transparency==nil)then
			value.transparency=255;
		end
		if(value.clearothers==nil)then
			value.clearothers=false;
		end
		if(value.text==nil)then 
			if(value.page==nil)then
				value.text="";
			else
				if (value.page[1]==nil)then
					value.text="";
				end
			end
		else
			value.page={};
			value.page[1]=value.text;
		end
		if(value.size==nil)then
			if(value.page~=nil) then
				local index=1;
				while(value.page[index]~=nil)do
					index=index+1;
				end
				value.size=index-1;
			else
				value.size=0;
			end
		end
		if(value.pagenumber==nil)then 
			value.pagenumber=1;
		end

	end
	
	return value;
end

function _textdialog.show(value)
	local ctrl, parent, str,str1,dialog;
	value=_textdialog.check(value);
	if(value==nil) then
		return;
	end
	
	if(value.clearothers==true)then
		_textdialog.clearall();
	end
	_textdialog.counter=_textdialog.counter+1;
	
	dialog={};
	dialog.pagenumber=value.pagenumber;
	dialog.index=_textdialog.counter;
	dialog.size=value.size;
	dialog.page=clone(value.page);
	dialog.text=value.text;
	
	_textdialog.list[_textdialog.counter]=dialog;
	
	ctrl=ParaUI.CreateUIObject("container","textdialog_main".._textdialog.counter,"_lt",value.x,value.y,value.width,value.height);
	ctrl:AttachToRoot();
	ctrl.background="Texture/speak_box.png";
	if(value.obj~=nil)then
		ctrl:AttachTo3D(value.obj);
	else
		ctrl.candrag=true;
		str="(gl)empty.lua;local ctrl=ParaUI.GetUIObject(\"";
		str=str..ctrl.name;
		str=str.."\");_textdialog.lastx=ctrl.x;_textdialog.lasty=ctrl.y;";
		ctrl.ondragend=str;
		ParaGlobal.WriteToLogFile("\nondragend:"..str);
	end
	ctrl.scrollable=false;
	
	if(value.toolbar==true)then
		parent=ctrl;
	--[[	ctrl=ParaUI.CreateUIObject("container","textdialog_textwin".._textdialog.counter,"_lt",0,0,value.width,value.height-30);
		parent:AddChild(ctrl);
		ctrl.scrollable=value.scrollable;--]]
		
		ctrl=ParaUI.CreateUIObject("button","textdialog_btnok".._textdialog.counter,"_lb",0,-30,30,30);
		parent:AddChild(ctrl);
		ctrl.background="Texture/arr_no.png";
		str="(gl)empty.lua;_textdialog.close(".._textdialog.counter;
		str=str..");";
		ctrl.onclick=str;
--		ParaGlobal.WriteToLogFile("\nbutton ok:"..str);
		
		ctrl=ParaUI.CreateUIObject("button","textdialog_btnleft".._textdialog.counter,"_lb",30,-30,30,30);
		parent:AddChild(ctrl);
		ctrl.background="Texture/arr_l.png";
		str1="_textdialog.list[".._textdialog.counter;
		str1=str1.."].pagenumber";
		str="(gl)empty.lua;if ("..str1;
		str=str..">1)then \n";
		str=str..str1;
		str=str.."=";
		str=str..str1;
		str=str.."-1;end;_textdialog.showpage(";
		str=str.._textdialog.counter;
		str=str..",";
		str=str..str1;
		str=str..");"
		ctrl.onclick=str;
--		ParaGlobal.WriteToLogFile("\nbutton left:"..str);
		
		ctrl=ParaUI.CreateUIObject("button","textdialog_btnright".._textdialog.counter,"_lb",60,-30,30,30);
		parent:AddChild(ctrl);
		ctrl.background="Texture/arr_r.png";
		str1="_textdialog.list[".._textdialog.counter;
		str1=str1.."]";
		str="(gl)empty.lua;if ("..str1;
		str=str..".pagenumber<";
		str=str..str1;
		str=str..".size)then \n";
		str=str..str1;
		str=str..".pagenumber=";
		str=str..str1;
		str=str..".pagenumber+1;end;_textdialog.showpage(";
		str=str.._textdialog.counter;
		str=str..",";
		str=str..str1;
		str=str..".pagenumber);"
		ctrl.onclick=str;
--		ParaGlobal.WriteToLogFile("\nbutton right:"..str);

		ctrl=ParaUI.CreateUIObject("text","textdialog_pagenum".._textdialog.counter,"_rb",-50,-25,20,20);
		parent:AddChild(ctrl);
		ctrl.text=""..value.pagenumber;

		ctrl=ParaUI.CreateUIObject("text","textdialog_pagesper".._textdialog.counter,"_rb",-30,-25,8,20);
		parent:AddChild(ctrl);
		ctrl.text="/";

		ctrl=ParaUI.CreateUIObject("text","textdialog_pagetotal".._textdialog.counter,"_rb",-22,-25,20,20);
		parent:AddChild(ctrl);
		ctrl.text=""..value.size;
	end
	
	
	parent=ParaUI.GetUIObject("textdialog_main".._textdialog.counter);
	if(parent:IsValid()==false)then
		ParaGlobal.WriteToLogFile("\ntextdialog_textwin nil");
		return;
	end
		
	ctrl=ParaUI.CreateUIObject("text","textdialog_text".._textdialog.counter,"_lt",0,0,parent.width-2,parent.height-30);
	parent:AddChild(ctrl);
	ctrl.autosize=false;
	_textdialog.showpage(_textdialog.counter,value.pagenumber);
end

function _textdialog.showpage(index,pagenumber)
	if(_textdialog.list[index]==nil or _textdialog.list[index].index==0)then
		ParaGlobal.WriteToLogFile("textdialog_showpage index nil\n");
		return;
	end
	if(pagenumber<=_textdialog.list[index].size and pagenumber>0)then
		_textdialog.list[index].text=_textdialog.list[index].page[pagenumber];
		_textdialog.update(index);
	--show the page text
	end
end

function _textdialog.update(index)
	if(_textdialog.list[index]==nil or _textdialog.list[index].index==0)then
		ParaGlobal.WriteToLogFile("textdialog_update index nil\n");
		return;
	end
	local ctrl=ParaUI.GetUIObject("textdialog_text"..index);
	if(ctrl:IsValid()==false)then
		local str="\ntextdialog_text"..index;
		str=str.." not found";
		ParaGlobal.WriteToLogFile(str);
		return;
	end
	ctrl.text=_textdialog.list[index].text;

	local ctrl=ParaUI.GetUIObject("textdialog_pagenum"..index);
	if(ctrl:IsValid()==false)then
		local str="\ntextdialog_pagenum"..index;
		str=str.." not found";
		ParaGlobal.WriteToLogFile(str);
		return;
	end
	ctrl.text="".._textdialog.list[index].pagenumber;

	local ctrl=ParaUI.GetUIObject("textdialog_pagetotal"..index);
	if(ctrl:IsValid()==false)then
		local str="\ntextdialog_pagetotal"..index;
		str=str.." not found";
		ParaGlobal.WriteToLogFile(str);
		return;
	end
	ctrl.text="".._textdialog.list[index].size;
end

function _textdialog.close(index)
	if(_textdialog.list[index]==nil or _textdialog.list[index].index==0)then
		ParaGlobal.WriteToLogFile("textdialog_close index nil\n");
		return;
	end
	_textdialog.list[index].index=0;
	ParaUI.Destroy("textdialog_main"..index);
end

function clone(value)
	if(value==nil)then
		return nil;
	end
	local newvalue;
	if(type(value)~="table")then
        newvalue=value;
    else
    	newvalue={};
    	for k,v in pairs(value) do
    		if(v~=nil and k~=nil)then
    			if(type(v)~="table")then
    				newvalue[k]=v;
    			else
    				newvalue[k]=clone(v);
    			end
    		end
    	end
	end
	
	return newvalue;
	
end
--[[
local function activate()
			local value={};
			value.page={};
			value.page[1]="11111 first page";
			value.page[2]="22222 second page";
			value.toolbar=true;
			local player = ParaScene.GetObject("<player>");
			value.obj=player;
			ParaGlobal.WriteToLogFile("fdaf");
			_textdialog.show(value);
	
end

NPL.this(activate);--]]
