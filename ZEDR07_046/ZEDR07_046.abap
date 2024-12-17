*&---------------------------------------------------------------------*
*& Report ZEDR07_046
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_046.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

DELETE FROM ZEDT07_001 WHERE ZTEL = '01000001111'.

IF SY-SUBRC = 0.
  WRITE :/ '데이터삭제 성공'.
ENDIF.
