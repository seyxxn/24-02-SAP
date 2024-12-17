*&---------------------------------------------------------------------*
*& Report ZEDR07_058
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_058.

RANGES GR_SCARR FOR SCARR-CARRID. "RANGES 변수 선언

DATA : BEGIN OF GS_SCARR,
  ZCHECK TYPE C,
  CARRID LIKE SCARR-CARRID,
  CARRNAME LIKE SCARR-CARRNAME,
  END OF GS_SCARR.
DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

GR_SCARR-SIGN = 'I'.
GR_SCARR-OPTION = 'EQ'.
GR_SCARR-LOW = 'AA'.
GR_SCARR-HIGH = 'QF'.
APPEND GR_SCARR.

*GR_SCARR-HIGH = 'QF'.
*APPEND GR_SCARR.

SELECT CARRID
       CARRNAME
  FROM SCARR
  INTO CORRESPONDING FIELDS OF TABLE GT_SCARR
  WHERE CARRID IN GR_SCARR.


LOOP AT GT_SCARR INTO GS_SCARR.
  WRITE :/ GS_SCARR-CARRID, GS_SCARR-CARRNAME.
ENDLOOP.
