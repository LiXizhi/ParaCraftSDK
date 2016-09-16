# Author: LiXizhi
# Email: lixizhi@yeah.net
# Date: 2015.4.8
# Desc: this is a custom target. Rebuild to run sync_src.bat.

cmake_minimum_required(VERSION 2.8)

project (NPLWebServer)

# since the project is for documentation only, we will turn relative path on. 
set(CMAKE_USE_RELATIVE_PATHS ON)

##############################
file (GLOB_RECURSE NPLWebServer_NPL_FILES ${PROJECT_SOURCE_DIR}/www/*.lua)
SOURCE_GROUP("src\\" FILES ${NPLWebServer_NPL_FILES})
list(APPEND NPLWebServer_SRCS ${NPLWebServer_NPL_FILES})

##############################
file (GLOB_RECURSE NPLWebServer_PAGE_FILES ${PROJECT_SOURCE_DIR}/www/*.page)
SOURCE_GROUP("pages\\" FILES ${NPLWebServer_PAGE_FILES})
list(APPEND NPLWebServer_SRCS ${NPLWebServer_PAGE_FILES})

##############################
file (GLOB_RECURSE NPLWebServer_XML_FILES ${PROJECT_SOURCE_DIR}/www/*.xml)
SOURCE_GROUP("xml\\" FILES ${NPLWebServer_XML_FILES})
list(APPEND NPLWebServer_SRCS ${NPLWebServer_XML_FILES})

##############################
# misc
SET(NPLWebServer_MISC_FILES
	Run.bat
	update_packages.bat
	main.lua
	README.md
)
source_group("" FILES ${NPLWebServer_MISC_FILES})
list(APPEND NPLWebServer_SRCS ${NPLWebServer_MISC_FILES})

##############################
add_custom_target(NPLWebServer 
	COMMAND echo "run it"
	# WORKING_DIRECTORY "../redist/"
	COMMENT "run.bat ..."
	SOURCES ${NPLWebServer_SRCS})