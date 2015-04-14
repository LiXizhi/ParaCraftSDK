#pragma once

#ifdef WIN32
#	ifndef _CRT_SECURE_NO_WARNINGS
#		define _CRT_SECURE_NO_WARNINGS
#	endif
#endif

#include "PluginAPI.h"

#include <string>
#include <sstream>
#include <fstream>
#include <map>

#include "INPLRuntimeState.h"
#include "NPLInterface.hpp"

#pragma warning( disable : 4819)