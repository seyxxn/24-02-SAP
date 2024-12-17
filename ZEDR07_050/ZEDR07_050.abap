*&---------------------------------------------------------------------*
*& Report ZEDR07_050
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_050.

DATA : BEGIN OF GS_SCARR,
  CARRID LIKE SCARR-CARRID,
  CARRNAME LIKE SCARR-CARRNAME,
  END OF GS_SCARR.
DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

SELECT CARRID CARRNAME INTO GS_SCARR
  FROM SCARR
  WHERE CARRID = 'AA'.

  WRITE :/ GS_SCARR-CARRID, GS_SCARR-CARRNAME.
ENDSELECT.
