*&---------------------------------------------------------------------*
*& Report ZEDR07_087
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_087.

INCLUDE ZEDR07_087_TOP. "변수 선언
INCLUDE ZEDR07_087_SCR. "스크린
INCLUDE ZEDR07_087_F01. "함수
INCLUDE ZEDR07_087_PB0. "실행 전
INCLUDE ZEDR07_087_PAI. "실행 후

INITIALIZATION.
  PERFORM SET_INIT. "초기 세팅 -> F01에 넣기

START-OF-SELECTION.
  PERFORM GET_DATA. "DB에서 데이터 가져오기 -> F01에 넣기

CALL SCREEN 101.
