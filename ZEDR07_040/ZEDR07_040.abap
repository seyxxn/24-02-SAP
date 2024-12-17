*&---------------------------------------------------------------------*
*& Report ZEDR07_040
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_040.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

GS_STUDENT-MANDT = SY-MANDT.
GS_STUDENT-ZCODE = 'SSU-21'.
GS_STUDENT-ZPERNR = '0000000021'.
GS_STUDENT-ZKNAME = '도레미'.
GS_STUDENT-ZENAME = 'DO'.
GS_STUDENT-ZGENDER = 'F'.
GS_STUDENT-ZTEL = '01000001111'.

INSERT INTO ZEDT07_001 VALUES GS_STUDENT.

IF SY-SUBRC = 0.
  WRITE :/ '성공'.
ELSE.
  WRITE :/ '실패'.
ENDIF.
