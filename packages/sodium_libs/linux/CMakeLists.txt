cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "sodium_libs")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "sodium_libs_plugin")

find_package(PkgConfig)
pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)

add_library(${PLUGIN_NAME} SHARED
  "sodium_libs_plugin.cc"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::SODIUM)

# List of absolute paths to libraries that should be bundled with the plugin
set(sodium_libs_bundled_libraries
  ""
  PARENT_SCOPE
)
