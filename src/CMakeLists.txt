# Author: LiXizhi
# Email: lixizhi@yeah.net
# Date: 2015.4.8
# Desc: this is a custom target. Rebuild to run sync_src.bat.

cmake_minimum_required(VERSION 2.8)

project (ParacraftSrc)

# since the project is for documentation only, we will turn relative path on. 
set(CMAKE_USE_RELATIVE_PATHS ON CACHE INTERNAL "" FORCE)

##############################
file (GLOB_RECURSE ParacraftSrc_NPL_FILES ${PROJECT_SOURCE_DIR}/script/*.lua)
SOURCE_GROUP("npl\\" FILES ${ParacraftSrc_NPL_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_NPL_FILES})


##############################
file (GLOB ParacraftSrc_Config_FILES ${PROJECT_SOURCE_DIR}/config/Aries/creator/*.xml)
SOURCE_GROUP("config\\" FILES ${ParacraftSrc_Config_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_Config_FILES})

##############################
file (GLOB_RECURSE ParacraftSrc_XML_FILES ${PROJECT_SOURCE_DIR}/script/*.xml)
SOURCE_GROUP("mcml\\" FILES ${ParacraftSrc_XML_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_XML_FILES})

file (GLOB_RECURSE ParacraftSrc_HTML_FILES ${PROJECT_SOURCE_DIR}/script/*.html)
SOURCE_GROUP("mcml\\" FILES ${ParacraftSrc_HTML_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_HTML_FILES})

##############################
# doc
SET(ParacraftSrc_MISC_FILES
	sync_src.bat
	readme.txt
)
source_group("" FILES ${ParacraftSrc_MISC_FILES})
list(APPEND ParacraftSrc_SRCS ${ParacraftSrc_MISC_FILES})

##############################
add_custom_target(ParacraftSrc 
	COMMAND ${CMAKE_SOURCE_DIR}/sync_src.bat
	# WORKING_DIRECTORY "../redist/"
	COMMENT "sync Paracraft source ..."
	SOURCES ${ParacraftSrc_SRCS})