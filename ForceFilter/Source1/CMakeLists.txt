

cmake_minimum_required(VERSION 2.8.9)
if(POLICY CMP0048)
  cmake_policy(SET CMP0048 OLD)
endif()
if(POLICY CMP0017)
  cmake_policy(SET CMP0017 OLD)
endif()
foreach(p
  CMP0054 # CMake 3.1
  )
  if(POLICY ${p})
    cmake_policy(SET ${p} NEW)
  endif()
endforeach()

#-----------------------------------------------------------------------------
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})


set(ProjectName RobotForce)
project(${ProjectName})

set(${ProjectName}_CMAKE_DIR ${${ProjectName}_SOURCE_DIR}/CMake)

#-----------------------------------------------------------------------------
# Set the header template which defines custom export/import macros
# for shared libraries
#-----------------------------------------------------------------------------
set(${ProjectName}_EXPORT_HEADER_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/CMake/qTIGSExport.h.in")  

#-----------------------------------------------------------------------------
# Qt requirements
#-----------------------------------------------------------------------------
#need add Qt5 support

if(NOT DEFINED TIGS_REQUIRED_QT_VERSION)
  set(TIGS_REQUIRED_QT_VERSION "5" CACHE STRING "Minimum required Qt version" FORCE)
endif()

set(TIGS_QT5_COMPONENTS Core Xml XmlPatterns Concurrent Sql Widgets Network OpenGL UiTools)

find_package(Qt5 COMPONENTS ${TIGS_QT5_COMPONENTS} REQUIRED)

#----------------------------------------------------------------------------
# Build shared lib by default
#------------------------------------------------------------------------------
# option(BUILD_SHARED_LIBS "Build TIGS with shared libraries." ON)
set(BUILD_SHARED_LIBS ON)

#-----------------------------------------------------------------------------
# VTK
#-----------------------------------------------------------------------------
#find_package(VTK REQUIRED)
#include(${VTK_USE_FILE})

#option(TIGS_USE_VTK_DEBUG_LEAKS "Enable VTKs Debug Leaks functionality in #both VTK and TIGS." ON)
#set(VTK_DEBUG_LEAKS ${TIGS_USE_VTK_DEBUG_LEAKS})

### 添加其他�?


#-----------------------------------------------------------------------------
# Project sub-directories
#-----------------------------------------------------------------------------
set(${ProjectName}_BIN_DIR "bin")
set(${ProjectName}_LIB_DIR "lib/${ProjectName}")
set(${ProjectName}_INCLUDE_DIR "include/${ProjectName}")
set(${ProjectName}_SHARE_DIR "share/${ProjectName}")
set(${ProjectName}_LIBEXEC_DIR "libexec/${ProjectName}")

#-----------------------------------------------------------------------------
# Project install directories
#-----------------------------------------------------------------------------
set(${ProjectName}_INSTALL_ROOT "${${ProjectName}_BINARY_DIR}/")

set(${ProjectName}_INSTALL_BIN_DIR "${${ProjectName}_INSTALL_ROOT}${${ProjectName}_BIN_DIR}")
set(${ProjectName}_INSTALL_LIB_DIR "${${ProjectName}_INSTALL_ROOT}${${ProjectName}_LIB_DIR}")
set(${ProjectName}_INSTALL_INCLUDE_DIR "${${ProjectName}_INSTALL_ROOT}${${ProjectName}_INCLUDE_DIR}")
set(${ProjectName}_INSTALL_SHARE_DIR "${${ProjectName}_INSTALL_ROOT}${${ProjectName}_SHARE_DIR}")
set(${ProjectName}_INSTALL_LIBEXEC_DIR "${${ProjectName}_INSTALL_ROOT}${${ProjectName}_LIBEXEC_DIR}")

#-----------------------------------------------------------------------------
# Output directories.
#------------------------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${${ProjectName}_BINARY_DIR}/${${ProjectName}_BIN_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${${ProjectName}_BINARY_DIR}/${${ProjectName}_BIN_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${${ProjectName}_BINARY_DIR}/${${ProjectName}_LIB_DIR})

#-----------------------------------------------------------------------------
# Project Home
#------------------------------------------------------------------------------
set(${ProjectName}_HOME "${${ProjectName}_BINARY_DIR}")

#-----------------------------------------------------------------------------
# Set CMAKE_{C,CXX}_FLAGS variables
#-----------------------------------------------------------------------------
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS_INIT} ${TIGS_REQUIRED_C_FLAGS} ${ITK_REQUIRED_C_FLAGS} ${COVERAGE_C_FLAGS} ${ADDITIONAL_C_FLAGS}" CACHE STRING "CMake C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT} ${TIGS_REQUIRED_CXX_FLAGS} ${ITK_REQUIRED_CXX_FLAGS} ${COVERAGE_CXX_FLAGS} ${ADDITIONAL_CXX_FLAGS}" CACHE STRING "CMake CXX Flags" FORCE)


#-----------------------------------------------------------------------------
# Subdirectories
#-----------------------------------------------------------------------------
SET(${ProjectName}_MODULE_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/Module)
SET(${ProjectName}_MODULE_INCLUDE_DIRS  CACHE INTERNAL "" FORCE) # CACHE INTERNAL "" )

include(MacroBuildBaseQtLibrary)

#-----------------------------------------------------------------------------
# Applications
#-----------------------------------------------------------------------------

add_subdirectory(Application)


#file(COPY config DESTINATION ${CMAKE_CURRENT_BINARY_DIR})





