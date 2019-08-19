################################################################################
#
#  Program: 3D Slicer
#
#  Copyright (c) Kitware Inc.
#
#  See COPYRIGHT.txt
#  or http://www.slicer.org/copyright/copyright.txt for details.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  This file was originally developed by Jean-Christophe Fillion-Robin, Kitware Inc.
#  and was partially funded by NIH grant 3P41RR013218-12S1
#
################################################################################

#
# TIGSMacroBuildBaseQtLibrary
#

#
# Parameters:
#
#   NAME .................: Name of the library
#
#   EXPORT_DIRECTIVE .....: Export directive that should be used to export symbol
#
#   SRCS .................: List of source files
#
#   MOC_SRCS .............: Optional list of headers to run through the meta object compiler (moc)
#                           using QT4_WRAP_CPP CMake macro
#
#   UI_SRCS ..............: Optional list of UI file to run through UI compiler (uic) using
#                           QT4_WRAP_UI CMake macro
#
#   INCLUDE_DIRECTORIES ..: Optional list of extra folder that should be included. See implementation
#                           for the list of folder included by default.
#
#   TARGET_LIBRARIES .....: Optional list of target libraries that should be used with TARGET_LINK_LIBRARIES
#                           CMake macro. See implementation for the list of libraries added by default.
#
#   RESOURCES ............: Optional list of files that should be converted into resource header
#                           using QT4_ADD_RESOURCES
#
# Options:
#
#   WRAP_PYTHONQT ........: If specified, the sources (SRCS) will be 'PythonQt' wrapped and a static
#                           library named <NAME>PythonQt will be built.
#

macro(TIGSMacroBuildModuleLibrary)
  set(options
    WRAP_PYTHONQT
    )
  set(oneValueArgs
    NAME
    EXPORT_DIRECTIVE
    )
  set(multiValueArgs
    SRCS
    MOC_SRCS
    UI_SRCS
    INCLUDE_DIRECTORIES
    TARGET_LIBRARIES
    RESOURCES
    )
  CMAKE_PARSE_ARGUMENTS(TIGSMODULELIB
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  message(STATUS "Configuring ${TIGS_MAIN_PROJECT_APPLICATION_NAME} Module library: ${TIGSMODULELIB_NAME}")
  # --------------------------------------------------------------------------
  # Sanity checks
  # --------------------------------------------------------------------------
  if(TIGSMODULELIB_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to TIGSMacroBuildModuleLibrary(): \"${TIGSQTBASELIB_UNPARSED_ARGUMENTS}\"")
  endif()

  set(expected_defined_vars NAME EXPORT_DIRECTIVE)
  foreach(var ${expected_defined_vars})
    if(NOT DEFINED TIGSMODULELIB_${var})
      message(FATAL_ERROR "${var} is mandatory")
    endif()
  endforeach()

  if(NOT DEFINED TIGS_INSTALL_NO_DEVELOPMENT)
    message(SEND_ERROR "TIGS_INSTALL_NO_DEVELOPMENT is mandatory")
  endif()

  # --------------------------------------------------------------------------
  # Define library name
  # --------------------------------------------------------------------------
  set(lib_name ${TIGSMODULELIB_NAME})

  # --------------------------------------------------------------------------
  # Include dirs
  # --------------------------------------------------------------------------

  set(include_dirs
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${TIGSMODULELIB_INCLUDE_DIRECTORIES}
    )

  include_directories(${include_dirs})
  #message(warning ${include_dirs})

  #-----------------------------------------------------------------------------
  # Update TIGS_Base_INCLUDE_DIRS
  #-----------------------------------------------------------------------------
  set(TIGS_MODULE_INCLUDE_DIRS ${TIGS_MODULE_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    CACHE INTERNAL "TIGS Module includes" FORCE)

  # #-----------------------------------------------------------------------------
  # # Configure
  # # --------------------------------------------------------------------------
  # set(MY_LIBRARY_EXPORT_DIRECTIVE ${TIGSMODULELIB_EXPORT_DIRECTIVE})
  # set(MY_EXPORT_HEADER_PREFIX ${TIGSMODULELIB_NAME})
  # #set(MY_EXPORT_HEADER_PREFIX "TIGSModule")
  # set(MY_LIBNAME ${lib_name})
  
  # message(status "module")
  # message(status ${MY_EXPORT_HEADER_PREFIX})

  # configure_file(
    # ${TIGS_SOURCE_DIR}/CMake/qTIGSExport.h.in
    # ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    # )
  # set(dynamicHeaders
    # "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")

  #-----------------------------------------------------------------------------
  # Sources
  # --------------------------------------------------------------------------
  QT4_WRAP_CPP(TIGSQTBASELIB_MOC_OUTPUT ${TIGSMODULELIB_MOC_SRCS})
  QT4_WRAP_UI(TIGSMODULELIB_UI_CXX ${TIGSMODULELIB_UI_SRCS})
  if(DEFINED TIGSMODULELIB_RESOURCES)
    QT4_ADD_RESOURCES(TIGSMODULELIB_QRC_SRCS ${TIGSMODULELIB_RESOURCES})
  endif(DEFINED TIGSMODULELIB_RESOURCES)

  QT4_ADD_RESOURCES(TIGSMODULELIB_QRC_SRCS ${TIGS_SOURCE_DIR}/Resources/qTIGS.qrc)

  set_source_files_properties(
    ${TIGSMODULELIB_UI_CXX}
    ${TIGSMODULELIB_MOC_OUTPUT}
    ${TIGSMODULELIB_QRC_SRCS}
    WRAP_EXCLUDE
    )

  # --------------------------------------------------------------------------
  # Source groups
  # --------------------------------------------------------------------------
  source_group("Resources" FILES
    ${TIGSMODULELIB_UI_SRCS}
    ${TIGS_SOURCE_DIR}/Resources/qTIGS.qrc
    ${TIGSMODULELIB_RESOURCES}
  )

  source_group("Generated" FILES
    ${TIGSMODULELIB_UI_CXX}
    ${TIGSMODULELIB_MOC_OUTPUT}
    ${TIGSMODULELIB_QRC_SRCS}
    ${dynamicHeaders}
  )

  # --------------------------------------------------------------------------
  # Build the library
  # --------------------------------------------------------------------------
  add_library(${lib_name}
    ${TIGSMODULELIB_SRCS}
    ${TIGSMODULELIB_MOC_OUTPUT}
    ${TIGSMODULELIB_UI_CXX}
    ${TIGSMODULELIB_QRC_SRCS}
    ${QM_OUTPUT_FILES}
    )
  set_target_properties(${lib_name} PROPERTIES LABELS ${lib_name})

  # Apply user-defined properties to the library target.
  if(TIGS_LIBRARY_PROPERTIES)
    set_target_properties(${lib_name} PROPERTIES ${TIGS_LIBRARY_PROPERTIES})
  endif()

  target_link_libraries(${lib_name}
    ${TIGSMODULELIB_TARGET_LIBRARIES}
    )

  # Folder
  set_target_properties(${lib_name} PROPERTIES FOLDER "Module")

  #-----------------------------------------------------------------------------
  # Install library
  #-----------------------------------------------------------------------------
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION ${TIGS_INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
    LIBRARY DESTINATION ${TIGS_INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION ${TIGS_INSTALL_LIB_DIR} COMPONENT Development
  )

  # --------------------------------------------------------------------------
  # Install headers
  # --------------------------------------------------------------------------
  if(NOT TIGS_INSTALL_NO_DEVELOPMENT)
    # Install headers
    file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
    install(FILES
      ${headers}
      ${dynamicHeaders}
      DESTINATION ${TIGS_INSTALL_INCLUDE_DIR}/${PROJECT_NAME} COMPONENT Development
      )
  endif()

  # --------------------------------------------------------------------------
  # Export target
  # --------------------------------------------------------------------------
  set_property(GLOBAL APPEND PROPERTY TIGS_TARGETS ${TIGSMODULELIB_NAME})

endmacro()
