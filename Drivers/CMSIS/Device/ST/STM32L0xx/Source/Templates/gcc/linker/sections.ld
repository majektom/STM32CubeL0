INPUT(crti.o crtn.o)

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* Minimal required heap size */
_Min_Heap_Size = 0x200;
/* Minimal required stack size */
_Min_Stack_Size = 0x400;

SECTIONS
{
  /* Interruption vector */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  /* Program code */
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    /* Glue arm to thumb code */
    *(.glue_7)
    /* Glue thumb to arm code */
    *(.glue_7t)
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;
  } >FLASH

  /* Read only data */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  .ARM.extab :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
  } >FLASH

  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH

  /* .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH */

  /* Initialized data in flash memory to be copied to RAM at startup */
  _sidata = LOADADDR(.data);

  /* Initialized data */
  .data : 
  {
    . = ALIGN(4);
    /* Initialized data begin */
    _sdata = .;
    *(.data)
    *(.data*)

    . = ALIGN(4);
    /* Initialized data end */
    _edata = .;
  } >RAM AT> FLASH

  /* Zero-initialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* Zero-initialized data begin */
    _sbss = .;
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    /* Zero-initialized data end */
    _ebss = .;
    __bss_end__ = _ebss;
  } >RAM

  /* User heap and stack */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
