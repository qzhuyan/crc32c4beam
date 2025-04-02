cmake_minimum_required(VERSION 3.16)

project(crc32c4beam_nif)
set(SOURCES
  c_src/crc32c4beam_nif.c
)

SET(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
SET(Erlang_EI_INCLUDE_DIRS   ${Erlang_OTP_LIB_DIR}/${Erlang_EI_DIR}/include)
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/priv/)

SET(CRC32C_BUILD_BENCHMARKS, ON)
# For cerl picking up the OTP_ROOT
if (DEFINED ENV{Erlang_OTP_ROOT_DIR})
  SET(Erlang_OTP_ROOT_DIR $ENV{Erlang_OTP_ROOT_DIR})
else()
EXECUTE_PROCESS(
        COMMAND         erl -noshell -eval "io:format(\"~s\", [code:root_dir()])" -s erlang halt
        OUTPUT_VARIABLE Erlang_OTP_ROOT_DIR
        )
endif()

add_library(crc32c4beam_nif SHARED ${SOURCES})
target_include_directories(crc32c4beam_nif PRIVATE ${Erlang_OTP_ROOT_DIR}/usr/include/ google/crc32c/include)

set(CMAKE_CXX_EXTENSIONS ON)
set_property(GLOBAL  PROPERTY CXX_STANDARD 11)

include_directories(${PROJECT_SOURCE_DIR}/google/crc32c)
add_subdirectory(${PROJECT_SOURCE_DIR}/google/crc32c)
target_link_libraries(crc32c4beam_nif PRIVATE crc32c)

include(GNUInstallDirs)
install(TARGETS crc32c4beam_nif LIBRARY DESTINATION ${PROJECT_SOURCE_DIR}/priv/)

set_target_properties(crc32c4beam_nif
    PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/priv/
)

set_target_properties(crc32c
    PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/priv/
)
