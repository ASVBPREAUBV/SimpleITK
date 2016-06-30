
#
# Project setup
#

if (NOT CMAKE_PROJECT_NAME STREQUAL "SimpleITK" )

  set( SimpleITK_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." )
  list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

  find_package(SimpleITK REQUIRED)
  include(${SimpleITK_USE_FILE})

  # Add compiler flags needed to use SimpleITK.
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SimpleITK_REQUIRED_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SimpleITK_REQUIRED_CXX_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${SimpleITK_REQUIRED_LINK_FLAGS}")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${SimpleITK_REQUIRED_LINK_FLAGS}")
  set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${SimpleITK_REQUIRED_LINK_FLAGS}")

endif()


# Setup build locations to the wrapping language sub directories
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY OR CMAKE_PROJECT_NAME STREQUAL "SimpleITK" )
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY OR CMAKE_PROJECT_NAME STREQUAL "SimpleITK" )
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif()
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY OR CMAKE_PROJECT_NAME STREQUAL "SimpleITK" )
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif()

if(NOT TARGET dist)
  add_custom_target( dist cmake -E echo "Finished generating wrapped packages for distribution..." )
endif()

# TODO these should be moved into UseSimpleITK
if(NOT SimpleITK_DOC_FILES)
  set ( SimpleITK_DOC_FILES
    "${SimpleITK_SOURCE_SOURCE_DIR}/LICENSE"
    "${SimpleITK_SOURCE_SOURCE_DIR}/NOTICE"
    "${SimpleITK_SOURCE_SOURCE_DIR}/Readme.md"
  )
endif()

#
# General SWIG configuration
#

find_package ( SWIG 2 REQUIRED )

include (sitkUseSWIG)

set(SIMPLEITK_WRAPPING_COMMON_DIR
  ${SimpleITK_SOURCE_DIR}/Wrapping/Common)

if ( CMAKE_PROJECT_NAME STREQUAL "SimpleITK" )
  file(GLOB SWIG_EXTRA_DEPS
    "${SimpleITK_SOURCE_DIR}/Code/Common/include/*.h"
    "${SimpleITK_SOURCE_DIR}/Code/Registration/include/*.h"
    "${SimpleITK_SOURCE_DIR}/Code/IO/include/*.h")
  list( APPEND SWIG_EXTRA_DEPS
    "${SimpleITK_BINARY_DIR}/Code/BasicFilters/include/SimpleITKBasicFiltersGeneratedHeaders.h"
    ${SimpleITKBasicFiltersGeneratedHeader} )
else()
  find_file( _file
    NAMES SimpleITKBasicFiltersGeneratedHeaders.h
    PATHS ${SimpleITK_INCLUDE_DIRS}
    NO_DEFAULT_PATH )
  list( APPEND SWIG_EXTRA_DEPS ${_file} )
endif()

# make a manual list of dependencies for the Swig.i files
list( APPEND SWIG_EXTRA_DEPS
  "${SIMPLEITK_WRAPPING_COMMON_DIR}/SimpleITK_Common.i"
  )

# check if uint64_t is the same as unsigned long
try_compile(SITK_ULONG_SAME_AS_UINT64
  ${PROJECT_BINARY_DIR}/CMakeTmp
  ${SimpleITK_SOURCE_DIR}/CMake/same_uint64_ulong.cxx )

# when "-DSWIGWORDSIZE64" is defined SWIG used unsigned long for uint64_t types
if(${SITK_ULONG_SAME_AS_UINT64} )
  set ( CMAKE_SWIG_GLOBAL_FLAGS "-DSWIGWORDSIZE64" )
endif()

set ( CMAKE_SWIG_GLOBAL_FLAGS -I${SIMPLEITK_WRAPPING_COMMON_DIR} ${CMAKE_SWIG_GLOBAL_FLAGS} )

include(sitkTargetLinkLibrariesWithDynamicLookup)
include(sitkStripOption)
include(sitkForbidDownloadsOption)
