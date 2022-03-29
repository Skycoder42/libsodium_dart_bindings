cmake_minimum_required(VERSION 3.19)
set(PROJECT_NAME "sodium_libs")
project(${PROJECT_NAME} LANGUAGES CXX)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

SET(LIBSODIUM_SIGNING_KEY "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3")

set(LIBSODIUM_ARCH "${CMAKE_VS_PLATFORM_NAME}")
set(LIBSODIUM_CONFIG "${CMAKE_BUILD_TYPE}")
set(LIBSODIUM_VS_VERSION "${CMAKE_VS_PLATFORM_TOOLSET}")

find_program(DART "dart")
if(DART)
  message(DEBUG "Found dart at: ${DART}")
else()
  message(FATAL_ERROR "Did not find dart in PATH!")
endif()
execute_process(COMMAND cmd /c "${DART}" run
                "${CMAKE_CURRENT_SOURCE_DIR}/../libsodium_version.dart"
                OUTPUT_VARIABLE LIBSODIUM_VERSION_JSON
                COMMAND_ERROR_IS_FATAL ANY
)
string(JSON LIBSODIUM_VERSION
       GET "${LIBSODIUM_VERSION_JSON}"
       ffi
)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "sodium_libs_plugin")

add_library(${PLUGIN_NAME} SHARED
  "sodium_libs_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/libsodium-${LIBSODIUM_VERSION}")
  find_program(MINISIGN "minisign")
  if(NOT MINISIGN)
    message(FATAL_ERROR "Did not find minisign in PATH. Please install it. See sodium_libs README")
  endif()

  file(DOWNLOAD
       "https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VERSION}-stable-msvc.zip"
       "${CMAKE_CURRENT_BINARY_DIR}/libsodium-${LIBSODIUM_VERSION}.zip"
       SHOW_PROGRESS
  )
  file(DOWNLOAD
      "https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VERSION}-stable-msvc.zip.minisig"
      "${CMAKE_CURRENT_BINARY_DIR}/libsodium-${LIBSODIUM_VERSION}.zip.minisig"
      SHOW_PROGRESS
  )

  execute_process(COMMAND "${MINISIGN}" -V
                  -P "${LIBSODIUM_SIGNING_KEY}"
                  -m "libsodium-${LIBSODIUM_VERSION}.zip"
                  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
                  COMMAND_ERROR_IS_FATAL ANY
  )

  file(ARCHIVE_EXTRACT
       INPUT "${CMAKE_CURRENT_BINARY_DIR}/libsodium-${LIBSODIUM_VERSION}.zip"
       VERBOSE
  )
  file(RENAME
       "${CMAKE_CURRENT_BINARY_DIR}/libsodium"
       "${CMAKE_CURRENT_BINARY_DIR}/libsodium-${LIBSODIUM_VERSION}"
  )
endif()

# List of absolute paths to libraries that should be bundled with the plugin
set(sodium_libs_bundled_libraries
  "${CMAKE_CURRENT_BINARY_DIR}/libsodium-${LIBSODIUM_VERSION}/${LIBSODIUM_ARCH}/${LIBSODIUM_CONFIG}/${LIBSODIUM_VS_VERSION}/dynamic/libsodium.dll"
  PARENT_SCOPE
)
