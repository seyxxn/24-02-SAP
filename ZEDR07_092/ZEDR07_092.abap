*&---------------------------------------------------------------------*
*& Report ZEDR07_090
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_092.

INCLUDE ZEDR07_092_CLS.
INCLUDE ZEDR07_092_TOP.
INCLUDE ZEDR07_092_SCR.
INCLUDE ZEDR07_092_F01.
INCLUDE ZEDR07_092_PBO.
INCLUDE ZEDR07_092_PAI.

INITIALIZATION.
  PERFORM SET_INIT.

START-OF-SELECTION.
  PERFORM GET_DATA.

CALL SCREEN 104.
