*&---------------------------------------------------------------------*
*& Report ZEDR07_038
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_038.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

GS_STUDENT-ZCODE = 'SSU-14'.
GS_STUDENT-ZPERNR = '0000000014'.

DELETE ZEDT07_001 FROM GS_STUDENT.

IF SY-SUBRC = 0.
  WRITE :/ '데이터삭제 성공'.
ENDIF.
