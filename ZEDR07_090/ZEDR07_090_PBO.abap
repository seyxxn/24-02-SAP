*&---------------------------------------------------------------------*
*&  Include           ZEDR07_090_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0104  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0104 OUTPUT.
  SET PF-STATUS 'STATUS_0104'.
  SET TITLEBAR 'T104'.
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
    PERFORM CLASS_EVENT. "여기서 클래스 객체를 생성한다.
    PERFORM ALV_DISPLAY.
  ELSE.
    PERFORM REFRESH.
  ENDIF.
ENDMODULE.
