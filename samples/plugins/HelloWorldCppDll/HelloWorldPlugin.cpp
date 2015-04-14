#include "stdafx.h"
#include "HelloWorld.h"

#ifdef WIN32
#define CORE_EXPORT_DECL    __declspec(dllexport)
#else
#define CORE_EXPORT_DECL
#endif

// forward declare of exported functions. 
#ifdef __cplusplus
extern "C" {
#endif
	CORE_EXPORT_DECL const char* LibDescription();
	CORE_EXPORT_DECL int LibNumberClasses();
	CORE_EXPORT_DECL unsigned long LibVersion();
	CORE_EXPORT_DECL ParaEngine::ClassDescriptor* LibClassDesc(int i);
	CORE_EXPORT_DECL void LibInit();
	CORE_EXPORT_DECL void LibActivate(int nType, void* pVoid);
#ifdef __cplusplus
}   /* extern "C" */
#endif
 
HINSTANCE Instance = NULL;

using namespace ParaEngine;

ClassDescriptor* HelloWorldPlugin_GetClassDesc();
typedef ClassDescriptor* (*GetClassDescMethod)();

GetClassDescMethod Plugins[] = 
{
	HelloWorldPlugin_GetClassDesc,
};

/** This has to be unique, change this id for each new plugin.
*/
#define HelloWorld_CLASS_ID Class_ID(0x2b905a29, 0x47b409af)

class HelloWorldPluginDesc:public ClassDescriptor
{
public:
	void* Create(bool loading = FALSE)
	{
		return new CHelloWorld();
	}

	const char* ClassName()
	{
		return "IHelloWorld";
	}

	SClass_ID SuperClassID()
	{
		return OBJECT_MODIFIER_CLASS_ID;
	}

	Class_ID ClassID()
	{
		return HelloWorld_CLASS_ID;
	}

	const char* Category() 
	{ 
		return "HelloWorld"; 
	}

	const char* InternalName() 
	{ 
		return "HelloWorld"; 
	}

	HINSTANCE HInstance() 
	{ 
		extern HINSTANCE Instance;
		return Instance; 
	}
};

ClassDescriptor* HelloWorldPlugin_GetClassDesc()
{
	static HelloWorldPluginDesc s_desc;
	return &s_desc;
}

CORE_EXPORT_DECL const char* LibDescription()
{
	return "ParaEngine HelloWorld Ver 1.0.0";
}

CORE_EXPORT_DECL unsigned long LibVersion()
{
	return 1;
}

CORE_EXPORT_DECL int LibNumberClasses()
{
	return sizeof(Plugins)/sizeof(Plugins[0]);
}

CORE_EXPORT_DECL ClassDescriptor* LibClassDesc(int i)
{
	if (i < LibNumberClasses() && Plugins[i])
	{
		return Plugins[i]();
	}
	else
	{
		return NULL;
	}
}

CORE_EXPORT_DECL void LibInit()
{
}

#ifdef WIN32
BOOL WINAPI DllMain(HINSTANCE hinstDLL,ULONG fdwReason,LPVOID lpvReserved)
#else
void __attribute__ ((constructor)) DllMain()
#endif
{
	// TODO: dll start up code here
#ifdef WIN32
	Instance = hinstDLL;				// Hang on to this DLL's instance handle.
	return (TRUE);
#endif
}

/** this is the main activate function to be called, when someone calls NPL.activate("this_file.dll", msg); 
*/
CORE_EXPORT_DECL void LibActivate(int nType, void* pVoid)
{
	if(nType == ParaEngine::PluginActType_STATE)
	{
		NPL::INPLRuntimeState* pState = (NPL::INPLRuntimeState*)pVoid;
		const char* sMsg = pState->GetCurrentMsg();
		int nMsgLength = pState->GetCurrentMsgLength();

		NPLInterface::NPLObjectProxy input_msg = NPLInterface::NPLHelper::MsgStringToNPLTable(sMsg);
		const std::string& sCmd = input_msg["cmd"];
		if(sCmd == "hello" || true)
		{
			NPLInterface::NPLObjectProxy output_msg;
			output_msg["succeed"] = "true";
			output_msg["sample_number_output"] = (double)(1234567);
			output_msg["result"] = "hello world!";

			std::string output;
			NPLInterface::NPLHelper::NPLTableToString("msg", output_msg, output);
			pState->activate("script/test/echo.lua", output.c_str(), output.size());
		}
	}
}
