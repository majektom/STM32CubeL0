project(stm32l0xx-cmsis)

add_library(${PROJECT_NAME} INTERFACE)

target_include_directories(${PROJECT_NAME}
  INTERFACE
    Include
)

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_link_directories(${PROJECT_NAME}
    INTERFACE
      Lib/GCC
  )

  target_link_libraries(${PROJECT_NAME}
    INTERFACE
      libarm_cortexM0l_math.a
  )
elseif()
  message(FATAL_ERROR "Unsupported C compiler: ${CMAKE_C_COMPILER_ID}")
endif()

add_subdirectory(Device/ST/STM32L0xx)
