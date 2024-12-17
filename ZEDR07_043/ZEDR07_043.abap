*&---------------------------------------------------------------------*
*& Report ZEDR07_043
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_043.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

GS_STUDENT-ZCODE = 'SSU-22'.
GS_STUDENT-ZPERNR = '0000000022'.
GS_STUDENT-ZKNAME = '가나다'.
GS_STUDENT-ZENAME = 'GANADA'.
GS_STUDENT-ZGENDER = 'F'.
GS_STUDENT-ZTEL = '01000002222'.

UPDATE ZEDT07_001 FROM GS_STUDENT.

IF SY-SUBRC = 0.
  WRITE :/ '데이터변경 성공'.
ENDIF.
