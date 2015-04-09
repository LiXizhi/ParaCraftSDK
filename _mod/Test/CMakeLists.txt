# Author: LiXizhi
# Email: lixizhi@yeah.net
# Date: 2015.4.8
# Desc: this is a custom target. Rebuild to run sync_src.bat.

cmake_minimum_required(VERSION 2.8)

project (ModTest)

# since the project is for documentation only, we will turn relative path on. 
set(CMAKE_USE_RELATIVE_PATHS ON)

##############################
file (GLOB_RECURSE ParacraftSrc_NPL_FILES ${PROJECT_SOURCE_DIR}/*.lua)
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
# misc
SET(ParacraftSrc_MISC_FILES
	Run.bat
)
source_group("" FILES ${ParacraftSrc_MISC_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_MISC_FILES})

##############################
add_custom_target(ModTest 
	COMMAND echo "run it"
	# WORKING_DIRECTORY "../redist/"
	COMMENT "run.bat ..."
	SOURCES ${ParacraftSrc_SRCS})