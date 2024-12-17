*&---------------------------------------------------------------------*
*& Report ZEDR07_081
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_081.


TABLES : ZEDT07_002.

DATA : GS_STUDENT TYPE ZEDT07_002.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

"필드 카탈로그 인터널테이블과 구조체 선언
DATA : GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
DATA : GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

RANGES S_ZCODE FOR ZEDT07_001-ZCODE.

INITIALIZATION.
S_ZCODE-SIGN = 'I'.
S_ZCODE-OPTION = 'BT'.
S_ZCODE-LOW = 'SSU-01'.
S_ZCODE-HIGH = 'SSU-99'.
APPEND S_ZCODE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'SC1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.
END-OF-SELECTION.
  PERFORM ALV_DISPLAY.

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .
  PERFORM FIELD_CATALOG.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    IT_FIELDCAT = GT_FIELDCAT
  TABLES
    T_OUTTAB = GT_STUDENT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  SELECT * FROM ZEDT07_002
    INTO CORRESPONDING FIELDS OF TABLE GT_STUDENT
    WHERE ZCODE IN S_ZCODE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA .
  LOOP AT GT_STUDENT INTO GS_STUDENT.
    MODIFY GT_STUDENT FROM GS_STUDENT INDEX SY-TABIX.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1. "컬럼의 OUTPUT 순서
  GS_FIELDCAT-FIELDNAME = 'ZCODE'. "필드 카탈로그의 필드 이름(인터널 테이블의 필드 이름과 같아야함)
  GS_FIELDCAT-SELTEXT_M = '학생코드'. "출력될 필드 명
  GS_FIELDCAT-KEY = 'X'. "키값으로 지정
  GS_FIELDCAT-JUST = 'L'. "왼쪽 정렬
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-SELTEXT_M = '출석번호'.
  GS_FIELDCAT-KEY = 'X'. "키값으로 지정
  GS_FIELDCAT-JUST = 'C'. "중앙 정렬
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZMAJOR'.
  GS_FIELDCAT-SELTEXT_M = '전공'.
  GS_FIELDCAT-JUST = 'R'. "오른쪽 정렬
  GS_FIELDCAT-NO_OUT = 'X'. "필드 숨김
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZMNAME'.
  GS_FIELDCAT-SELTEXT_M = '전공명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZSUM'.
  GS_FIELDCAT-SELTEXT_M = '등록금액'.
  GS_FIELDCAT-CURRENCY = 'KRW'. " CURRENCY 단위를 지정하여 한화로 표기
  GS_FIELDCAT-JUST = 'R'. "오른쪽 정렬
  GS_FIELDCAT-DO_SUM = 'X'. "합계 표기
  GS_FIELDCAT-NO_ZERO = 'X'. "0값은 삭제(빈 데이터로 둠)
  GS_FIELDCAT-NO_SIGN = 'X'. "출력 부호 제거 (출력은 부호가 없으나, SUM 값 계산은 - 값대로 계산됨)
  GS_FIELDCAT-OUTPUTLEN = 20. "문자의 열 너비
  GS_FIELDCAT-EMPHASIZE = 'X'. "색상 강조
  GS_FIELDCAT-EDIT = 'X'. "편집 모드
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-SELTEXT_M = '통화'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.
