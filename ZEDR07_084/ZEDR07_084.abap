

*&---------------------------------------------------------------------*
*& Report ZEDR07_084
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_084.

TABLES : ZEDT07_001.

*DATA : BEGIN OF GT_STUDENT OCCURS 0,
*  ZCOLOR TYPE C LENGTH 4, "신호등 색상을 표기하기 위한 변수
*  ZCHECKBOX TYPE C, "체크박스를 표기하기 위한 변수
*  ZCODE LIKE ZEDT07_001-ZCODE,
*  ZPERNR LIKE ZEDT07_001-ZPERNR,
*  ZKNAME LIKE ZEDT07_001-ZKNAME,
*  ZENAME LIKE ZEDT07_001-ZENAME,
*  ZGENDER LIKE ZEDT07_001-ZGENDER,
*  ZMAJOR LIKE ZEDT07_002-ZMAJOR,
*  ZMNAME LIKE ZEDT07_002-ZMNAME,
*  END OF GT_STUDENT.

DATA : BEGIN OF GS_STUDENT OCCURS 0,
  ZCOLOR TYPE C LENGTH 4, "신호등 색상을 표기하기 위한 변수
  ZCHECKBOX TYPE C, "체크박스를 표기하기 위한 변수
  ZCODE LIKE ZEDT07_001-ZCODE,
  ZPERNR LIKE ZEDT07_001-ZPERNR,
  ZKNAME LIKE ZEDT07_001-ZKNAME,
  ZENAME LIKE ZEDT07_001-ZENAME,
  ZGENDER LIKE ZEDT07_001-ZGENDER,
  ZMAJOR LIKE ZEDT07_002-ZMAJOR,
  ZMNAME LIKE ZEDT07_002-ZMNAME,
  END OF GS_STUDENT.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

DATA : GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

START-OF-SELECTION.
  PERFORM GET_DATA. "데이터 먼저 가지고 오기
  PERFORM MODIFY_DATA.
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
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*   EXPORTING
*     I_PROGRAM_NAME               = SY-REPID
*     I_INTERNAL_TABNAME           = 'GT_STUDENT'
*     I_INCLNAME                   = SY-REPID
*    CHANGING
*      CT_FIELDCAT                  = GT_FIELDCAT.
  PERFORM FIELD_CATALOG.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     IT_FIELDCAT                       = GT_FIELDCAT
    TABLES
      T_OUTTAB                         = GT_STUDENT.

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
  GS_FIELDCAT-FIELDNAME = 'ZCHECKBOX'.
  GS_FIELDCAT-SELTEXT_M = '체크구분'.
  GS_FIELDCAT-CHECKBOX = 'X'.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2. "컬럼의 OUTPUT 순서
  GS_FIELDCAT-FIELDNAME = 'ZCODE'. "필드 카탈로그의 필드 이름(인터널 테이블의 필드 이름과 같아야함)
  GS_FIELDCAT-SELTEXT_M = '학생코드'. "출력될 필드 명
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-SELTEXT_M = '출석번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-SELTEXT_M = '이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZENAME'.
  GS_FIELDCAT-SELTEXT_M = '영문이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZCOLOR'.
  GS_FIELDCAT-SELTEXT_M = '표기'.
  GS_FIELDCAT-ICON = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA .
  CLEAR GS_STUDENT.

  LOOP AT GT_STUDENT INTO GS_STUDENT.
    IF GS_STUDENT-ZENAME IS INITIAL.
      GS_STUDENT-ZCOLOR = '@0A@'.
    ENDIF.

    MODIFY GT_STUDENT FROM GS_STUDENT INDEX SY-TABIX.
    CLEAR GS_STUDENT.
  ENDLOOP.

ENDFORM.
