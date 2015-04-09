# Author: LiXizhi
# Email: lixizhi@yeah.net
# Date: 2015.4.8
# Desc: this is a custom target. 

cmake_minimum_required(VERSION 2.8)

project (Paracraft)

# since the project is for documentation only, we will turn relative path on. 
set(CMAKE_USE_RELATIVE_PATHS ON)

##############################
file (GLOB_RECURSE ParacraftSrc_NPL_FILES ${PROJECT_SOURCE_DIR}/source/*.lua)
SOURCE_GROUP("npl\\" FILES ${ParacraftSrc_NPL_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_NPL_FILES})

##############################
file (GLOB_RECURSE ParacraftSrc_XML_FILES ${PROJECT_SOURCE_DIR}/*.xml)
SOURCE_GROUP("mcml\\" FILES ${ParacraftSrc_XML_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_XML_FILES})

file (GLOB_RECURSE ParacraftSrc_HTML_FILES ${PROJECT_SOURCE_DIR}/*.html)
SOURCE_GROUP("mcml\\" FILES ${ParacraftSrc_HTML_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_HTML_FILES})

##############################
file (GLOB_RECURSE ParacraftSrc_Android_FILES ${PROJECT_SOURCE_DIR}/*.bat)
SOURCE_GROUP("proj.android\\" FILES ${ParacraftSrc_Android_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_Android_FILES})

##############################
# misc
SET(ParacraftSrc_MISC_FILES
	Run.bat
	Run.peworld
	Paracraft.nsi
	proj.android/assets/res/config.txt
)
source_group("" FILES ${ParacraftSrc_MISC_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_MISC_FILES})

##############################
add_custom_target(Paracraft 
	COMMAND echo "Paracraft ..."
	# WORKING_DIRECTORY "../redist/"
	COMMENT "skipping Paracraft..."
	SOURCES ${ParacraftSrc_SRCS})