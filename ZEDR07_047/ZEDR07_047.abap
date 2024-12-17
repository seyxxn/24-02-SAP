*&---------------------------------------------------------------------*
*& Report ZEDR07_047
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_047.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

CLEAR : GS_STUDENT, GT_STUDENT.
GS_STUDENT-ZCODE = 'SSU-10'.
GS_STUDENT-ZPERNR = '0000000010'.
APPEND GS_STUDENT TO GT_STUDENT.

CLEAR : GS_STUDENT.
GS_STUDENT-ZCODE = 'SSU-13'.
GS_STUDENT-ZPERNR = '0000000013'.
APPEND GS_STUDENT TO GT_STUDENT.

DELETE ZEDT07_001 FROM TABLE GT_STUDENT.

IF SY-SUBRC = 0.
  WRITE :/ '데이터삭제 성공'.
ENDIF.
