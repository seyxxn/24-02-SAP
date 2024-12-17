*&---------------------------------------------------------------------*
*& Report ZEDR07_079
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_079.

TABLES : ZEDT07_001.

DATA : GS_STUDENT TYPE ZEDT07_001.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_STRUCTURE_NAME = 'ZEDT07_001' "구조체가 필드 카탈로그 역할을 함
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
