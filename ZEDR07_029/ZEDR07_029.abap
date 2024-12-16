*&---------------------------------------------------------------------*
*& Report ZEDR07_029
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_029.

DATA : LV_NUM TYPE I.
DATA : LV_SUM TYPE I.

LV_NUM = 5.

DO LV_NUM TIMES.
  ADD SY-INDEX TO LV_SUM.
  WRITE :/ SY-INDEX.
ENDDO.

WRITE :/ 'INDEX합계: ', LV_SUM.

LV_SUM = 0.

DO LV_NUM TIMES.
  IF SY-INDEX = '3'.
    EXIT. "EXIT를 만난 순간 반복문을 나감
  ENDIF.

  ADD SY-INDEX TO LV_SUM.
  WRITE :/ SY-INDEX.
ENDDO.

WRITE :/ 'INDEX합계: ', LV_SUM.

LV_SUM = 0.

DO LV_NUM TIMES.
  IF SY-INDEX = '3'.
    CONTINUE. "CONTINUE를 만나면 그 순서의 반복문만 빠져나감
  ENDIF.

  ADD SY-INDEX TO LV_SUM.
  WRITE :/ SY-INDEX.
ENDDO.

WRITE :/ 'INDEX합계: ', LV_SUM.

LV_SUM = 0.

DO LV_NUM TIMES.
  CHECK SY-INDEX = '3'. "CHECK 뒤의 논리 연산자가 참일 경우에만 실행

  ADD SY-INDEX TO LV_SUM.
  WRITE :/ SY-INDEX.
ENDDO.

WRITE :/ 'INDEX합계: ', LV_SUM.

LV_SUM = 0.


DO LV_NUM TIMES.
  IF SY-INDEX = '3'.
    STOP. "STOP을 만난 순간 프로그램이 종료됨
  ENDIF.

  ADD SY-INDEX TO LV_SUM.
  WRITE :/ SY-INDEX.
ENDDO.

WRITE :/ 'INDEX합계: ', LV_SUM.
