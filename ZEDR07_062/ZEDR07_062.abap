*&---------------------------------------------------------------------*
*& Report ZEDR07_062
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_062.

"SUBQUERY는 SELECT 구문의 WHERE 조건에 또 다른 SELECT 구문을 추가하여 값을 제한함
"SUBQUERY를 이용해 특별한 조건을 WHERE 구문에 추가함
"SUBQUERY의 SELECT 구문에는 컬럼 하나만 선언함

DATA : BEGIN OF GS_SFLIGHT, "구조체 선언
  CARRID TYPE SFLIGHT-CARRID,
  CONNID TYPE SFLIGHT-CONNID,
  PRICE TYPE SFLIGHT-PRICE,
  END OF GS_SFLIGHT.
DATA : GT_SFLIGHT LIKE TABLE OF GS_SFLIGHT. "인터널테이블 선언

"SELECT 문
SELECT CARRID
       CONNID
       PRICE
  INTO CORRESPONDING FIELDS OF TABLE GT_SFLIGHT
  FROM SFLIGHT AS A "별칭 사용 가능
  WHERE CARRID IN ( SELECT CARRID
                    FROM SPFLI
                    WHERE CARRID = A~CARRID "별칭 사용 가능
                      AND CONNID = A~CONNID ) "SUBQUERY 조건에 해당하는 값만 읽음
  AND CARRID = 'AA'
  AND CONNID LIKE '00%'.

LOOP AT GT_SFLIGHT INTO GS_SFLIGHT.
  WRITE :/ GS_SFLIGHT-CARRID, GS_SFLIGHT-CONNID, GS_SFLIGHT-PRICE.
ENDLOOP.
