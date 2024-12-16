*&---------------------------------------------------------------------*
*& Report ZEDR07_PRACTICE004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_PRACTICE004 MESSAGE-ID ZMED07.

RANGES GR_YEAR FOR BKPF-GJAHR. "연도 필드

RANGES GR_MONTH FOR BKPF-MONAT. "월 필드
GR_MONTH-LOW = 1.
GR_MONTH-HIGH = 12.
APPEND GR_MONTH.

PARAMETERS : P_ZYEAR TYPE BKPF-GJAHR DEFAULT 2024.
PARAMETERS : P_ZMONTH TYPE BKPF-MONAT DEFAULT 10.

DATA : GV_IYEAR TYPE BKPF-GJAHR,
       GV_IMONTH TYPE BKPF-MONAT.
DATA : GV_EYEAR TYPE BKPF-GJAHR,
      GV_EMONTH TYPE BKPF-MONAT,
      GV_EDAY TYPE I,
      GV_EMESSAGE TYPE C LENGTH 20.
DATA : GV_DATE TYPE DATS.

GV_IYEAR = P_ZYEAR.
GV_IMONTH = P_ZMONTH.

CALL FUNCTION 'ZED07_DATE'
 EXPORTING
   I_YEAR          = GV_IYEAR
   I_MONTH         = GV_IMONTH
 IMPORTING
   E_YEAR          = GV_EYEAR
   E_MONTH         = GV_EMONTH
   E_DAY           = GV_EDAY
   E_MESSAGE       = GV_EMESSAGE
   .


IF SY-SUBRC = 0.
  GV_DATE = |{ GV_EYEAR }{ GV_EMONTH }{ GV_EDAY }|.

  WRITE: / GV_IYEAR, '년 ', GV_IMONTH, '월의 마지막 일은 ', GV_DATE ,  '입니다.'.
ENDIF.
