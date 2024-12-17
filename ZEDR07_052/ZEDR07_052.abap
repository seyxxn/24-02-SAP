*&---------------------------------------------------------------------*
*& Report ZEDR07_052
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_052.

DATA : BEGIN OF GS_SCARR,
  CARRID LIKE SCARR-CARRID,
  CARRNAME LIKE SCARR-CARRNAME,
  END OF GS_SCARR.
DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

*DATA : BEGIN OF GS_SCARR,
*  ZCHECK TYPE C, "추가 됨
*  CARRID LIKE SCARR-CARRID,
*  CARRNAME LIKE SCARR-CARRNAME,
*  END OF GS_SCARR.
*DATA : GT_SCARR LIKE TABLE OF GS_SCARR.

SELECT CARRID
       CARRNAME
  FROM SCARR
  INTO TABLE GT_SCARR "INTO TABLE은 순서대로 인터널테이블에 들어감
  WHERE CARRID = 'AA'.

LOOP AT GT_SCARR INTO GS_SCARR.
  WRITE :/ GS_SCARR-CARRID, GS_SCARR-CARRNAME.
ENDLOOP.
