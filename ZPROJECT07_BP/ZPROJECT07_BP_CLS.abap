*&---------------------------------------------------------------------*
*&  Include           ZEDR07_PROJECT001_CLS
*&---------------------------------------------------------------------*
CLASS EVENT DEFINITION.
    PUBLIC SECTION.

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

CLASS EVENT IMPLEMENTATION.

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
