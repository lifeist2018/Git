

#
# BuildBaseQtLibraryMacro
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

macro(MacroBuildBaseLibLibrary)
  set(oneValueArgs
    NAME
    EXPORT_DIRECTIVE
    )
  set(multiValueArgs
    SRCS
    INCLUDE_DIRECTORIES
    TARGET_LIBRARIES
	)
  CMAKE_PARSE_ARGUMENTS(BASELIB
  "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  # --------------------------------------------------------------------------
  # Sanity checks
  # --------------------------------------------------------------------------
  if(BASELIB_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to TIGSMacroBuildBaseQtLibrary(): \"${TIGSQTBASELIB_UNPARSED_ARGUMENTS}\"")
  endif()

  set(expected_defined_vars NAME EXPORT_DIRECTIVE)
  foreach(var ${expected_defined_vars})
    if(NOT DEFINED BASELIB_${var})
      message(FATAL_ERROR "${var} is mandatory")
    endif()
  endforeach()

  # --------------------------------------------------------------------------
  # Define library name
  # --------------------------------------------------------------------------
  set(lib_name ${BASELIB_NAME})
  message(warning ${BASELIB_NAME})

  # --------------------------------------------------------------------------
  # Include dirs
  # --------------------------------------------------------------------------

  set(include_dirs
    ${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}
    ${${Project_Name}_Base_INCLUDE_DIRS}
    ${${Project_Name}_Libs_INCLUDE_DIRS}
    ${BASELIB_INCLUDE_DIRECTORIES}
    )

  include_directories(${include_dirs})
 

  #-----------------------------------------------------------------------------
  # Update ${Project_Name}_Base_INCLUDE_DIRS
  #-----------------------------------------------------------------------------
  set(${Project_Name}_MODULE_INCLUDE_DIRS ${${Project_Name}_MODULE_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}
    CACHE INTERNAL "${Project_Name} Base includes" FORCE)

  #-----------------------------------------------------------------------------
  # Configure
  # --------------------------------------------------------------------------
  set(MY_LIBRARY_EXPORT_DIRECTIVE ${BASELIB_EXPORT_DIRECTIVE})
  set(MY_EXPORT_HEADER_PREFIX "${Project_Name}${BASELIB_NAME}")
  set(MY_LIBNAME ${lib_name})
  
  message(warning ${MY_EXPORT_HEADER_PREFIX})
  configure_file(
    ${${Project_Name}_SOURCE_DIR}/CMake/q${Project_Name}Export.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    )
  set(dynamicHeaders
    "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")


  # --------------------------------------------------------------------------
  # Source groups
  # --------------------------------------------------------------------------


  # --------------------------------------------------------------------------
  # Build the library
  # --------------------------------------------------------------------------
  add_library(${lib_name}
    ${BASELIB_SRCS}
    )
  set_target_properties(${lib_name} PROPERTIES LABELS ${lib_name})

  # Apply user-defined properties to the library target.
  if(${Project_Name}_LIBRARY_PROPERTIES)
    set_target_properties(${lib_name} PROPERTIES ${${Project_Name}_LIBRARY_PROPERTIES})
  endif()

  target_link_libraries(${lib_name}
    ${BASELIB_TARGET_LIBRARIES}
    )
  message(warning ${BASELIB_TARGET_LIBRARIES})
  # Folder
  set_target_properties(${lib_name} PROPERTIES FOLDER "Module")

  #-----------------------------------------------------------------------------
  # Install library
  #-----------------------------------------------------------------------------
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION ${${Project_Name}_INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
    LIBRARY DESTINATION ${${Project_Name}_INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION ${${Project_Name}_INSTALL_LIB_DIR} COMPONENT Development
  )

  # --------------------------------------------------------------------------
  # Install headers
  # --------------------------------------------------------------------------
  if(NOT ${Project_Name}_INSTALL_NO_DEVELOPMENT)
    # Install headers
    file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
    install(FILES
      ${headers}
      ${dynamicHeaders}
      DESTINATION ${${Project_Name}_INSTALL_INCLUDE_DIR}/${Project_Name} COMPONENT Development
      )
  endif()

  # --------------------------------------------------------------------------
  # Export target
  # --------------------------------------------------------------------------
  set_property(GLOBAL APPEND PROPERTY ${Project_Name}_TARGETS ${BASELIB_NAME})

endmacro()
