*&---------------------------------------------------------------------*
*&  Include           ZEDR07_HW003_CLS
*&---------------------------------------------------------------------*

"클래스 정의부 생성
CLASS EVENT DEFINITION.
  PUBLIC SECTION.

  METHODS HANDLER_USER_COMMAND FOR EVENT USER_COMMAND
                               OF CL_GUI_ALV_GRID
                               IMPORTING E_UCOMM.


ENDCLASS.

"클래스 실행부 생성
CLASS EVENT IMPLEMENTATION.
  METHOD HANDLER_USER_COMMAND.
    PERFORM ALV_HANDLER_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.

ENDCLASS.
