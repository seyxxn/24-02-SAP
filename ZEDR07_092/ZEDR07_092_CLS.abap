*&---------------------------------------------------------------------*
*&  Include           ZEDR07_092_CLS
*&---------------------------------------------------------------------*

"클래스 정의부 생성
CLASS EVENT DEFINITION.
  PUBLIC SECTION.

  "EVENT 클래스 내에 HANDLER_USER_COMMAND 라는 메서드 생성
  METHODS HANDLER_USER_COMMAND FOR EVENT USER_COMMAND
                               OF CL_GUI_ALV_GRID
                               IMPORTING E_UCOMM.

  METHODS HANDLER_DATA_CHANGED FOR EVENT DATA_CHANGED
                                OF CL_GUI_ALV_GRID
                                IMPORTING ER_DATA_CHANGED
                                          E_ONF4
                                          E_ONF4_BEFORE
                                          E_ONF4_AFTER
                                          E_UCOMM.

  METHODS HANDLER_DATA_CHANGED_FINISHED FOR EVENT DATA_CHANGED_FINISHED
                                  OF CL_GUI_ALV_GRID
                                IMPORTING E_MODIFIED
                                          ET_GOOD_CELLS.

ENDCLASS.

"클래스 실행부 생성
CLASS EVENT IMPLEMENTATION.
  METHOD HANDLER_USER_COMMAND.
    PERFORM ALV_HANDLER_USER_COMMAND USING E_UCOMM.

  ENDMETHOD.

  METHOD HANDLER_DATA_CHANGED.
    PERFORM ALV_HANDLER_DATA_CHANGED USING ER_DATA_CHANGED
                                          E_ONF4
                                          E_ONF4_BEFORE
                                          E_ONF4_AFTER
                                          E_UCOMM.
  ENDMETHOD.


  METHOD HANDLER_DATA_CHANGED_FINISHED.
    PERFORM ALV_DATA_CHANGED_FINISHED USING E_MODIFIED
                                            ET_GOOD_CELLS.
  ENDMETHOD.

ENDCLASS.
