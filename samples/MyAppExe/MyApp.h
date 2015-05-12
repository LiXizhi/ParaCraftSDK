namespace MyCompany
{
	class CMyApp
	{
	public:
		CMyApp(HINSTANCE hInst = NULL);
		~CMyApp();

		/** load the ParaEngine plug in dll if not.
		* @return true if loaded.
		*/
		bool CheckLoad();

		/** run the application */
		int Run(HINSTANCE hInst, const char* lpCmdLine);

	private:
		ParaEngine::CPluginLoader m_ParaEngine_plugin;
		ParaEngine::IParaEngineCore * m_pParaEngine;
		ParaEngine::IParaEngineApp * m_pParaEngineApp;
		HINSTANCE m_hInst;
	};
}