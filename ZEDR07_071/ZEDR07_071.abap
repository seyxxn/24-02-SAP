
*&---------------------------------------------------------------------*
*& Report ZEDR07_071
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_071.

TABLES : ZEDT07_001.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  SELECT-OPTIONS : S_ZCODE FOR ZEDT07_001-ZCODE.
  PARAMETERS : P_ZPERNR LIKE ZEDT07_001-ZPERNR MODIF ID M1.
  PARAMETERS : P_ZGEN LIKE ZEDT07_001-ZGENDER MODIF ID M2. "제어할 필드를 그룹으로 묶음
*  PARAMETERS : P_ZGEN LIKE ZEDT07_001-ZGENDER MATCHCODE OBJECT ZSH07_001 MODIF ID M2.
  "만약 SEARCH HELP가 등록되지 않는 필드를 참조했다면, MATCHCODE OBJECT 옵션을 통해 사용이 가능함

  "여기에서는 학부생, 대학원생에 따라 성별을 보이게하거나 안보이게 할 것임
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  PARAMETERS : P_R1 RADIOBUTTON GROUP R1 DEFAULT 'X' USER-COMMAND UC1. "이벤트를 적용하고 싶을 때 USER-COMMAND
  PARAMETERS : P_R2 RADIOBUTTON GROUP R1.
SELECTION-SCREEN END OF BLOCK B2.

"SELECTION-SCREEN을 제어하는 구문 입력
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M2'. "제어할 그룹
      IF P_R1 = 'X'. "라디오 버튼 1번이 선택된 경우
        SCREEN-ACTIVE = '1'. "1이므로 활성화 함
        SCREEN-INTENSIFIED = '1'. "글씨 강조(1일 경우 파란색)
        SCREEN-DISPLAY_3D = '1'. "필드의 입체를 제어
*        SCREEN-INVISIBLE = '1'. "암호 처럼 사용
      ELSEIF P_R2 = 'X'. "라디오 버튼 2번이 선택된 경우
        SCREEN-ACTIVE = '0'. "0이므로 비활성화 함 -> ACTIVE이므로 아예 안보임
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
