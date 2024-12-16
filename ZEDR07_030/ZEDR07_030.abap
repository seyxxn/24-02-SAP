*&---------------------------------------------------------------------*
*& Report ZEDR07_030
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_030.

DATA : GV_NUM TYPE I.
DATA : GV_CHECK TYPE C.
DATA : GV_TIMES TYPE I.

GV_NUM = 5.
GV_TIMES = 0.

WHILE GV_NUM = 5 AND GV_TIMES < GV_NUM.
  GV_CHECK = 'X'.
  WRITE :/ GV_TIMES.
  GV_TIMES = GV_TIMES + 1.
ENDWHILE.

IF GV_CHECK = 'X'.
  WRITE :/ '출력되었습니다.'.
ENDIF.
