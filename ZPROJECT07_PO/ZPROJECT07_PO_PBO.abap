*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_PO_PBO
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
  IF GC_CUSTOM IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM FIELD_CATALOG.
    PERFORM ALV_LAYOUT.
    PERFORM CLASS_EVENT.
    PERFORM ALV_DISPLAY.
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
*&---------------------------------------------------------------------*
*&      Module  SET_ALV_SEARCH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ALV_SEARCH OUTPUT.
  IF GC_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT_SEARCH.
    PERFORM FIELD_CATALOG_SEARCH.
    PERFORM ALV_LAYOUT_SEARCH.
    PERFORM ALV_SORT_SEARCH.
    PERFORM ALV_DISPLAY_SEARCH.
  ELSE.
    PERFORM REFRESH.
  ENDIF.
ENDMODULE.
