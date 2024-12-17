*&---------------------------------------------------------------------*
*&  Include           ZEDT01_HW003_CLS
*&---------------------------------------------------------------------*

CLASS EVENT DEFINITION.
  PUBLIC SECTION.
  METHODS HANDLER_TOOLBAR FOR EVENT TOOLBAR
                         OF CL_GUI_ALV_GRID
                         IMPORTING E_OBJECT E_INTERACTIVE.

  METHODS HANDLER_USER_COMMAND FOR EVENT USER_COMMAND
                               OF CL_GUI_ALV_GRID
                               IMPORTING E_UCOMM.



ENDCLASS.


CLASS EVENT IMPLEMENTATION.

  METHOD HANDLER_TOOLBAR.
    PERFORM HANDLER_TOOLBAR USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.

  METHOD HANDLER_USER_COMMAND.
    PERFORM HANDLER_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.

ENDCLASS.
