#pragma once
#include "IParaEngineApp.h"
#include "CommandLineParams.h"

namespace ParaEngine
{
	/* base implementation of ParaEngine APP, shared by both mobile and pc version.  */
	class CParaEngineAppBase : public IParaEngineApp, public CCommandLineParams
	{
	public:
		CParaEngineAppBase();
		CParaEngineAppBase(const char* sCmd);

		void DoTestCode();

		virtual ~CParaEngineAppBase();


		/** call this function at the end of the frame. */
		virtual void OnFrameEnded();

	public:
		virtual void WriteToLog(const char* sFormat, ...);
		virtual void AppLog(const char* sFormat);
		/** set the current working directory. This function is called in the constructor to ensure that all IO directs to the right dir. */
		virtual bool FindParaEngineDirectory(const char* sHint = NULL);

		void AutoSetLocale();

		/** disable 3D rendering, do not present the scene.
		* This is usually called before and after we show a standard win32 window during full screen mode, such as displaying a flash window
		* @param bEnable: true to enable.
		*/
		virtual void Enable3DRendering(bool bEnable);

		/** whether 3D rendering is enabled, do not present the scene.
		* This is usually called before and after we show a standard win32 window during full screen mode, such as displaying a flash window */
		virtual bool Is3DRenderingEnabled();

		/** whether the last mouse input is from touch or mouse. by default it is mouse mode. */
		virtual bool IsTouchInputting();
		virtual void SetTouchInputting(bool bTouchInputting);
		virtual bool IsSlateMode();
		/** obsoleted function: */
		virtual int32 GetTouchPointX()  { return 0; };
		virtual int32 GetTouchPointY()  { return 0; };

		/** get the current mouse cursor position.
		* @param pX: out
		* @param pY: out
		* @param bInBackbuffer: if true, it will scale the output according to the ratio of back buffer and current window size.
		*/
		virtual void GetCursorPosition(int* pX, int * pY, bool bInBackbuffer = true);

		/** translate a position from game coordination system to client window position.
		* @param inout_x: in and out
		* @param inout_y: in and out
		* @param bInBackbuffer: if true, it will scale the output according to the ratio of back buffer and current window size.
		*/
		virtual void GameToClient(int& inout_x, int & inout_y, bool bInBackbuffer = true) { };

		/** translate a position from client window position to game coordination system.
		* @param inout_x: in and out
		* @param inout_y: in and out
		* @param bInBackbuffer: if true, it will scale the output according to the ratio of back buffer and current window size.
		*/
		virtual void ClientToGame(int& inout_x, int & inout_y, bool bInBackbuffer = true){ };

		/** switch to ignore windows size change. default to false.
		* if false, the user is allowed to adjust window size in windowed mode. */
		virtual void SetIgnoreWindowSizeChange(bool bIgnoreSizeChange){};

		/** return true if it is currently under windowed mode. */
		virtual bool GetIgnoreWindowSizeChange(){ return false; };

		/** get the module handle, it may be exe or the dll handle, depending on how the main host app is built. */
		virtual HINSTANCE GetModuleHandle()  { return 0; };

		/**
		* Set the frame rate timer interval
		* @param fTimeInterval:  value in seconds. such as 0.033f or 0.01667f
		* 	Passing a value <= 0 to render in idle time.
		* @param nFrameRateControl: 0 for real time, 1 for ideal frame rate at 30 FPS no matter whatever time interval is set.
		*/
		virtual void SetRefreshTimer(float fTimeInterval, int nFrameRateControl = 0) { };

		/** get the refresh timer.
		*/
		virtual float GetRefreshTimer()  { return 0; };

		/** this function is called whenever the application is disabled or enabled. usually called when receiving the WM_ACTIVATEAPP message.
		* [main thread only]
		*/
		virtual void ActivateApp(bool bActivate) { };

		/** whether the application is active or not. */
		virtual bool IsAppActive();

		/** Get the current ParaEngine app usage.
		* [main thread only]
		* @return see PE_USAGE
		*/
		virtual DWORD GetCoreUsage();

		/** Set the current ParaEngine app usage.
		* [main thread only]
		* @param dwUsage: bitwise of PE_USAGE
		*/
		virtual void SetCoreUsage(DWORD dwUsage) { };


		/** Get the exit code that will be used when the standalone executable exit.
		* this is mainly used for writing test cases. Where a return value of 0 means success, any other value means failure.
		*/
		virtual void SetReturnCode(int nReturnCode);
		virtual int GetReturnCode();

		/** show a system message box to the user. mostly about fatal error.  */
		virtual void SystemMessageBox(const std::string& msg);
	protected:
		/** shared init called in constructor.  */
		void InitCommon();
		void DestroySingletons();

		/** we will load all packages that matches the following pattern in the order given by their name,
		* such that "main_001.pkg" is always loaded before "main_002.pkg" 
		* we will skip packages *_32bits.pkg when in 64bits; and skip *_64bits.pkg in 32bits; packages without above suffix will be loaded in both version. 
		*/
		void LoadPackages();
		
		/** register a given class. */
		void RegisterObjectClass(IAttributeFields* pObject);

		/** register any custom classes */
		void RegisterObjectClasses();
	protected:
		bool m_bEnable3DRendering;
		bool m_isTouching;
		/** the application exit code or return code. 0 means success. otherwise means a failure. */
		int m_nReturnCode;
	};
}

