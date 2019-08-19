

set(APPNAME "${ProjectName}Filter")


PROJECT(${APPNAME})

#set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" )


INCLUDE_DIRECTORIES(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}
	${${ProjectName}_MODULE_INCLUDE_DIRS}
)

SET (${APPNAME}_HEADERS 
		AsySocketClient.h
		mainwindow.h
		main.h
		RobotController.h
		Filter.h
	)
SET (${APPNAME}_UIS Resource/UI/mainwindow.ui)

SET(${APPNAME}_SRCS 
		AsySocketClient.cpp
		mainwindow.cpp
		main.cpp
		RobotController.cpp
		Filter.cpp
	)

SET(CMAKE_AUTOMOC ON)
QT5_WRAP_UI(${APPNAME}_UISRCS ${${APPNAME}_UIS})


ADD_EXECUTABLE(${APPNAME} ${${APPNAME}_SRCS} ${${APPNAME}_UISRCS} )
QT5_USE_MODULES(${APPNAME} Core GUI Widgets Network)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${VTK_LIBRARIES})

add_custom_command(TARGET ${APPNAME}
  COMMAND ${CMAKE_COMMAND}
        -DMSVC_BUILD_CONFIG_DIR=${CMAKE_CFG_INTDIR}
        -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
		#-DOpenCV_DIR=${OpenCV_DIR}
		-DVTK_DIR=${VTK_DIR}
        -P "${${ProjectName}_CMAKE_DIR}/copydll.cmake"
  COMMENT "COPY..."
  VERBATIM
) 