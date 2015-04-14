# Author: LiXizhi	
# Company: ParaEngine.com
# Date: 2014.1.25
# Desc: Sample C++ ParaEngine Plugin
# Note: modify this file to set the correct ParaEngine include and boost directory. and then Use CMake to build


cmake_minimum_required(VERSION 2.6)

project (HelloWorldPlugin)

# add the binary tree to the search path for include files
include_directories("${PROJECT_SOURCE_DIR}")
# Note: include the ParaEngine include directory
include_directories("${PROJECT_SOURCE_DIR}/../../../include/ParaEngine")

# include boost
set(BOOST_ROOT ${PROJECT_SOURCE_DIR}/../../../../../Server/trunk/boost_1_55_0)
find_package( Boost )
include_directories("${Boost_INCLUDE_DIRS}")

SET(HelloWorldPlugin_SRCS
	stdafx.h
	stdafx.cpp
	HelloWorld.h
	HelloWorld.cpp
	HelloWorldPlugin.h
	HelloWorldPlugin.cpp
	HelloWorldPlugin.def
	readme.txt
)

IF(MSVC)
	# statically link MSVC to reduce dependancies
	foreach(flag_var CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)
	 	if(${flag_var} MATCHES "/MD")
			string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
	 	endif(${flag_var} MATCHES "/MD")
	 	if(${flag_var} MATCHES "/MDd")
	 		string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
		endif(${flag_var} MATCHES "/MDd")
	endforeach(flag_var)
	
	# /GR- Remove RTTI to miminize the executable size
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /GR-")
	SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi")
ENDIF()


IF(MSVC)
	# generate program database (PDB symbol files even in release build)
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
	SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi")
ENDIF(MSVC)


SET(CMAKE_DEBUG_POSTFIX "_d")

# add the executable
add_library(HelloWorldPlugin SHARED ${HelloWorldPlugin_SRCS})


if(MSVC)
	get_target_property(DEBUG_EXE_PATH OCCPlugin DEBUG_LOCATION)
	STRING(REGEX REPLACE "^.*[/\\]([^/\\]+)$" "\\1" DEBUG_EXE_NAME "${DEBUG_EXE_PATH}" )

	get_target_property(RELEASE_EXE_PATH PhysicsBT RELEASE_LOCATION)
	STRING(REGEX REPLACE "^.*[/\\]([^/\\]+)$" "\\1" RELEASE_EXE_NAME "${RELEASE_EXE_PATH}" )

# Handy post build script, just in case you need it. 
#	ADD_CUSTOM_COMMAND(
#	   TARGET HelloWorldPlugin
#	   POST_BUILD
#	   COMMAND ${CMAKE_COMMAND} -E copy ${DEBUG_EXE_PATH} ${CLIENT_SOURCE_DIR}/../../ParaWorld/${DEBUG_EXE_NAME}
#	   COMMAND ${CMAKE_COMMAND} -E copy ${RELEASE_EXE_PATH} ${CLIENT_SOURCE_DIR}/../../ParaWorld/${RELEASE_EXE_NAME}
#	)

endif(MSVC)