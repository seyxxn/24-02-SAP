*&---------------------------------------------------------------------*
*& Report ZEDR07_078
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_078 MESSAGE-ID ZMED07.

TABLES : ZEDT07_001.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  SELECT-OPTIONS : S_ZCODE FOR ZEDT07_001-ZCODE.
  PARAMETERS : P_ZPERNR LIKE ZEDT07_001-ZPERNR.
  PARAMETERS : P_ZGEN LIKE ZEDT07_001-ZGENDER.
SELECTION-SCREEN END OF BLOCK B1.

IF S_ZCODE IS INITIAL.
  MESSAGE I000.
ENDIF.

PERFORM GET_DATA.
IF GT_STUDENT IS INITIAL.
  MESSAGE I001.
  EXIT.
ENDIF.
PERFORM WRITE_DATA.

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
    WHERE ZCODE IN S_ZCODE
    AND ZGENDER = P_ZGEN.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_DATA .
  LOOP AT GT_STUDENT INTO GS_STUDENT.
    WRITE :/ GS_STUDENT-ZCODE, GS_STUDENT-ZKNAME.
  ENDLOOP.
ENDFORM.
