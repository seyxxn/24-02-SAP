*&---------------------------------------------------------------------*
*& Report ZEDR07_086
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_086.

INCLUDE ZEDR07_086_TOP. "변수 선언
INCLUDE ZEDRO7_086_SCR. "스크린 관련
INCLUDE ZEDR07_086_F01. "FUNCTION
INCLUDE ZEDR07_086_PBO. "스크린 실행 전
INCLUDE ZEDR07_086_PAI. "실행 후

INITIALIZATION.
  PERFORM SET_INIT. "초기 세팅

START-OF-SELECTION.
 PERFORM GET_DATA.

CALL SCREEN 100.
