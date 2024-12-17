*&---------------------------------------------------------------------*
*& Report ZEDR07_080
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_080.

TABLES : ZEDT07_001.

DATA : GS_STUDENT TYPE ZEDT07_001.
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

*SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
*  SELECT-OPTIONS : S_ZCODE FOR ZEDT07_001-ZCODE.
*  PARAMETERS : P_ZPERNE LIKE ZEDT07_001-ZPERNR.
*  PARAMETERS : P_ZGEN LIKE ZEDT07_001-ZGENDER MODIF ID SC1.
*SELECTION-SCREEN END OF BLOCK B1.

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
  SELECT * FROM ZEDT07_001
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
    MODIFY GT_STUDENT FROM GS_STUDENT.
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
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'.
  GS_FIELDCAT-SELTEXT_M = '학생코드'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-SELTEXT_M = '출석번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-SELTEXT_M = '이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.


  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'CRDATE'.
  GS_FIELDCAT-SELTEXT_M = '생성일'.
  GS_FIELDCAT-EDIT_MASK = '____-__-__'. "데이터 포맷 변경
  APPEND GS_FIELDCAT TO GT_FIELDCAT.


ENDFORM.
