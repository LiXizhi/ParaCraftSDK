//-----------------------------------------------------------------------------
// Class:	MyApp 
// Authors:	LiXizhi
// Emails:	LiXizhi@yeah.net
// Company: ParaEngine Co.
// Date:	2015.5.12
// Desc: This exe must be run in the working directory of ParaEngineClient.dll
//-----------------------------------------------------------------------------
#include "PEtypes.h"
#include "IParaEngineApp.h"
#include "IParaEngineCore.h"
#include "PluginLoader.hpp"

#include "MyApp.h"

using namespace ParaEngine;
using namespace MyCompany;

MyCompany::CMyApp::CMyApp(HINSTANCE hInst /*= NULL*/) : m_pParaEngine(NULL), m_pParaEngineApp(NULL), m_hInst(hInst)
{

}

MyCompany::CMyApp::~CMyApp()
{
	if (m_pParaEngineApp){
		m_pParaEngineApp->StopApp();
	}
}

bool MyCompany::CMyApp::CheckLoad()
{
	if (m_ParaEngine_plugin.IsValid())
	{
		return true;
	}

#ifdef _DEBUG
	// post_fix with _d
	m_ParaEngine_plugin.Init("ParaEngineClient_d.dll");
#else
	m_ParaEngine_plugin.Init("ParaEngineClient.dll");
#endif

	int nClassCount = m_ParaEngine_plugin.GetNumberOfClasses();
	for (int i = 0; i < nClassCount; ++i)
	{
		ClassDescriptor* pDesc = m_ParaEngine_plugin.GetClassDescriptor(i);
		if (pDesc)
		{
			if (strcmp(pDesc->ClassName(), "ParaEngine") == 0)
			{
				m_pParaEngine = (ParaEngine::IParaEngineCore*)(pDesc->Create());
			}
		}
	}
	return m_ParaEngine_plugin.IsValid();
}

int MyCompany::CMyApp::Run(HINSTANCE hInst, const char* lpCmdLine)
{
	if (!CheckLoad())
		return E_FAIL;

	m_pParaEngineApp = m_pParaEngine->CreateApp();
	if (m_pParaEngineApp == 0)
		return E_FAIL;

	if (m_pParaEngineApp->StartApp(lpCmdLine) != S_OK)
		return E_FAIL;

	// Set Frame Rate
	//m_pParaEngineApp->SetRefreshTimer(1/45.f, 0);
	m_pParaEngineApp->SetRefreshTimer(1 / 30.f, 0);

	// Run to end
	return m_pParaEngineApp->Run(hInst);
}


//-----------------------------------------------------------------------------
// Name: WinMain()
/// Entry point to the program. Initializes everything, and goes into a
///       message-processing loop. Idle time is used to render the scene.
//-----------------------------------------------------------------------------
INT WINAPI WinMain(HINSTANCE hInst, HINSTANCE, LPSTR lpCmdLine, INT)
{
	std::string sAppCmdLine;
	if (lpCmdLine)
		sAppCmdLine = lpCmdLine;

	// TODO: add your custom command line here
	sAppCmdLine += " mc=true noupdate=true";

	CMyApp myApp(hInst);
	return myApp.Run(0, sAppCmdLine.c_str());
}