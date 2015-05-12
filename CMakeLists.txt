# Author: LiXizhi
# Contact: lixizhi@yeah.net
# Date: 2015.4.8
# Note: 

cmake_minimum_required (VERSION 2.8)

# since the project is for documentation only, we will turn relative path on. 
set(CMAKE_USE_RELATIVE_PATHS ON CACHE INTERNAL "" FORCE)

project (ParacraftRoot)

SET(ParaEngineClient_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/include/ParaEngine)

MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

MACRO(AddSubDirs dirpath)
	SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/${dirpath})
	FOREACH(subdir ${SUBDIRS})
		message(STATUS "path = ${subdir}")
		if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${dirpath}/${subdir}/CMakeLists.txt")
			add_subdirectory(${dirpath}/${subdir})
		endif()
	ENDFOREACH()
ENDMACRO()

# src
# add_subdirectory (src)

# add all projects under samples/ folder
AddSubDirs(samples)

AddSubDirs(_apps)

AddSubDirs(_mod)


