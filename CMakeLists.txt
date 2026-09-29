cmake_minimum_required(VERSION 3.16)
project(scs_telemetry_jaime LANGUAGES CXX)

set(SCS_SDK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/scs_sdk" CACHE PATH "SCS SDK 1.14 root (must contain include/)")

if(NOT EXISTS "${SCS_SDK_ROOT}/include/scssdk.h")
    message(FATAL_ERROR "No se encuentra SCS SDK 1.14 en: ${SCS_SDK_ROOT}")
endif()

set(PLUGIN_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scs_telemetry_jaime")
set(PLUGIN_SOURCES
    "${PLUGIN_SRC_DIR}/src/log.cpp"
    "${PLUGIN_SRC_DIR}/src/scs_gameplay_event_handlers.cpp"
    "${PLUGIN_SRC_DIR}/src/scs_telemetry.cpp"
    "${PLUGIN_SRC_DIR}/src/scs_config_handlers.cpp"
    "${PLUGIN_SRC_DIR}/src/sharedmemory.cpp"
)

add_library(scs_telemetry_jaime SHARED ${PLUGIN_SOURCES})

target_include_directories(scs_telemetry_jaime PRIVATE
    "${SCS_SDK_ROOT}/include"
    "${PLUGIN_SRC_DIR}/inc"
)

target_compile_definitions(scs_telemetry_jaime PRIVATE
    WIN32
    _WINDOWS
    _USRDLL
    TELEMETRY_EXPORTS
    TRUCKHUD_BUILT_WITH_SCS_SDK_1_14=1
)

if(MSVC)
    target_compile_options(scs_telemetry_jaime PRIVATE /W3)
    set_target_properties(scs_telemetry_jaime PROPERTIES
        MSVC_RUNTIME_LIBRARY "MultiThreadedDLL"
    )
    target_link_options(scs_telemetry_jaime PRIVATE
        "/DEF:${PLUGIN_SRC_DIR}/vs2012/scs_telemetry_jaime.def"
    )
endif()

set_target_properties(scs_telemetry_jaime PROPERTIES
    OUTPUT_NAME "scs_telemetry_jaime"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

install(TARGETS scs_telemetry_jaime RUNTIME DESTINATION ".")
