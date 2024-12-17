*&---------------------------------------------------------------------*
*& Report ZEDR07_056
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_056.

DATA : BEGIN OF GS_SCARR,
  ZCHECK TYPE C,
  CARRID LIKE SCARR-CARRID,
  CARRNAME LIKE SCARR-CARRNAME,
  END OF GS_SCARR.
DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

SELECT CARRID
       CARRNAME
  FROM SCARR
  INTO CORRESPONDING FIELDS OF TABLE GT_SCARR "각각의 동일 필드 명에 맞게 값이 할당됨
  WHERE CARRID LIKE 'A%'.


LOOP AT GT_SCARR INTO GS_SCARR.
  WRITE :/ GS_SCARR-CARRID, GS_SCARR-CARRNAME.
ENDLOOP.
