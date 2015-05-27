# Author: LiXizhi
# Company: ParaEngine.com
# Date: 2015.5.12
# Desc: The client exe application for ParaEngine. It is just a small exe that uses ParaEngineClient.dll 
project (MyApp)

# The version number.
set (MyApp_VERSION_MAJOR 1)
set (MyApp_VERSION_MINOR 0)

##############################  
# source code
SET(MyApp_SRCS
	MyApp.cpp		MyApp.h
)

##############################  
# web files
file (GLOB MyApp_FILES RELATIVE ${PROJECT_SOURCE_DIR}
    *.rc *.ico *.txt
    )
SOURCE_GROUP("Files" FILES ${MyApp_FILES})    
list(APPEND MyApp_SRCS ${MyApp_FILES})

##############################
# add the binary tree to the search path for include files
include_directories("${ParaEngineClient_SOURCE_DIR}")
include_directories("${ParaEngineClient_SOURCE_DIR}/Core")
INCLUDE_DIRECTORIES( ${Boost_INCLUDE_DIRS} )

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
	# /Zi generate program database (PDB symbol files even in release build)
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi /GR-")
	SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi")
	# To turn size optimisations on again
	SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /opt:ref /DEBUG /LARGEADDRESSAWARE")
ENDIF()

# add the executable
add_executable(MyApp ${MyApp_SRCS})

# When this property is set to true the executable when linked on Windows will be created with a WinMain() entry point instead of of just main().
set_target_properties(MyApp PROPERTIES WIN32_EXECUTABLE true)
# set_target_properties(MyApp PROPERTIES LINK_FLAGS /MANIFESTUAC:"level='requireAdministrator' uiAccess='false'")
# Since we are installing to local app data dir from now on, we will only need medium integrity level to run the app, however protected mode IE only gives use low IL, in which we need to write to registry to promote this process to medium IL. 
# set_target_properties(MyApp PROPERTIES LINK_FLAGS /MANIFESTUAC:"level='highestAvailable' uiAccess='false'")

set_target_properties(MyApp PROPERTIES OUTPUT_NAME "MyApp")
set_target_properties(MyApp PROPERTIES DEBUG_OUTPUT_NAME "MyApp_d")


# Link the executable to the libraries. 
target_link_libraries (MyApp ) 
