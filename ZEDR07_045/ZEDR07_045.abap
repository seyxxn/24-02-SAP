*&---------------------------------------------------------------------*
*& Report ZEDR07_045
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_045.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

UPDATE ZEDT07_001 SET ZENAME = 'DONG' WHERE ZCODE = 'SSU-01'.

IF SY-SUBRC = 0.
  WRITE :/ '데이터변경 성공'.
ENDIF.
