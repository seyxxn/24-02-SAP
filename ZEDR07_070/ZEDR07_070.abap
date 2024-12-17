*&---------------------------------------------------------------------*
*& Report ZEDR07_070
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_070.

TABLES : ZEDT07_001.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  SELECT-OPTIONS : S_ZCODE FOR ZEDT07_001-ZCODE.
   PARAMETERS : P_ZGEN LIKE ZEDT07_001-ZGENDER.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  PARAMETERS : P_CH1 AS CHECKBOX DEFAULT 'X' MODIF ID M1. "그룹으로 묶기
  PARAMETERS : P_CH2 AS CHECKBOX MODIF ID M2.
SELECTION-SCREEN END OF BLOCK B2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M2'. "그룹 M2로 묶은 필드를 제어
*      SCREEN-INPUT = '0'. "0 입력시 비활성화(값을 변경할 수 없음), 1 입력시 활성화
*      SCREEN-ACTIVE = '0'. "0 입력시 비활성화(피드가 아예 보이지 않음), 1 입력시 활성화
*      SCREEN-REQUIRED = '0'. "1 : 스크린 내 필드 필수 입력, 0: 필수는 아님
      SCREEN-OUTPUT = '0'. "0 입력시 체크 박스는 보이는데 글씨가 안보임

*     IF SCREEN-NAME = 'P_CH2'. "NAME으로 지정할 수도 있음
*       SCREEN-INPUT = '0'.

      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
