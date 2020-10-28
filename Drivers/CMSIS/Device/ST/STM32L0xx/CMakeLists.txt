project(stm32l0xx C ASM)

add_library(${PROJECT_NAME}
  Source/Templates/system_stm32l0xx.c
)

target_include_directories(${PROJECT_NAME}
  PUBLIC
    Include
)

target_link_libraries(${PROJECT_NAME}
  PUBLIC
    stm32l0xx-cmsis
)

get_directory_property(COMPILE_DEFINITIONS COMPILE_DEFINITIONS)
list(FIND COMPILE_DEFINITIONS USE_HAL_DRIVER USE_HAL_DRIVER_DEFINE_INDEX)

if (NOT USE_HAL_DRIVER_DEFINE_INDEX EQUAL -1)
  target_link_libraries(${PROJECT_NAME}
    PUBLIC
      stm32l0xx-hal
  )
endif()

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_sources(${PROJECT_NAME}
    PRIVATE
      Source/Templates/gcc/startup_${CMAKE_SYSTEM_PROCESSOR}.s
  )

  target_link_options(${PROJECT_NAME}
    PUBLIC
      $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:-Wl,-T,${CMAKE_CURRENT_LIST_DIR}/Source/Templates/gcc/linker/${CMAKE_SYSTEM_PROCESSOR}-mem.ld>
      $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:-Wl,-T,${CMAKE_CURRENT_LIST_DIR}/Source/Templates/gcc/linker/sections.ld>
  )
elseif()
  message(FATAL_ERROR "Unsupported C compiler: ${CMAKE_C_COMPILER_ID}")
endif()
