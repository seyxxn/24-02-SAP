*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_IR_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'T200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ALV OUTPUT.
  IF GC_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM FIELD_CATALOG.
    PERFORM ALV_LAYOUT.
    PERFORM ALV_SORT.
    PERFORM CLASS_EVENT.
    IF P_R1 = C_X.
      PERFORM ALV_DISPLAY USING GT_ALV_DATA.
    ELSEIF P_R2 = C_X.
     PERFORM ALV_DISPLAY USING GT_RECEIVED_GOODS.
    ENDIF.
  ELSE.
    PERFORM REFRESH.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS 'STATUS_0300'.
  SET TITLEBAR 'T300'.
ENDMODULE.
