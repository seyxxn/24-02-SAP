*&---------------------------------------------------------------------*
*& Report ZEDR07_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_001.

DATA : BEGIN OF GS_STUDENT,
  ZCODE TYPE C LENGTH 10,
  ZKNAME TYPE C LENGTH 10,
  ZENAME TYPE C LENGTH 10,
  ZCLASS TYPE C,
END OF GS_STUDENT.

DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

GS_STUDENT-ZCODE = 'SSU-01'.
GS_STUDENT-ZKNAME = '강동원'.
GS_STUDENT-ZENAME = 'DONG'.

APPEND GS_STUDENT TO GT_STUDENT.

*BREAK-POINT.

CLEAR : GT_STUDENT.

BREAK-POINT.
