*&---------------------------------------------------------------------*
*&  Include           ZEDR07_088_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
   SELECT-OPTIONS : S_ZCODE FOR ZEDT07_001-ZCODE.
   PARAMETERS : P_ZGEN LIKE ZEDT07_001-ZGENDER MODIF ID SC1 DEFAULT 'F'.
SELECTION-SCREEN END OF BLOCK B1.
