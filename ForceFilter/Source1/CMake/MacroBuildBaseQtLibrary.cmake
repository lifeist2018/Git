

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

macro(MacroBuildBaseQtLibrary)
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
  CMAKE_PARSE_ARGUMENTS(QTBASELIB
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  # --------------------------------------------------------------------------
  # Sanity checks
  # --------------------------------------------------------------------------
  if(QTBASELIB_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to TIGSMacroBuildBaseQtLibrary(): \"${TIGSQTBASELIB_UNPARSED_ARGUMENTS}\"")
  endif()

  set(expected_defined_vars NAME EXPORT_DIRECTIVE)
  foreach(var ${expected_defined_vars})
    if(NOT DEFINED QTBASELIB_${var})
      message(FATAL_ERROR "${var} is mandatory")
    endif()
  endforeach()

  # --------------------------------------------------------------------------
  # Define library name
  # --------------------------------------------------------------------------
  set(lib_name ${QTBASELIB_NAME})
  message(warning ${QTBASELIB_NAME})

  # --------------------------------------------------------------------------
  # Include dirs
  # --------------------------------------------------------------------------

  set(include_dirs
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${${Project_Name}_Base_INCLUDE_DIRS}
    ${${Project_Name}_Libs_INCLUDE_DIRS}
    ${QTBASELIB_INCLUDE_DIRECTORIES}
    )

  include_directories(${include_dirs})
 

  #-----------------------------------------------------------------------------
  # Update TIGS_Base_INCLUDE_DIRS
  #-----------------------------------------------------------------------------
  set(${ProjectName}_MODULE_INCLUDE_DIRS ${${ProjectName}_MODULE_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    CACHE INTERNAL "TIGS Base includes" FORCE)

  #-----------------------------------------------------------------------------
  # Configure
  # --------------------------------------------------------------------------
  set(MY_LIBRARY_EXPORT_DIRECTIVE ${QTBASELIB_EXPORT_DIRECTIVE})
  set(MY_EXPORT_HEADER_PREFIX "${ProjectName}${QTBASELIB_NAME}")
  set(MY_LIBNAME ${lib_name})
  
  message(warning ${MY_EXPORT_HEADER_PREFIX})
  configure_file(
    ${${ProjectName}_SOURCE_DIR}/CMake/qTIGSExport.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    )
  set(dynamicHeaders
    "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")

  #-----------------------------------------------------------------------------
  # Sources
  # --------------------------------------------------------------------------
  set(CMAKE_AUTOMOC ON)
  QT5_WRAP_UI(QTBASELIB_UI_CXX ${QTBASELIB_UI_SRCS})
  if(DEFINED QTBASELIB_RESOURCES)
    QT5_ADD_RESOURCES(QTBASELIB_QRC_SRCS ${QTBASELIB_RESOURCES})
  endif(DEFINED QTBASELIB_RESOURCES)

  #QT5_ADD_RESOURCES(QTBASELIB_QRC_SRCS ${TIGS_SOURCE_DIR}/Resources/qTIGS.qrc)

  set_source_files_properties(
    ${QTBASELIB_UI_CXX}
    ${QTBASELIB_MOC_OUTPUT}
    ${QTBASELIB_QRC_SRCS}
    WRAP_EXCLUDE
    )

  # --------------------------------------------------------------------------
  # Source groups
  # --------------------------------------------------------------------------
  source_group("Resources" FILES
    ${QTBASELIB_UI_SRCS}
    #${TIGS_SOURCE_DIR}/Resources/qTIGS.qrc
    ${QTBASELIB_RESOURCES}
  )

  source_group("Generated" FILES
    ${QTBASELIB_UI_CXX}
    ${QTBASELIB_MOC_OUTPUT}
    ${QTBASELIB_QRC_SRCS}
    ${dynamicHeaders}
  )

  # --------------------------------------------------------------------------
  # Build the library
  # --------------------------------------------------------------------------
  add_library(${lib_name}
    ${QTBASELIB_SRCS}
    ${QTBASELIB_MOC_OUTPUT}
    ${QTBASELIB_UI_CXX}
    ${QTBASELIB_QRC_SRCS}
    ${QM_OUTPUT_FILES}
    )
  set_target_properties(${lib_name} PROPERTIES LABELS ${lib_name})

  # Apply user-defined properties to the library target.
  if(${ProjectName}_LIBRARY_PROPERTIES)
    set_target_properties(${lib_name} PROPERTIES ${${ProjectName}_LIBRARY_PROPERTIES})
  endif()

  qt5_use_modules(${lib_name} Core Widgets Network)
  target_link_libraries(${lib_name}
    ${QTBASELIB_TARGET_LIBRARIES}
    )

  # Folder
  set_target_properties(${lib_name} PROPERTIES FOLDER "Module")

  #-----------------------------------------------------------------------------
  # Install library
  #-----------------------------------------------------------------------------
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION ${${ProjectName}_INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
    LIBRARY DESTINATION ${${ProjectName}_INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION ${${ProjectName}_INSTALL_LIB_DIR} COMPONENT Development
  )

  # --------------------------------------------------------------------------
  # Install headers
  # --------------------------------------------------------------------------
  if(NOT ${ProjectName}_INSTALL_NO_DEVELOPMENT)
    # Install headers
    file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
    install(FILES
      ${headers}
      ${dynamicHeaders}
      DESTINATION ${${ProjectName}_INSTALL_INCLUDE_DIR}/${ProjectName} COMPONENT Development
      )
  endif()

  # --------------------------------------------------------------------------
  # Export target
  # --------------------------------------------------------------------------
  set_property(GLOBAL APPEND PROPERTY ${ProjectName}_TARGETS ${QTBASELIB_NAME})

endmacro()
