*&---------------------------------------------------------------------*
*&  Include           ZEDR07_088_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_INIT . "초기 세팅
  S_ZCODE-LOW = 'SSU-01'.
  S_ZCODE-HIGH = 'SSU-99'.
  APPEND S_ZCODE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA . "DB에서 데이터 가져오기
  SELECT * FROM ZEDT07_001
    INTO CORRESPONDING FIELDS OF TABLE GT_STUDENT
    WHERE ZCODE IN S_ZCODE AND ZGENDER = P_ZGEN.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT . "객체 생성 -> PATTERN 이용
  "DOCKING CONTAINER 객체 먼저 생성
  CREATE OBJECT GC_DOCKING
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 2000
      .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "SPLITTER CONTAINER 객체 생성
  CREATE OBJECT GC_SPLITTER
    EXPORTING
      PARENT            = GC_DOCKING "위에서 만든 도킹컨테이너명
      ROWS              = 2 "화면을 어떻게 나눌 것인가 ?
      COLUMNS           = 1 "2행 1열
      .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

"SPLITTER에 각각의 CONTAINER 호출 (PATTERN 이용)
CALL METHOD GC_SPLITTER->GET_CONTAINER
  EXPORTING
    ROW       = 1
    COLUMN    = 1
  RECEIVING
    CONTAINER = GC_CONTAINER1 "1행 1열에 CONTAINER1 붙이기
    .

CALL METHOD GC_SPLITTER->GET_CONTAINER
  EXPORTING
    ROW       = 2
    COLUMN    = 1
  RECEIVING
    CONTAINER = GC_CONTAINER2 "1행 2열에 CONTAINER2 붙이기
    .

"컨테이너 모두 생성하고 붙였으니
"이제 그리드 생성
"컨테이너가 2개 이기때문에 그리드도 2개임
CREATE OBJECT GC_GRID1
  EXPORTING
    I_PARENT          = GC_CONTAINER1 "그리드의 부모는 컨테이너
    .
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

CREATE OBJECT GC_GRID2
  EXPORTING
    I_PARENT          = GC_CONTAINER2
    .
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

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
  PERFORM CONTAINER1_FIELD. "컨테이너1 필드설정
  PERFORM CONTAINER2_FIELD. "컨테이너2 필드설정
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER1_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER1_FIELD .
  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'.
  GS_FIELDCAT-COLTEXT = '학생코드'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '출석번호'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-COLTEXT = '한글이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER2_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER2_FIELD .
  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'.
  GS_FIELDCAT-COLTEXT = '학생코드'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '출석번호'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZENAME'.
  GS_FIELDCAT-COLTEXT = '영문이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.
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
  CLEAR : GS_LAYOUT.
  GS_LAYOUT-ZEBRA = 'X'.
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
  CLEAR : GS_SORT, GT_SORT1.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT1.

  CLEAR : GS_SORT, GT_SORT2.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-DOWN = 'X'.
  APPEND GS_SORT TO GT_SORT2.

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
  CALL METHOD GC_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      IS_VARIANT                    =
*      I_SAVE                        =
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_STUDENT
      IT_FIELDCATALOG               = GT_FIELDCAT1
      IT_SORT                       = GT_SORT1
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

  CALL METHOD GC_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      IS_VARIANT                    =
*      I_SAVE                        =
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_STUDENT
      IT_FIELDCATALOG               = GT_FIELDCAT2
      IT_SORT                       = GT_SORT2
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH .
  DATA : LS_STABLE TYPE LVC_S_STBL.

  "REFRESH 메서드 PATTERN으로 부름
  CALL METHOD GC_GRID1->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

  CALL METHOD GC_GRID2->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.



ENDFORM.
