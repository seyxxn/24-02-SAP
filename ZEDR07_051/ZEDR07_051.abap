*&---------------------------------------------------------------------*
*& Report ZEDR07_051
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_051.

DATA : BEGIN OF GS_SCARR,
  CARRID LIKE SCARR-CARRID,
  CARRNAME LIKE SCARR-CARRNAME,
  END OF GS_SCARR.
DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

SELECT SINGLE CARRID CARRNAME INTO ( GS_SCARR-CARRID , GS_SCARR-CARRNAME )
  FROM SCARR
  WHERE CARRID = 'AA'.

 WRITE :/ GS_SCARR-CARRID, GS_SCARR-CARRNAME.
