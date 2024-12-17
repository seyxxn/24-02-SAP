*&---------------------------------------------------------------------*
*& Report ZEDR07_090
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_090.

INCLUDE ZEDR07_090_CLS. "CLASS 관련 INCLUDE - TOP 위에 선언
INCLUDE ZEDR07_090_TOP.
INCLUDE ZEDR07_090_SCR.
INCLUDE ZEDR07_090_F01.
INCLUDE ZEDR07_090_PBO.
INCLUDE ZEDR07_090_PAI.

INITIALIZATION.
  PERFORM SET_INIT.

START-OF-SELECTION.
  PERFORM GET_DATA.

CALL SCREEN 104.
