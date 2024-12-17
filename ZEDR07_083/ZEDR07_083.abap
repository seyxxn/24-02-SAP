*&---------------------------------------------------------------------*
*& Report ZEDR07_083
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_083.

TABLES : ZEDT07_001.

DATA : BEGIN OF GT_STUDENT OCCURS 0,
  ZCODE LIKE ZEDT07_001-ZCODE,
  ZPERNR LIKE ZEDT07_001-ZPERNR,
  ZKNAME LIKE ZEDT07_001-ZKNAME,
  ZENAME LIKE ZEDT07_001-ZENAME,
  ZGENDER LIKE ZEDT07_001-ZGENDER,
  ZMAJOR LIKE ZEDT07_002-ZMAJOR,
  ZMNAME LIKE ZEDT07_002-ZMNAME,
  ZSUM LIKE ZEDT07_002-ZSUM,
  END OF GT_STUDENT.

DATA : GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

DATA : GS_LAYOUT TYPE SLIS_LAYOUT_ALV.

DATA : GS_SORT TYPE SLIS_SORTINFO_ALV.
DATA : GT_SORT TYPE SLIS_T_SORTINFO_ALV.

START-OF-SELECTION.
  PERFORM GET_DATA. "데이터 먼저 가지고 오기
END-OF-SELECTION.
  PERFORM ALV_DISPLAY. "ALV 관련 설정하는 펑션 부르기
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
    SELECT A~ZCODE
      A~ZPERNR
      A~ZKNAME
      A~ZENAME
      A~ZGENDER
      B~ZMAJOR
      B~ZMNAME
      B~ZSUM
    FROM ZEDT07_001 AS A
    INNER JOIN ZEDT07_002 AS B
    ON A~ZCODE = B~ZCODE
    INTO CORRESPONDING FIELDS OF TABLE GT_STUDENT.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .
  PERFORM FIELD_CATALOG.
  PERFORM ALV_LAYOUT.
  PERFORM ALV_SORT.
  PERFORM CALL_ALV.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'.
  GS_FIELDCAT-SELTEXT_M = '학생코드'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-SELTEXT_M = '출석번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-SELTEXT_M = '이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZENAME'.
  GS_FIELDCAT-SELTEXT_M = '영문이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZGENDER'.
  GS_FIELDCAT-SELTEXT_M = '성별'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZMAJOR'.
  GS_FIELDCAT-SELTEXT_M = '전공코드'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZMNAME'.
  GS_FIELDCAT-SELTEXT_M = '전공명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'ZSUM'.
  GS_FIELDCAT-SELTEXT_M = '등록금'.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_LAYOUT .
*  GS_LAYOUT-NO_COLHEAD = 'X'. "ALV 칼럼 헤더를 조회되지 않게 설정
  GS_LAYOUT-ZEBRA = 'X'. "라인 단위 별로 줄무늬 패턴을 설정
*  GS_LAYOUT-NO_VLINE = 'X'. "GRID의 수직선을 보이지 않게 설정
*  GS_LAYOUT-NO_HLINE = 'X'. "GRID의 수평선을 보이지 않게 설정
*  GS_LAYOUT-EDIT = 'X'. "편집 모드 설정
  GS_LAYOUT-TOTALS_BEFORE_ITEMS = 'X'. "합계 금액을 맨 위의 라인에 설정

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_ALV .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     IS_LAYOUT                         = GS_LAYOUT
     IT_FIELDCAT                       = GT_FIELDCAT
     IT_SORT                           = GT_SORT
    TABLES
      T_OUTTAB                          = GT_STUDENT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_SORT .
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZCODE'. "정렬 기준
*  GS_SORT-UP = 'X'. "오름차순
  GS_SORT-DOWN = 'X'. "내림차순
*  GS_SORT-SUBTOT = 'X'. "서브토탈
  APPEND GS_SORT TO GT_SORT.

ENDFORM.
