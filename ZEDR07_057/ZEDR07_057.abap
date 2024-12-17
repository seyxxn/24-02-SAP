
*&---------------------------------------------------------------------*
*& Report ZEDR07_057
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_057.


DATA : BEGIN OF GS_SCARR,
  ZCHECK TYPE C,
  CARRID LIKE SCARR-CARRID,
  CARRNAME LIKE SCARR-CARRNAME,
  END OF GS_SCARR.
DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

SELECT CARRID
       CARRNAME
  FROM SCARR
  INTO CORRESPONDING FIELDS OF TABLE GT_SCARR
  WHERE CARRID IN ( 'AA' , 'AC' ).


LOOP AT GT_SCARR INTO GS_SCARR.
  WRITE :/ GS_SCARR-CARRID, GS_SCARR-CARRNAME.
ENDLOOP.
