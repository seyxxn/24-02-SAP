*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_PO_CLS
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

ENDCLASS.

CLASS EVENT IMPLEMENTATION.

      METHOD HANDLER_DATA_CHANGED.
        PERFORM ALV_HANDLER_DATA_CHANGED USING ER_DATA_CHANGED
                                              E_ONF4
                                              E_ONF4_BEFORE
                                              E_ONF4_AFTER
                                              E_UCOMM.
     ENDMETHOD.

ENDCLASS.
