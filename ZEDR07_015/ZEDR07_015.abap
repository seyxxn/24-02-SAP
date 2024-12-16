*&---------------------------------------------------------------------*
*& Report ZEDR07_015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_015.

DATA : BEGIN OF GS_STUDENT,
  ZPERNR LIKE ZEDT07_001-ZPERNR,
  ZCODE LIKE ZEDT07_001-ZCODE,
  ZKNAME LIKE ZEDT07_001-ZKNAME,
  ZENAME LIKE ZEDT07_001-ZENAME,
  ZGENDER LIKE ZEDT07_001-ZGENDER,
  ZGNAME TYPE C LENGTH 4,
  ZTEL LIKE ZEDT07_001-ZTEL,
  END OF GS_STUDENT.

DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

CLEAR : GS_STUDENT, GT_STUDENT.

GS_STUDENT-ZPERNR = '0000000001'.
GS_STUDENT-ZCODE = 'SSU-01'.
GS_STUDENT-ZKNAME = '강동원'.
GS_STUDENT-ZENAME = 'DONG'.
GS_STUDENT-ZGENDER = 'F'. "잘못입력한 정보
GS_STUDENT-ZTEL = '01011112222'.
APPEND GS_STUDENT TO GT_STUDENT.

*BREAK-POINT.

GS_STUDENT-ZGENDER = 'M'.
APPEND GS_STUDENT TO GT_STUDENT.
*이렇게 하면 변경이 되는게 아니고, 한줄이 추가됨
*구조체만 내의 ZGENDER만 값이 변경되고, 결정적으로 테이블의 값은 변경되지 않고 새로 추가만 되는 것

BREAK-POINT.

CLEAR : GS_STUDENT.
