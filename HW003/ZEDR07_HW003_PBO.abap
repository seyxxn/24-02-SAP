*&---------------------------------------------------------------------*
*&  Include           ZEDR07_HW003_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ALV OUTPUT.
    IF GC_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT. "객체 생성
    PERFORM FIELD_CATALOG.
    PERFORM ALV_LAYOUT.
    PERFORM ALV_SORT.
    IF P_R1 = C_X.
      PERFORM CLASS_EVENT. "여기에 두는게 맞나
      PERFORM ALV_DISPLAY USING GT_ORDER_ALV.
    ELSEIF P_R2 = C_X.
      PERFORM ALV_DISPLAY USING GT_DELIVERY_ALV.
    ENDIF.
  ELSE.
    PERFORM REFRESH.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'T200'.
ENDMODULE.
