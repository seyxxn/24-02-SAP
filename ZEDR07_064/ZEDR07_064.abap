*&---------------------------------------------------------------------*
*& Report ZEDR07_064
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_064.

DATA : BEGIN OF GS_SFLIGHT, "구조체 선언
  CARRID TYPE SFLIGHT-CARRID,
  CONNID TYPE SFLIGHT-CONNID,
  CARRNAME TYPE SCARR-CARRNAME,
  END OF GS_SFLIGHT.
DATA : GT_SFLIGHT LIKE TABLE OF GS_SFLIGHT. "인터널테이블 선언

"SELECT 문
SELECT A~CARRID "JOIN시에 SELECT로 가져오는 필드들을 어느 테이블에서 가져올 것인가
       A~CONNID
       B~CARRNAME
  INTO CORRESPONDING FIELDS OF TABLE GT_SFLIGHT
  FROM SFLIGHT AS A "별칭 지정
  LEFT OUTER JOIN SCARR AS B "LEFT OUTER JOIN
  "JOIN 연결의 왼쪽에 있는 데이터를 기준으로 SELECT 결과 도출
  ON A~CARRID = B~CARRID "JOIN 조건
  WHERE A~CARRID = 'AA'. "WHERE 조건 먼저 수행됨

LOOP AT GT_SFLIGHT INTO GS_SFLIGHT.
  WRITE :/ GS_SFLIGHT-CARRID, GS_SFLIGHT-CONNID, GS_SFLIGHT-CARRNAME.
ENDLOOP.
