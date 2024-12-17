*&---------------------------------------------------------------------*
*& Report ZEDR07_048
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_048.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

"새로운 키값을 넣음
GS_STUDENT-ZCODE = 'SSU-25'.
GS_STUDENT-ZPERNR = '0000000025'.
GS_STUDENT-ZKNAME = '윤아'.
GS_STUDENT-ZENAME = 'YOON'.
GS_STUDENT-ZGENDER = 'F'.
GS_STUDENT-ZTEL = '01000002222'.

MODIFY ZEDT07_001 FROM GS_STUDENT.

IF SY-SUBRC = 0.
  WRITE :/ '데이터변경 성공'.
ENDIF.
