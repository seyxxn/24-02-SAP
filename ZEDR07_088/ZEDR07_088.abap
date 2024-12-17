*&---------------------------------------------------------------------*
*& Report ZEDR07_088
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_088.

INCLUDE ZEDR07_088_TOP. "변수선언
INCLUDE ZEDR07_088_SCR. "스크린 관련
INCLUDE ZEDR07_088_F01. "함수 관련
INCLUDE ZEDR07_088_PBO. "스크린 실행 전
INCLUDE ZEDR07_088_PAI. "사용자 입력 후

INITIALIZATION.
  PERFORM SET_INIT. "초기 세팅

START-OF-SELECTION.
  PERFORM GET_DATA. "DB에서 데이터 가져오기

IF GT_STUDENT[] IS NOT INITIAL.
  CALL SCREEN 102.
ELSE.
  EXIT.
ENDIF.
