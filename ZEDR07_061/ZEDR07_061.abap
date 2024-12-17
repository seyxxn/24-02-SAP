*&---------------------------------------------------------------------*
*& Report ZEDR07_061
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_061.

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
  FROM SFLIGHT GROUP BY CARRID CONNID
  HAVING AVG( PRICE ) > 1000 "HAVING 절을 이용해서 GROUP BY한 것에 조건 추가
*  ORDER BY CARRID. "CARRID 로 정렬하여 조회(오름차순 기본)
*  ORDER BY CONNID DESCENDING. "CARRID 내림차순 정렬
*  ORDER BY PRICE. "PRICE 필드로 오름차순 정렬 -> 오류남. 별칭 그대로 작성해야 함
  ORDER BY GV_SUM.

LOOP AT GT_SFLIGHT INTO GS_SFLIGHT.
  WRITE :/ GS_SFLIGHT-CARRID, GS_SFLIGHT-CONNID, GS_SFLIGHT-GV_SUM.
ENDLOOP.
