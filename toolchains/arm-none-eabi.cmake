include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Generic)

set(compiler_triple "arm-none-eabi")
set(CMAKE_C_COMPILER ${compiler_triple}-gcc)
set(CMAKE_CXX_COMPILER ${compiler_triple}-g++)
set(CMAKE_SIZE ${compiler_triple}-size)
set(CMAKE_OBJDUMP ${compiler_triple}-objdump)

set(CMAKE_C_COMPILER_WORKS True)
set(CMAKE_CXX_COMPILER_WORKS True)

execute_process(
  COMMAND bash -c "echo '' | `${CMAKE_CXX_COMPILER} -print-prog-name=cc1plus` -v"
  ERROR_VARIABLE CXX_COMPILER_OUTPUT
)
string(REGEX REPLACE "(\r)?\n(\r)?( )*" ";" CXX_COMPILER_OUTPUT ${CXX_COMPILER_OUTPUT})
list(FIND CXX_COMPILER_OUTPUT "#include <...> search starts here:" CXX_INCLUDE_DIRS_BEGIN_INDEX)
if(CXX_INCLUDE_DIRS_BEGIN_INDEX EQUAL -1)
  message(FATAL_ERROR "Couldn't get CXX include directories (didn't find start marker)")
endif()
math(EXPR CXX_INCLUDE_DIRS_BEGIN_INDEX "${CXX_INCLUDE_DIRS_BEGIN_INDEX}+1")
list(FIND CXX_COMPILER_OUTPUT "End of search list." CXX_INCLUDE_DIRS_END_INDEX)
if(CXX_INCLUDE_DIRS_END_INDEX EQUAL -1)
  message(FATAL_ERROR "Couldn't get CXX include directories (didn't find end marker)")
endif()
math(EXPR CXX_INCLUDE_DIRS_LENGTH "${CXX_INCLUDE_DIRS_END_INDEX}-${CXX_INCLUDE_DIRS_BEGIN_INDEX}")
list(SUBLIST CXX_COMPILER_OUTPUT ${CXX_INCLUDE_DIRS_BEGIN_INDEX} ${CXX_INCLUDE_DIRS_LENGTH} CXX_INCLUDE_DIRS)

include_directories("$<$<COMPILE_LANGUAGE:CXX>:${CXX_INCLUDE_DIRS}>")

set(COMMON_FLAGS
  -mcpu=cortex-m0
  -mthumb
  -fsigned-char
  -ffunction-sections
  -fdata-sections
  -ffreestanding
  -fno-move-loop-invariants
  -Wpedantic
  -Wall
  -Werror
)

add_compile_options(
  ${COMMON_FLAGS}
  -Os
  # -save-temps=obj
  # -fverbose-asm
  $<$<COMPILE_LANGUAGE:CXX>:-fabi-version=0>
  $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>
  $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
  $<$<COMPILE_LANGUAGE:CXX>:-fno-use-cxa-atexit>
  $<$<COMPILE_LANGUAGE:CXX>:-fno-threadsafe-statics>
)

add_link_options(
  ${COMMON_FLAGS}
  $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:-nostartfiles>
  $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:-Wl,--gc-sections>
  $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:-Wl,-Map,$<TARGET_FILE_BASE_NAME:$<TARGET_PROPERTY:NAME>>.map>
  $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:--specs=nano.specs>
)

function(add_executable executable_name)
  _add_executable(${executable_name} ${ARGN})
  set_target_properties(${executable_name} PROPERTIES SUFFIX ".elf")
  set(TARGET_FILE $<TARGET_FILE:${executable_name}>)
  set(TARGET_FILE_BASE_NAME $<TARGET_FILE_BASE_NAME:${executable_name}>)
  add_custom_command(
    TARGET ${executable_name}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${TARGET_FILE} ${TARGET_FILE_BASE_NAME}.hex
    COMMENT "Creating hex file for target: ${executable_name}"
  )
  add_custom_command(
    TARGET ${executable_name}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET_FILE} ${TARGET_FILE_BASE_NAME}.bin
    COMMENT "Creating bin file for target: ${executable_name}"
  )
  add_custom_command(
    TARGET ${executable_name}
    POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -S --disassemble ${TARGET_FILE} > ${TARGET_FILE_BASE_NAME}.s
    COMMENT "Creating disassembly for target: ${executable_name}"
  )
  add_custom_command(
    TARGET ${executable_name}
    POST_BUILD
    COMMAND ${CMAKE_SIZE} --format=berkeley ${TARGET_FILE}
  )
endfunction()
