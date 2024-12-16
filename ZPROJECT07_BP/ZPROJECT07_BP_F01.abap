*&---------------------------------------------------------------------*
*&  Include           ZEDR07_PROJECT001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN .
  "라디오선택에 따라 입력 스크린 달라지도록 함
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'. "생성선택
      IF P_R1 = C_X.
        SCREEN-ACTIVE = '1'.
      ELSEIF P_R2 = C_X.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'. "조회선택
      IF P_R1 = C_X.
        SCREEN-ACTIVE = '0'.
      ELSEIF P_R2 = C_X.
        SCREEN-ACTIVE = '1'.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_INITIAL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_INITIAL_DATA . "처음 조회 시 점검
  "입력되었는지 확인하기 위한 체크 변수 (입력되었다면 X값을 가진다)
  DATA : LV_CHECK_BURKS TYPE C. "회사코드
  DATA : LV_CHECK_KTOKK TYPE C. "구매처그룹
  DATA : LV_CHECK_LIFNR TYPE C. "구매처번호

  IF P_BUKRS IS NOT INITIAL.
    LV_CHECK_BURKS = 'X'.
  ENDIF.

  IF P_KTOKK IS NOT INITIAL.
    LV_CHECK_KTOKK = 'X'.
  ENDIF.

  IF P_LIFNR IS NOT INITIAL.
    LV_CHECK_LIFNR = 'X'.
  ENDIF.

  "둘 중 하나라도 입력하지 않으면 안됨
  IF P_R1 = C_X. "생성을 선택한 경우
    IF LV_CHECK_BURKS = '' OR LV_CHECK_KTOKK = ' '.
      MESSAGE E000.
      EXIT.
    ENDIF.
  ELSEIF P_R2 = C_X. "조회를 선택한 경우
    IF LV_CHECK_BURKS = '' OR LV_CHECK_LIFNR = ' '.
      MESSAGE E000.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE OK_CODE.
    WHEN 'ADD'. "ADD 버튼 클릭 시
      CLEAR GS_ALV_ROW.

      PERFORM ADD_ROW_TO_ALV.
      PERFORM REFRESH.

    WHEN 'SAVE'.  "SAVE 버튼 클릭 시
      LOOP AT GT_ALV_DATA INTO GS_ALV_ROW.
        MOVE-CORRESPONDING GS_ALV_ROW TO GS_SAVE_LFA1.
        MOVE-CORRESPONDING GS_ALV_ROW TO GS_SAVE_LFB1.
        MOVE-CORRESPONDING GS_ALV_ROW TO GS_SAVE_LFM1.

        "GS_SAVE-LIFNR 자동채번
        DATA: LV_LIFNR TYPE ZLFA107-LIFNR.

       CALL FUNCTION 'NUMBER_GET_NEXT'
         EXPORTING
           NR_RANGE_NR                   = '01'
           OBJECT                        = 'ZLIFNR07'
           QUANTITY                      = '1'
        IMPORTING
          NUMBER                        = LV_LIFNR
                 .
       IF SY-SUBRC <> 0.
          MESSAGE '구매처번호 생성 실패' TYPE 'E'.
          EXIT.
       ENDIF.

        GS_SAVE_LFA1-LIFNR = LV_LIFNR.
        GS_SAVE_LFB1-LIFNR = LV_LIFNR.
        GS_SAVE_LFM1-LIFNR = LV_LIFNR.

        APPEND GS_SAVE_LFA1 TO GT_SAVE_LFA1.
        APPEND GS_SAVE_LFB1 TO GT_SAVE_LFB1.
        APPEND GS_SAVE_LFM1 TO GT_SAVE_LFM1.

      ENDLOOP.

     INSERT ZLFA107 FROM TABLE GT_SAVE_LFA1.
     INSERT ZLFB107 FROM TABLE GT_SAVE_LFB1.
     INSERT ZLFM107 FROM TABLE GT_SAVE_LFM1.

     IF SY-SUBRC = 0.
       MESSAGE '저장성공' TYPE 'I'.
     ELSE.
       MESSAGE '저장실패' TYPE 'I'.
     ENDIF.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  ADD_ROW_TO_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_ROW_TO_ALV .

  " ALV 데이터 테이블에 새로운 행 추가
  CLEAR GS_ALV_ROW.
  GS_ALV_ROW-BUKRS = P_BUKRS.
  GS_ALV_ROW-KTOKK = P_KTOKK.
  APPEND GS_ALV_ROW TO GT_ALV_DATA.

  "ALV 데이터 갱신
  PERFORM REFRESH.

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
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG .
  "회사코드
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'BUKRS'.
  LS_FIELDCAT-COLTEXT = '회사코드'.
  LS_FIELDCAT-OUTPUTLEN = 5.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  "구매처그룹
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'KTOKK'.
  LS_FIELDCAT-COLTEXT = '구매처그룹'.
  LS_FIELDCAT-OUTPUTLEN = 7.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 구매처명
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'NAME1'.
  LS_FIELDCAT-COLTEXT = '구매처명'.
  LS_FIELDCAT-OUTPUTLEN = 15.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 국가키
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'LAND1'.
  LS_FIELDCAT-COLTEXT = '국가키'.
  LS_FIELDCAT-OUTPUTLEN = 5.
  IF P_R1 = C_X.
     LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  IF P_R1 = C_X.
    IF P_KTOKK = '3000'. "3000일때만 개인번호 보임
      " 개인번호
      CLEAR LS_FIELDCAT.
      LS_FIELDCAT-FIELDNAME = 'STCD1'.
      LS_FIELDCAT-COLTEXT = '개인번호'.
      LS_FIELDCAT-OUTPUTLEN = 16.
      LS_FIELDCAT-EDIT = 'X'.
      APPEND LS_FIELDCAT TO LT_FIELDCAT.
    ENDIF.

    IF P_KTOKK <> '2000' AND P_KTOKK <> '3000'.
      " 사업자번호
      CLEAR LS_FIELDCAT.
      LS_FIELDCAT-FIELDNAME = 'STCD2'.
      LS_FIELDCAT-COLTEXT = '사업자번호'.
      LS_FIELDCAT-OUTPUTLEN = 10.
      LS_FIELDCAT-EDIT = 'X'.
      APPEND LS_FIELDCAT TO LT_FIELDCAT.
    ENDIF.
  ELSEIF P_R2 = C_X.
    DATA : LV_KTOKK TYPE ZLFA107-KTOKK. "구매처 그룹

    LOOP AT GT_ALV_DATA INTO GS_ALV_ROW.
      LV_KTOKK = GS_ALV_ROW-KTOKK. "조회한 데이터의 구매처 그룹 정보 가져옴
    ENDLOOP.
    IF LV_KTOKK = '3000'. "3000일때만 개인번호 보임
      " 개인번호
      CLEAR LS_FIELDCAT.
      LS_FIELDCAT-FIELDNAME = 'STCD1'.
      LS_FIELDCAT-COLTEXT = '개인번호'.
      LS_FIELDCAT-OUTPUTLEN = 16.
      LS_FIELDCAT-EDIT = 'X'.
      APPEND LS_FIELDCAT TO LT_FIELDCAT.
    ENDIF.

    IF LV_KTOKK <> '2000' AND LV_KTOKK <> '3000'.
      " 사업자번호
      CLEAR LS_FIELDCAT.
      LS_FIELDCAT-FIELDNAME = 'STCD2'.
      LS_FIELDCAT-COLTEXT = '사업자번호'.
      LS_FIELDCAT-OUTPUTLEN = 10.
      LS_FIELDCAT-EDIT = 'X'.
      APPEND LS_FIELDCAT TO LT_FIELDCAT.
    ENDIF.

  ENDIF.

  " 주소
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'STRAS'.
  LS_FIELDCAT-COLTEXT = '주소'.
  LS_FIELDCAT-OUTPUTLEN = 20.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  "계정
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'AKONT'.
  LS_FIELDCAT-COLTEXT = '계정'.
  LS_FIELDCAT-OUTPUTLEN = 11.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 지급조건
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'ZTERM'.
  LS_FIELDCAT-COLTEXT = '지급조건'.
  LS_FIELDCAT-OUTPUTLEN = 5.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 구매조직
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'EKORG'.
  LS_FIELDCAT-COLTEXT = '구매조직'.
  LS_FIELDCAT-OUTPUTLEN = 5.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 구매그룹
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'EKGRP'.
  LS_FIELDCAT-COLTEXT = '구매그룹'.
  LS_FIELDCAT-OUTPUTLEN = 5.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 구매오더통화
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'WAERS'.
  LS_FIELDCAT-COLTEXT = '구매오더통화'.
  LS_FIELDCAT-OUTPUTLEN = 10.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  " 세금코드
  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-FIELDNAME = 'MWSKZ'.
  LS_FIELDCAT-COLTEXT = '세금코드'.
  LS_FIELDCAT-OUTPUTLEN = 5.
  IF P_R1 = C_X.
    LS_FIELDCAT-EDIT = 'X'.
  ENDIF.
  APPEND LS_FIELDCAT TO LT_FIELDCAT.

    " ALV 필드 카탈로그 설정
    CALL METHOD GC_GRID->SET_FRONTEND_FIELDCATALOG
      EXPORTING
        IT_FIELDCATALOG = LT_FIELDCAT
      .

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
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .

    "그리드에서 함수 호출****
      CALL METHOD GC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          I_STRUCTURE_NAME              = 'TY_ALV_ROW'
        CHANGING
          IT_OUTTAB                     = GT_ALV_DATA
          IT_FIELDCATALOG               = LT_FIELDCAT
              .
      IF SY-SUBRC <> 0.
*       Implement suitable error handling here
      ENDIF.

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
                                        P_E_ONF4
                                        P_E_ONF4_BEFORE
                                        P_E_ONF4_AFTER
                                        P_E_UCOMM.

    DATA : LS_MODI TYPE LVC_S_MODI.
    DATA : LV_LEN(02).

    CLEAR : LS_MODI.

    LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MODI.
      IF LS_MODI-FIELDNAME = 'STCD1'.
          READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

          IF LS_MODI-VALUE IS INITIAL.
            MESSAGE '개인번호를 입력해주세요.' TYPE 'I'.
          ELSE.
            LV_LEN = STRLEN( LS_MODI-VALUE ).
            IF LV_LEN <> '13'.
              MESSAGE '개인번호를 확인해주세요.(13자리).' TYPE 'I'.
            ENDIF.
          ENDIF.
      ENDIF.

      IF LS_MODI-FIELDNAME = 'STCD2'.
          READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

          IF LS_MODI-VALUE IS INITIAL.
            MESSAGE '사업자번호를 입력해주세요.' TYPE 'I'.
          ELSE.
            LV_LEN = STRLEN( LS_MODI-VALUE ).
            IF LV_LEN <> '10'.
              MESSAGE '사업자번호를 확인해주세요.(10자리).' TYPE 'I'.
            ENDIF.
          ENDIF.
      ENDIF.

    ENDLOOP.


  " ALV 갱신
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

  LOOP AT PT_GOOD_CELLS INTO LS_MODI.
    " 변경된 셀이 STCD1 또는 STCD2라면 처리
    IF LS_MODI-FIELDNAME = 'STCD1' OR LS_MODI-FIELDNAME = 'STCD2'.

      READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

*    BREAK-POINT.

      IF SY-SUBRC = 0.
        " 수정된 값을 반영
        IF LS_MODI-FIELDNAME = 'STCD1'.
          GS_ALV_ROW-STCD1 = LS_MODI-VALUE.
        ELSEIF LS_MODI-FIELDNAME = 'STCD2'.
          GS_ALV_ROW-STCD2 = LS_MODI-VALUE.
        ENDIF.

        " 반영된 데이터를 다시 GT_ALV_DATA에 업데이트
        MODIFY GT_ALV_DATA FROM GS_ALV_ROW INDEX LS_MODI-ROW_ID.

        CLEAR : GS_ALV_ROW.
      ENDIF.
    ENDIF.
  ENDLOOP.

 PERFORM REFRESH. " ALV 데이터 갱신
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

    SELECT
        A~LIFNR
        B~BUKRS
        A~KTOKK
        A~NAME1
        A~LAND1
        A~STCD1
        A~STCD2
        A~STRAS
        B~AKONT
        B~ZTERM
        M~EKORG
        M~EKGRP
        M~WAERS
        M~MWSKZ
    INTO CORRESPONDING FIELDS OF TABLE GT_ALV_DATA
    FROM ZLFB107 AS B
    INNER JOIN ZLFA107 AS A ON B~LIFNR = A~LIFNR
    INNER JOIN ZLFM107 AS M ON B~LIFNR = M~LIFNR
    WHERE B~BUKRS = P_BUKRS AND B~LIFNR = P_LIFNR.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIND_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_SAVE_LFA1  text
*      <--P_LV_LIFNR  text
*----------------------------------------------------------------------*
FORM FIND_LIFNR  USING    P_SAVE_LFA1 STRUCTURE GS_SAVE_LFA1
                 CHANGING P_FINDED_LIFNR TYPE LFA1-LIFNR.

  SELECT SINGLE LIFNR
    INTO P_FINDED_LIFNR
    FROM ZLFA107
    WHERE LAND1 = P_SAVE_LFA1-LAND1
      AND KTOKK = P_SAVE_LFA1-KTOKK
      AND STCD1 = P_SAVE_LFA1-STCD1
      AND STCD2 = P_SAVE_LFA1-STCD2
      AND STRAS = P_SAVE_LFA1-STRAS.

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

    "ALV 컨테이너 생성
    CREATE OBJECT GC_CUSTOM
      EXPORTING
        CONTAINER_NAME              = 'CONTAINER_MAIN'
        .
    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    "그리드 생성
    CREATE OBJECT GC_GRID
      EXPORTING
        I_PARENT          = GC_CUSTOM
        .
    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

ENDFORM.
