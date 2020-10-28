include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi.cmake)

set(CMAKE_SYSTEM_PROCESSOR stm32l021xx)

if(CMAKE_VERSION VERSION_LESS "3.12")
  add_compile_options(
    -DSTM32L021xx
  )
else()
  add_compile_definitions(
    STM32L021xx
  )
endif()
