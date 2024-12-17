*&---------------------------------------------------------------------*
*&  Include           ZEDR07_092_F01
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

  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ICON'.  " 아이콘 필드를 필드 카탈로그에 추가
  GS_FIELDCAT-COLTEXT = '체크'.
  GS_FIELDCAT-ICON = 'X'.  " 필드가 아이콘 필드임을 지정
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'.
  GS_FIELDCAT-COLTEXT = '학생코드'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-HOTSPOT = 'X'. "HOTSPOT 컬럼 지정
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '출석번호'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-COLTEXT = '한글이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZENAME'.
  GS_FIELDCAT-COLTEXT = '영문이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZTEL'.
  GS_FIELDCAT-COLTEXT = '전화번호'.
  GS_FIELDCAT-EDIT = 'X'. "편집가능
  GS_FIELDCAT-OUTPUTLEN = 12.
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
*&      Form  ALV_HANDLER_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM ALV_HANDLER_USER_COMMAND  USING    P_UCOMM.

  CASE P_UCOMM.
    WHEN 'SAVE'.
      MESSAGE '저장 성공' TYPE 'I'.
  ENDCASE.

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
  CREATE OBJECT GO_EVENT.

  SET HANDLER GO_EVENT->HANDLER_USER_COMMAND FOR GC_GRID.

  "REGISTER_EDIT_EVENT 메서드를 사용해서 이벤트를 어느시점에 적용할건지를 지정함
  CALL METHOD GC_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED
*    EXCEPTIONS
*      ERROR      = 1
*      others     = 2
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

  SET HANDLER GO_EVENT->HANDLER_DATA_CHANGED FOR GC_GRID.
  SET HANDLER GO_EVENT->HANDLER_DATA_CHANGED_FINISHED FOR GC_GRID.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_HANDLER_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*      -->P_E_ONF4  text
*      -->P_E_ONF4_BEFORE  text
*      -->P_E_ONF4_AFTER  text
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM ALV_HANDLER_DATA_CHANGED  USING    P_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                        P_ONF4
                                        P_ONF4_BEFORE
                                        P_ONF4_AFTER
                                        P_UCOMM.

  DATA : LS_MODI TYPE LVC_S_MODI. "MT_GOOD_CELLS의 타입
  DATA : LV_LEN(02).

  CLEAR : LS_MODI, LV_LEN.

  LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MODI.
    IF LS_MODI-FIELDNAME = 'ZTEL'.
      READ TABLE GT_STUDENT INTO GS_STUDENT INDEX LS_MODI-ROW_ID.

      IF LS_MODI-VALUE IS INITIAL.
        GS_STUDENT-ICON = ICON_LED_RED.
      ELSE.
        LV_LEN = STRLEN( LS_MODI-VALUE ).
        IF LV_LEN = '11'.
          GS_STUDENT-ICON = ICON_LED_GREEN.
        ELSE.
          GS_STUDENT-ICON = ICON_LED_YELLOW.
        ENDIF.
      ENDIF.

      MODIFY GT_STUDENT FROM GS_STUDENT INDEX LS_MODI-ROW_ID.
      CLEAR GS_STUDENT.

    ENDIF.
  ENDLOOP.

  PERFORM REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM ALV_DATA_CHANGED_FINISHED  USING    P_MODIFIED
                                         PT_GOOD_CELLS TYPE LVC_T_MODI.

  DATA : LS_MODI TYPE LVC_S_MODI.

  CLEAR : LS_MODI.

  LOOP AT PT_GOOD_CELLS INTO LS_MODI.
    IF LS_MODI-FIELDNAME = 'ZTEL'.
      READ TABLE GT_STUDENT INTO GS_STUDENT INDEX LS_MODI-ROW_ID.

      IF GS_STUDENT-ICON NE ICON_LED_GREEN.
        DELETE TABLE GT_STUDENT FROM GS_STUDENT.
      ENDIF.

      CLEAR GS_STUDENT.
      ENDIF.
  ENDLOOP.

  PERFORM REFRESH.

ENDFORM.
