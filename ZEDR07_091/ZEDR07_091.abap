*&---------------------------------------------------------------------*
*& Report ZEDR07_091
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_091.

INCLUDE ZEDR07_091_CLS. "CLASS 관련 INCLUDE - TOP 위에 선언
INCLUDE ZEDR07_091_TOP.
INCLUDE ZEDR07_091_SCR.
INCLUDE ZEDR07_091_F01.
INCLUDE ZEDR07_091_PBO.
INCLUDE ZEDR07_091_PAI.

INITIALIZATION.
  PERFORM SET_INIT.

START-OF-SELECTION.
  PERFORM GET_DATA.

CALL SCREEN 104.
