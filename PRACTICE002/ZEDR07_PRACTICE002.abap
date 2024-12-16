*&---------------------------------------------------------------------*
*& Report ZEDR07_PRACTICE002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_PRACTICE002.

"구조체 정의
DATA : BEGIN OF GS_ZEDT001.
  INCLUDE TYPE ZEDT07_001.
  DATA : ZWARN TYPE C. "학사경고 여부
  DATA : ZMOVE TYPE C. "전과여부
  DATA : ZCHECK TYPE C. "성적을 받았는지에 대한 여부(성적 받았으면 X)
DATA : END OF GS_ZEDT001.


DATA : GS_ZEDT002 TYPE ZEDT07_002,
       GS_ZEDT003 TYPE ZEDT07_003.

DATA : GT_ZEDT001 LIKE TABLE OF GS_ZEDT001.
DATA : GT_ZEDT002 LIKE TABLE OF GS_ZEDT002.
DATA : GT_ZEDT003 LIKE TABLE OF GS_ZEDT003.


DATA : GS_MALESUM TYPE I, "남학생 등록금 총합
      GS_FEMALESUM TYPE I. "여학생 등록금 총합

GS_MALESUM = 0.
GS_FEMALESUM = 0.

"데이터 가져오기
SELECT * FROM ZEDT07_001
INTO CORRESPONDING FIELDS OF TABLE GT_ZEDT001.

SELECT * FROM ZEDT07_002
INTO CORRESPONDING FIELDS OF TABLE GT_ZEDT002.

SELECT * FROM ZEDT07_003
INTO CORRESPONDING FIELDS OF TABLE GT_ZEDT003.

"정렬
SORT GT_ZEDT001 BY ZCODE.
SORT GT_ZEDT002 BY ZCODE.
SORT GT_ZEDT003 BY ZCODE ZGRADE DESCENDING.

CLEAR : GS_ZEDT001.
CLEAR : GS_ZEDT002.
CLEAR : GS_ZEDT003.

LOOP AT GT_ZEDT001 INTO GS_ZEDT001.
  CLEAR GS_ZEDT003.
  MOVE-CORRESPONDING GS_ZEDT001 TO GS_ZEDT003.

  READ TABLE GT_ZEDT003 WITH KEY ZCODE = GS_ZEDT001-ZCODE INTO GS_ZEDT003.
  IF SY-SUBRC = 0.
    IF GS_ZEDT003-ZGRADE = 'D' OR GS_ZEDT003-ZGRADE = 'F'.
      GS_ZEDT001-ZWARN = 'X'.
    ENDIF.
  ELSE.
    CONTINUE.
  ENDIF.

  READ TABLE GT_ZEDT002 WITH KEY ZCODE = GS_ZEDT001-ZCODE INTO GS_ZEDT002.
  IF SY-SUBRC = 0.
    IF GS_ZEDT003-ZMNAME NE ''. "성적을 받지 않은 학생은 제외
      GS_ZEDT001-ZCHECK = 'X'.
    ENDIF.
    IF GS_ZEDT002-ZMNAME NE GS_ZEDT003-ZMNAME. "입학정보와 성적테이블 전공이 다른 경우
      GS_ZEDT001-ZMOVE = 'X'.
    ENDIF.
    IF GS_ZEDT001-ZGENDER = 'M'.
      GS_MALESUM = GS_MALESUM + GS_ZEDT002-ZSUM.
    ELSE.
      GS_FEMALESUM = GS_FEMALESUM + GS_ZEDT002-ZSUM.
    ENDIF.
  ELSE.
    CONTINUE.
  ENDIF.


  MODIFY GT_ZEDT001 FROM GS_ZEDT001.

*  IF SY-SUBRC = 0.
*    WRITE :/ GS_ZEDT001-ZCODE, GS_ZEDT001-ZKNAME, GS_ZEDT001-ZWARN, GS_ZEDT001-ZMOVE, GS_ZEDT002-ZMNAME, GS_ZEDT003-ZMNAME, GS_ZEDT001-ZCHECK.
*  ELSE.
*    WRITE :/ '데이터를 가져오지 못했습니다.'.
*  ENDIF.
ENDLOOP.

DELETE GT_ZEDT001 WHERE ZCHECK NE 'X'. "성적 받지 않은 데이터 테이블에서 삭제

LOOP AT GT_ZEDT001 INTO GS_ZEDT001.
  AT FIRST.
    WRITE :/ '---------------------------------------------------------------------------------------'.
    WRITE :/ '|   학생코드   |      이름       |  학사경고대상   |     전화번호         |    적요   |'.
    WRITE :/ '---------------------------------------------------------------------------------------'.
  ENDAT.


  WRITE: / '| ', GS_ZEDT001-ZCODE,
             ' | ', GS_ZEDT001-ZKNAME.

  IF GS_ZEDT001-ZWARN = 'X'.
    WRITE : '    |     학사경고    |'.
  ELSE.
    WRITE : '    |                 |'.
  ENDIF.

  IF GS_ZEDT001-ZWARN = 'X'.
    WRITE : '   ', GS_ZEDT001-ZTEL.
  ELSE.
    WRITE : '                    '.
  ENDIF.

  IF GS_ZEDT001-ZMOVE = 'X'.
    WRITE : '|  전과학생 |'.
  ELSE.
    WRITE : '|           |'.
  ENDIF.

    WRITE :/ '---------------------------------------------------------------------------------------'.

ENDLOOP.

DATA : LV_LINES TYPE I.
LV_LINES = LINES( GT_ZEDT001 ). " 내부 테이블의 레코드 수 가져오기

GS_MALESUM = GS_MALESUM * 100.
GS_FEMALESUM = GS_FEMALESUM * 100.

DO LV_LINES TIMES.
  IF SY-INDEX = 1. " 첫 번째 반복에서만 출력
    WRITE: / '남학생 등록금 총합: ', GS_MALESUM CURRENCY 'KRW', ' 원'.
    WRITE: / '여학생 등록금 총합: ', GS_FEMALESUM CURRENCY 'KRW', ' 원'.
  ENDIF.
ENDDO.
