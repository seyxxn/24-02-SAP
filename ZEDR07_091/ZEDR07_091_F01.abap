*&---------------------------------------------------------------------*
*&  Include           ZEDR07_091_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_INIT .
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
FORM GET_DATA .
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
FORM CREATE_OBJECT .
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

  CREATE OBJECT GC_GRID
    EXPORTING
      I_PARENT          = GC_DOCKING
      .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
 CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 0.
  GS_FIELDCAT-FIELDNAME = 'ICON'.
  GS_FIELDCAT-COLTEXT = '체크'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'.
  GS_FIELDCAT-COLTEXT = '학생코드'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-HOTSPOT = 'X'. "HOTSPOT 컬럼 지정
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '출석번호'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-COLTEXT = '한글이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZENAME'.
  GS_FIELDCAT-COLTEXT = '영문이름'.
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
  CLEAR : GS_SORT, GT_SORT.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT.
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
  CALL METHOD GC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_STUDENT
      IT_FIELDCATALOG               = GT_FIELDCAT
      IT_SORT                       = GT_SORT
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_HANDLER_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM ALV_HANDLER_TOOLBAR  USING    P_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                                   P_INTERACTIVE.
"TOOLBAR 이벤트를 이용하기 위해서는
"E_OBJECT가 필요한데, 이것은 CL_ALV_EVENT_TOOLBAR_SET 객체를 참조하고 있음

"CL_ALV_EVENT_TOOLBAR_SET 객체의 속성 중 MT_TOOLBAR를 사용하려고 함
"MT_TOOLBAR는 TTB_BUTTON 객체를 참조하고 있음

"TTB_BUTTON은 STB_BUTTON을 참조하여 TOOLBAR 기능을 사용하고 있음

  DATA : LS_TOOLBAR TYPE STB_BUTTON. "그럼 우리는 STB_BUTTON 부터 일단 만들면됨

  LS_TOOLBAR-FUNCTION = 'TEXT'. "여기서 이름 정해줌
  LS_TOOLBAR-ICON = ICON_CHECKED.
  LS_TOOLBAR-QUICKINFO = 'INFORMATION'. "QUICK INFO에 메세지를 넣으면 마우스 근접시 메세지가 출력됨

  APPEND LS_TOOLBAR TO P_OBJECT->MT_TOOLBAR.
  "P_OBJECT의 MT_TOOLBAR에 LS_TOOLBAR 넣음

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

  CALL METHOD GC_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CLASS_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLASS_EVENT .

  CREATE OBJECT GO_EVENT. "EVENT 객체 생성

  "핸들러 생성(반드시 기억)
  SET HANDLER GO_EVENT->HANDLER_TOOLBAR FOR GC_GRID.
  SET HANDLER GO_EVENT->HANDLER_USER_COMMAND FOR GC_GRID.

  "HOTSPOT_CLICK
  SET HANDLER GO_EVENT->HANDLER_HOTSPOT_CLICK FOR GC_GRID.

  "DOUBLE CLICK
* SET HANDLER GO_EVENT->HANDLER_DOUBLE_CLICK FOR GC_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_HANDLER_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM ALV_HANDLER_USER_COMMAND  USING    P_UCOMM.

  CASE P_UCOMM.
    WHEN 'TEXT'.
      MESSAGE '학생정보데이터입니다.' TYPE 'I'.
   ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_HANDLER_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*      -->P_ES_ROW_ID  text
*----------------------------------------------------------------------*
FORM ALV_HANDLER_HOTSPOT_CLICK  USING    P_ROW_ID TYPE LVC_S_ROW
                                         P_COLUMN_ID TYPE LVC_S_COL
                                         P_ROW_NO TYPE LVC_S_ROID.

  "HOTSPOT 기능
  CASE P_COLUMN_ID-FIELDNAME. "COLUMN 제어 (속성 중 FIELDNAME을 사용)
    WHEN 'ZCODE'.
      READ TABLE GT_STUDENT INTO GS_STUDENT INDEX P_ROW_NO-ROW_ID. "ROW 제어
      SET PARAMETER ID 'XUS' FIELD GS_STUDENT-ZCODE. "제어 필드의 파라미터 값 입력
      CALL TRANSACTION 'SU01'. "HOTSPOT 이벤트를 통해 실행하려는 티코드 입력
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_HANDLER_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM ALV_HANDLER_DOUBLE_CLICK  USING    P_ROW TYPE LVC_S_ROW
                                        P_COLUMN_ID TYPE LVC_S_COL
                                        P_ROW_NO TYPE LVC_S_ROID.

  DATA : LV_CHAR(2). "ROW 데이터를 담기 위한 변수 생성
  DATA : LV_MESSAGE(20). "더블클릭 시 뿌려주는 메세지 변수 생성

"만약 열 제어를 주석처리하면, 지정한 필드 값이 아닌 다른 필드 값을 클릭해도 몇번째 데이터인지 출력됨
*  CASE P_COLUMN_ID-FIELDNAME.
*    WHEN 'ZCODE'. "열 제어 가능
      CLEAR GS_STUDENT.
      LV_CHAR = P_ROW_NO-ROW_ID.
      READ TABLE GT_STUDENT INTO GS_STUDENT INDEX P_ROW_NO-ROW_ID. "행 제어 가능
      IF SY-SUBRC = 0.
        LV_CHAR = P_ROW_NO-ROW_ID.
        CONCATENATE LV_CHAR '번째 데이터 입니다.' INTO LV_MESSAGE.
        MESSAGE LV_MESSAGE TYPE 'I'.
      ENDIF.
*  ENDCASE.

ENDFORM.
