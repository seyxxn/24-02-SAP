*&---------------------------------------------------------------------*
*& Report ZEDR07_059
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_059.

DATA : BEGIN OF GS_SFLIGHT, "구조체 선언
  CARRID TYPE SFLIGHT-CARRID,
  CONNID TYPE SFLIGHT-CONNID,
  GV_SUM TYPE I, "필드 정의 필요 !!
  END OF GS_SFLIGHT.
DATA : GT_SFLIGHT LIKE TABLE OF GS_SFLIGHT. "인터널테이블 선언

"SELECT 문
SELECT CARRID
       CONNID
       AVG( PRICE ) AS GV_SUM "반드시 AS 구문 이용해 별칭 쓰기
  INTO CORRESPONDING FIELDS OF TABLE GT_SFLIGHT
  FROM SFLIGHT GROUP BY CARRID CONNID.

LOOP AT GT_SFLIGHT INTO GS_SFLIGHT.
  WRITE :/ GS_SFLIGHT-CARRID, GS_SFLIGHT-CONNID, GS_SFLIGHT-GV_SUM.
ENDLOOP.
