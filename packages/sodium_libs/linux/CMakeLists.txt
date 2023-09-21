# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "sodium_libs")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed.
set(PLUGIN_NAME "sodium_libs_plugin")

# add libsodium dependency
if(DEFINED ENV{LIBSODIUM_USE_PKGCONFIG})
  find_package(PkgConfig)
  pkg_check_modules(SODIUM REQUIRED IMPORTED_TARGET libsodium)
else()
  add_library(sodium SHARED IMPORTED)
  set_target_properties(sodium PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_SYSTEM_PROCESSOR}/libsodium.so")
  set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
  set(CMAKE_INSTALL_RPATH $ORIGIN)
endif()

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "sodium_libs_plugin.cc"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
if(DEFINED ENV{LIBETEBASE_USE_PKGCONFIG})
  target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::SODIUM)
else()
  target_link_libraries(${PLUGIN_NAME} PRIVATE sodium)
endif()

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
if(DEFINED ENV{LIBETEBASE_USE_PKGCONFIG})
  set(sodium_libs_bundled_libraries
    ""
    PARENT_SCOPE
  )
else()
  set(sodium_libs_bundled_libraries
    "${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_SYSTEM_PROCESSOR}/libsodium.so"
    PARENT_SCOPE
  )
endif()
