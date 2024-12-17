*&---------------------------------------------------------------------*
*& Report ZEDR07_076
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_076.

DATA : BEGIN OF GS_STUDENT.
  INCLUDE TYPE ZEDT07_001.
  DATA : END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

DATA : GV_PNAME(20) VALUE 'ZEDR07_074'.
DATA : GV_FORMNAME(20) VALUE 'GET_DATA'.

TRANSLATE GV_PNAME TO UPPER CASE.
TRANSLATE GV_FORMNAME TO UPPER CASE.
"동적 구문을 사용할 때는 프로그램 이름과 서브루틴 이름을 반드시 대문자로 지정

PERFORM (GV_FORMNAME) IN PROGRAM (GV_PNAME) IF FOUND CHANGING GT_STUDENT.

LOOP AT GT_STUDENT INTO GS_STUDENT.
  WRITE :/ GS_STUDENT-ZCODE, GS_STUDENT-ZKNAME.
ENDLOOP.
