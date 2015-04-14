//-----------------------------------------------------------------------------
// Copyright (C) 2007 - 2010 ParaEngine Co. All Rights Reserved.
// Author: LiXizhi
// Date: 2006.8
// Description:	API for ParaEngine types. 
//-----------------------------------------------------------------------------
#pragma once

// Cross-platform type definitions
#ifdef WIN32
#ifndef PARAENGINE_CLIENT
/* Prevent inclusion of winsock.h in windows.h, otherwise boost::Asio will produce error in ParaEngineServer project: WinSock.h has already been included*/ 
#define WIN32_LEAN_AND_MEAN    
#endif
#include <windows.h>
#include <stdio.h>
#include <wchar.h>
#else// For LINUX
#include <ctype.h>
#include <wctype.h>
#include <unistd.h>
#include <string.h>
#include <wchar.h>
#include <stdarg.h>
#include <malloc.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#endif // WIN32

#include <assert.h>

// Cross-platform type definitions
#ifdef WIN32
typedef signed char int8;
typedef short int16;
typedef long int32;
typedef __int64 int64;
typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned long uint32;
typedef unsigned __int64 uint64;
typedef unsigned char byte;
#ifndef STDCALL 
#define STDCALL __stdcall
#endif 

#else // For LINUX
typedef int8_t int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;
typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;
typedef uint8_t byte;
#define FALSE 0
#define TRUE 1
#define VOID            void
typedef void * HANDLE;
typedef void * HWND;
typedef void * HANDLE;
typedef void * HMODULE;
typedef void * HINSTANCE;
typedef void *PVOID;
typedef void *LPVOID;
typedef float FLOAT;
typedef uint32_t DWORD;
typedef DWORD *LPDWORD;
typedef const void * LPCVOID;
typedef char CHAR;
typedef wchar_t WCHAR;
typedef uint16_t WORD;
typedef float               FLOAT;
typedef int                 BOOL;
typedef unsigned char       BYTE;
typedef int                 INT;
typedef unsigned int        UINT;
typedef int32_t LONG;
typedef uint32_t ULONG;
typedef int32_t HRESULT;

typedef struct tagRECT
{
	LONG left;
	LONG top;
	LONG right;
	LONG bottom;
} 	RECT;

#define FILE_BEGIN           0
#define FILE_CURRENT         1
#define FILE_END             2

#ifndef STDCALL 
#define STDCALL __attribute__((stdcall)) 
#endif 

#define _HRESULT_TYPEDEF_(_sc) ((HRESULT)_sc)
#define E_FAIL		((HRESULT)(0x80000008L))
// emulate windows error msg in linux
#define E_ACCESSDENIED                   _HRESULT_TYPEDEF_(0x80070005L)
#define E_INVALIDARG                     _HRESULT_TYPEDEF_(0x80000003L)
#define E_PENDING                        _HRESULT_TYPEDEF_(0x8000000AL)

typedef struct _FILETIME
{
	DWORD dwLowDateTime;
	DWORD dwHighDateTime;
} 	FILETIME;
#define MAX_PATH          260
#endif // WIN32

#ifndef SUCCEEDED
#define SUCCEEDED(hr)  ((HRESULT)(hr) >= 0)
#endif

#ifndef SAFE_DELETE
#define SAFE_DELETE(x)  if((x)!=0){delete (x);x=0;}
#endif

#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(x)  if((x)!=0){delete [] (x);x=0;}
#endif

#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p)      { if(p) { (p)->Release(); (p)=NULL; } }
#endif

#ifndef FAILED
#define FAILED(hr)  ((HRESULT)(hr) < 0)
#endif

#ifndef S_OK
#define S_OK  ((HRESULT)0x00000000L)
#endif

#ifndef UCHAR_MAX
#define UCHAR_MAX     0xff      /* maximum unsigned char value */
#endif

namespace ParaEngine
{
	/** event type */
	enum EventType{
		EVENT_MOUSE=0, // mouse click
		EVENT_KEY,
		EVENT_EDITOR,
		EVENT_SYSTEM,
		EVENT_NETWORK,
		EVENT_MOUSE_MOVE,
		EVENT_MOUSE_DOWN,
		EVENT_MOUSE_UP,
		EVENT_KEY_UP,
		EVENT_MOUSE_WHEEL,
		EVENT_LAST
	};
	/** bit fields */
	enum EventHandler_type
	{
		EH_MOUSE = 0x1, // mouse click
		EH_KEY = 0x1<<1,
		EH_EDITOR = 0x1<<2,
		EH_SYSTEM = 0x1<<3,
		EH_NETWORK = 0x1<<4,
		EH_MOUSE_MOVE = 0x1<<5,
		EH_MOUSE_DOWN = 0x1<<6,
		EH_MOUSE_UP = 0x1<<7,
		EH_KEY_UP = 0x1<<8,
		EH_MOUSE_WHEEL = 0x1<<9,
		EH_ALL = 0xffff,
	};

	/**
	* class ID for built-in classes only. 
	*/
	typedef int SClass_ID;  


	/** activation file type in the plug-in's Activate() function. */
	enum PluginActivationType
	{
		PluginActType_NONE = 0,
		/// this is obsoleted, use PluginActType_STATE
		PluginActType_SCODE, 
		/// from the NPL activate function call. the second paramter to LibActivate() will be pointer of INPLRuntimeState. Use GetCurrentMsg() and GetCurrentMsgLength() to retrieve the message. 
		PluginActType_STATE, 
	};

	/**
	* This class represents the unique class ID for a ParaEngine plug-in. A plug-ins Class_ID must be unique. 
	A Class_ID consists of two unsigned 32-bit quantities. The constructor assigns a value to each of these, 
	for example Class_ID(0x11261982, 0x19821126).
	@remark: Only the built-in classes (those that ship with ParaEngine) should have the second 32 bits equal to 0. 
	All plug-in developers should use both 32 bit quantities.
	*/
	class Class_ID 
	{
		unsigned long a,b;
	public:
		Class_ID() { a = b = 0xffffffff; }
		Class_ID(const Class_ID& cid) { a = cid.a; b = cid.b;	}
		Class_ID(unsigned long  aa, unsigned long  bb) { a = aa; b = bb; }
		unsigned long  PartA() { return a; }
		unsigned long  PartB() { return b; }
		void SetPartA( unsigned long  aa ) { a = aa; } //-- Added 11/21/96 GG
		void SetPartB( unsigned long  bb ) { b = bb; }
		int operator==(const Class_ID& cid) const { return (a==cid.a&&b==cid.b); }
		int operator!=(const Class_ID& cid) const { return (a!=cid.a||b!=cid.b); }
		Class_ID& operator=(const Class_ID& cid)  { a=cid.a; b = cid.b; return (*this); }
		// less operator - allows for ordering Class_IDs (used by stl maps for example) 
		bool operator<(const Class_ID& rhs) const
		{
			if ( a < rhs.a || ( a == rhs.a && b < rhs.b ) )
				return true;

			return false;
		}
	};

	/**
	* an interface ID 
	*/
	class Interface_ID 
	{
		unsigned long a,b;
	public:
		Interface_ID() { a = b = 0xffffffff; }
		Interface_ID(const Interface_ID& iid) { a = iid.a; b = iid.b;	}
		Interface_ID(unsigned long  aa, unsigned long  bb) { a = aa; b = bb; }
		unsigned long  PartA() { return a; }
		unsigned long  PartB() { return b; }
		void SetPartA( unsigned long  aa ) { a = aa; }
		void SetPartB( unsigned long  bb ) { b = bb; }
		int operator==(const Interface_ID& iid) const { return (a==iid.a&&b==iid.b); }
		int operator!=(const Interface_ID& iid) const { return (a!=iid.a||b!=iid.b); }
		Interface_ID& operator=(const Interface_ID& iid)  { a=iid.a; b = iid.b; return (*this); }
		// less operator - allows for ordering Class_IDs (used by stl maps for example) 
		bool operator<(const Interface_ID& rhs) const
		{
			if ( a < rhs.a || ( a == rhs.a && b < rhs.b ) )
				return true;

			return false;
		}
	};

	struct PARAVECTOR2	{
		float x;
		float y;
		PARAVECTOR2(float x_, float y_):x(x_), y(y_){}
		PARAVECTOR2(){};
	};

	struct PARAVECTOR3	{
		float x;
		float y;
		float z;
		PARAVECTOR3(float x_, float y_, float z_):x(x_), y(y_),z(z_){}
		PARAVECTOR3(){};
	};

	struct PARAVECTOR4	{
		float x;
		float y;
		float z;
	};

	struct PARAMATRIX {
		union {
			struct {
				float        _11, _12, _13, _14;
				float        _21, _22, _23, _24;
				float        _31, _32, _33, _34;
				float        _41, _42, _43, _44;
			};
			float m[4][4];
		};
	};

	struct PARAMATRIX3x3 {
		union {
			struct {
				float        _11, _12, _13;
				float        _21, _22, _23;
				float        _31, _32, _33;
			};
			float m[3][3];
		};
	};

	struct PARARECT {
		int32 x1;
		int32 y1;
		int32 x2;
		int32 y2;
	};

	struct PARACOLORVALUE {
		float r;
		float g;
		float b;
		float a;
	};
}
