*&---------------------------------------------------------------------*
*& Report ZEDR07_075
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_075.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

DATA : GV_ZCODE LIKE ZEDT07_001-ZCODE.
DATA : GV_ZKNAME LIKE ZEDT07_001-ZKNAME.

PERFORM GET_DATA(ZEDR07_074) IF FOUND CHANGING GT_STUDENT.

LOOP AT GT_STUDENT INTO GS_STUDENT.
  WRITE :/ GS_STUDENT-ZCODE, GS_STUDENT-ZKNAME.
ENDLOOP.
