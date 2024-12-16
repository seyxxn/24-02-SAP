*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_PO_F01
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

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'. "생성
      IF P_R1 = C_X.
        SCREEN-ACTIVE = '1'.
      ELSEIF P_R2 = C_X.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'. "조회
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
FORM CHECK_INITIAL_DATA .
  "입력되었는지 확인하는 변수(입력 되었다면 X)
  DATA : LV_CHECK_BUKRS TYPE C. "회사코드 -> 필수
  DATA : LV_CHECK_LIFNR TYPE C. "구매처번호 -> 필수
  DATA : LV_CHECK_BEDAT TYPE C. "증빙일 -> 생성시 필수
  DATA : LV_CHECK_EBELN TYPE C. "PO번호 -> 조회시 필수

  IF P_BUKRS IS NOT INITIAL.
    LV_CHECK_BUKRS = 'X'.
  ENDIF.

  IF P_LIFNR IS NOT INITIAL.
    LV_CHECK_LIFNR = 'X'.
  ENDIF.

  IF P_BEDAT IS NOT INITIAL.
    LV_CHECK_BEDAT = 'X'.
  ENDIF.

  IF S_EBELN[] IS NOT INITIAL.
    LV_CHECK_EBELN = 'X'.
  ENDIF.

  IF LV_CHECK_BUKRS = '' OR LV_CHECK_LIFNR = ''.
    MESSAGE E000.
    EXIT.
  ENDIF.

  IF P_R1 = C_X. "생성
    IF LV_CHECK_BEDAT = ''.
      MESSAGE E000.
      EXIT.
    ENDIF.

    "생성 시에 구매처정합성 체크 필수
    PERFORM CHECK_LIFNR.

  ELSEIF P_R2 = C_X. "조회
    IF LV_CHECK_EBELN = ''.
      MESSAGE E000.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_LIFNR . "사용자에게 입력받은 구매처번호가 구매처마스터에 존재하는지 정합성 체크

  "ZLFA107 테이블에서 구매처정보 일반데이터 읽기
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE GT_LFA1
  FROM ZLFA107 AS A
  WHERE A~LIFNR = P_LIFNR.

  IF GT_LFA1[] IS INITIAL.
    MESSAGE '구매처번호에 대한 정보가 존재하지 않습니다.' TYPE 'E'.
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
*  CLEAR LS_FIELDCAT.
*  LS_FIELDCAT-FIELDNAME = 'SEL'.
*  LS_FIELDCAT-COLTEXT = '삭제'.
*  LS_FIELDCAT-CHECKBOX = 'X'.
*  LS_FIELDCAT-EDIT = 'X'.
*  APPEND LS_FIELDCAT TO LT_FIELDCAT.

  CLEAR : GS_FIELDCAT, GT_FIELDCAT.

  "자재번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MATNR'.
  GS_FIELDCAT-COLTEXT = '자재번호'.
  GS_FIELDCAT-OUTPUTLEN = 13.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "자재명
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MAKTX'.
  GS_FIELDCAT-COLTEXT = '자재명'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "PO수량
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = 'PO수량'.
  GS_FIELDCAT-OUTPUTLEN = 6.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "수량 단위
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MEINS'.
  GS_FIELDCAT-COLTEXT = '수량 단위'.
  GS_FIELDCAT-OUTPUTLEN = 6.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "단가 금액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'NETPR'.
  GS_FIELDCAT-COLTEXT = '단가 금액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "단가 단위
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BPRME'.
  GS_FIELDCAT-COLTEXT = '단가 단위'.
  GS_FIELDCAT-OUTPUTLEN = 6.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "통화
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "세금코드
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MWSKZ'.
  GS_FIELDCAT-COLTEXT = '세금코드'.
  GS_FIELDCAT-OUTPUTLEN = 6.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "납품일
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'PRDAT'.
  GS_FIELDCAT-COLTEXT = '납품일'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "플랜트
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WERKS'.
  GS_FIELDCAT-COLTEXT = '플랜트'.
  GS_FIELDCAT-OUTPUTLEN = 6.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "저장위치
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LGORT'.
  GS_FIELDCAT-COLTEXT = '저장위치'.
  GS_FIELDCAT-OUTPUTLEN = 6.
  GS_FIELDCAT-EDIT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

    " ALV 필드 카탈로그 설정
    CALL METHOD GC_GRID->SET_FRONTEND_FIELDCATALOG
      EXPORTING
        IT_FIELDCATALOG = GT_FIELDCAT
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
          I_STRUCTURE_NAME              = 'TY_PO_ITEM'
          IS_LAYOUT                     = GS_LAYOUT
        CHANGING
          IT_OUTTAB                     = GT_ALV_DATA
          IT_FIELDCATALOG               = GT_FIELDCAT
              .
      IF SY-SUBRC <> 0.
*       Implement suitable error handling here
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
*&---------------------------------------------------------------------*
*&      Form  ADD_ROW_TO_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_ROW_TO_ALV .
* DATA : LV_LAST_EBELP TYPE ZEKPO07-EBELP.
* DATA : LV_NEW_EBELP TYPE ZEKPO07-EBELP.

* LOOP AT GT_ALV_DATA INTO GS_ALV_ROW.
*   IF GS_ALV_ROW-EBELP > LV_LAST_EBELP.
*     LV_LAST_EBELP = GS_ALV_ROW-EBELP.
*   ENDIF.
* ENDLOOP.

* IF LV_LAST_EBELP IS INITIAL.
*   LV_NEW_EBELP = 10.
* ELSE.
*   LV_NEW_EBELP = LV_LAST_EBELP + 10.
* ENDIF.

  " ALV 데이터 테이블에 새로운 행 추가
  CLEAR GS_ALV_ROW.
* GS_ALV_ROW-EBELP = LV_NEW_EBELP.
  APPEND GS_ALV_ROW TO GT_ALV_DATA.

  "ALV 데이터 갱신
  PERFORM REFRESH.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REMOVE_ROW_FROM_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REMOVE_ROW_FROM_ALV .
  DATA : LT_SELECTED_ROWS TYPE LVC_T_ROW,
         LS_SELECTED_ROW TYPE LVC_S_ROW,
         LV_INDEX TYPE I.

  " 선택된 행 가져오기
  CALL METHOD GC_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_SELECTED_ROWS
*      ET_ROW_NO     =
      .

  IF LT_SELECTED_ROWS IS INITIAL.
    MESSAGE '삭제할 행을 선택해주세요.' TYPE 'I'.
    RETURN.
  ENDIF.

  " 선택된 행 삭제
  LOOP AT LT_SELECTED_ROWS INTO LS_SELECTED_ROW.
    LV_INDEX = LS_SELECTED_ROW-INDEX.
    DELETE GT_ALV_DATA INDEX LV_INDEX.
  ENDLOOP.

  " ALV 데이터 갱신
  PERFORM REFRESH.

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
    GS_LAYOUT-BOX_FNAME = ''.
    GS_LAYOUT-SEL_MODE = 'A'.
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

    DATA : LS_MODI TYPE LVC_S_MODI.
    DATA : LV_LEN(02).
    DATA : LV_EXISTS TYPE C LENGTH 1,     " 자재번호 존재 여부 플래그
           LV_MSG    TYPE STRING.         " 메시지 문자열

    CLEAR : LS_MODI.

    LOOP AT P_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MODI.

      IF LS_MODI-FIELDNAME = 'MATNR'.
          READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

          IF LS_MODI-VALUE IS INITIAL.
           MESSAGE '자재번호는 필수 입력입니다.' TYPE 'I'.
          ENDIF.

          " 자재번호 유효성 확인 (ZMAT07 테이블에서 존재 여부)
          CLEAR LV_EXISTS.
          SELECT SINGLE MATNR
            INTO LV_EXISTS
            FROM ZMAT07
            WHERE MATNR = LS_MODI-VALUE.

           IF SY-SUBRC <> 0. " 자재번호가 존재하지 않을 때
             MESSAGE '유효하지 않은 자재번호입니다.' TYPE 'I'.
           ENDIF.

          MODIFY GT_ALV_DATA FROM GS_ALV_ROW INDEX LS_MODI-ROW_ID.
          CLEAR GS_ALV_ROW.

      ENDIF.

      IF LS_MODI-FIELDNAME = 'PRDAT'.
          READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

          IF LS_MODI-VALUE IS INITIAL.
            MESSAGE '납품일은 필수 입력입니다.' TYPE 'I'.
          ELSE.
            PERFORM CHECK_DELIVERY_DATE USING LS_MODI-VALUE CHANGING GS_ALV_ROW-VALID_PRDAT.
          ENDIF.

          MODIFY GT_ALV_DATA FROM GS_ALV_ROW INDEX LS_MODI-ROW_ID.
          CLEAR GS_ALV_ROW.

      ENDIF.

      IF LS_MODI-FIELDNAME = 'WERKS'.
          READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

          IF LS_MODI-VALUE IS INITIAL.
            MESSAGE '플랜트는 필수 입력입니다.' TYPE 'I'.
          ELSE.
            PERFORM CHECK_DOMAIN_VALIDITY USING 'ZWERKS07' LS_MODI-VALUE CHANGING GS_ALV_ROW-VALID_WERKS.
          ENDIF.

          MODIFY GT_ALV_DATA FROM GS_ALV_ROW INDEX LS_MODI-ROW_ID.
          CLEAR GS_ALV_ROW.

      ENDIF.

      IF LS_MODI-FIELDNAME = 'LGORT'.
          READ TABLE GT_ALV_DATA INTO GS_ALV_ROW INDEX LS_MODI-ROW_ID.

          IF LS_MODI-VALUE IS INITIAL.
            MESSAGE '저장위치는 필수 입력입니다.' TYPE 'I'.
          ELSE.
            PERFORM CHECK_DOMAIN_VALIDITY USING 'ZLGORT07' LS_MODI-VALUE CHANGING GS_ALV_ROW-VALID_LGORT.
          ENDIF.

          MODIFY GT_ALV_DATA FROM GS_ALV_ROW INDEX LS_MODI-ROW_ID.
          CLEAR GS_ALV_ROW.
      ENDIF.

    ENDLOOP.


    " ALV 갱신
    PERFORM REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_DELIVERY_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MODI_VALUE  text
*----------------------------------------------------------------------*
FORM CHECK_DELIVERY_DATE  USING  P_PRDAT
                          CHANGING P_VALID TYPE C.

    " 납품일과 증빙일 비교
    IF P_PRDAT < P_BEDAT.
      P_VALID = ''.
      MESSAGE '납품일은 증빙일과 동일하거나 이후 날짜여야 합니다.' TYPE 'I'.
    ELSE.
      P_VALID = C_X.
    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOMAIN_VALIDITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0527   text
*      -->P_LS_MODI_VALUE  text
*----------------------------------------------------------------------*
FORM CHECK_DOMAIN_VALIDITY USING  P_DOMAIN_NAME TYPE DD07V-DOMNAME
                                  P_VALUE TYPE ANY
                           CHANGING P_VALID TYPE C.

  DATA: LT_VALUES TYPE TABLE OF DD07V,
        LS_VALUE TYPE DD07V.

  DATA: LV_DOMAIN_NAME TYPE STRING.

  " 도메인 값 읽기
  SELECT * FROM DD07V
    INTO TABLE LT_VALUES
    WHERE DOMNAME = P_DOMAIN_NAME.

  " 입력 값이 도메인에 존재하는지 확인
  READ TABLE LT_VALUES WITH KEY DOMVALUE_L = P_VALUE INTO LS_VALUE.

  IF P_DOMAIN_NAME = 'ZWERKS07'.
    LV_DOMAIN_NAME = '플랜트'.
  ELSEIF P_DOMAIN_NAME = 'ZLGORT07'.
    LV_DOMAIN_NAME = '저장위치'.
  ENDIF.

  IF SY-SUBRC = 0.
    P_VALID = C_X. "유효한 값
  ELSE.
    P_VALID = ''. " 유효하지 않은 값
    MESSAGE I005 WITH LV_DOMAIN_NAME P_VALUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_AND_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATE_AND_SAVE.

  DATA: LV_INVALID    TYPE C LENGTH 1,         " 한 조건이라도 유효하지 않으면 'X'
        LV_INVALID_COUNT TYPE I VALUE 0,       " 유효하지 않은 데이터 개수
        LV_VALID_COUNT   TYPE I VALUE 0,       " 유효한 데이터 개수
        LT_INVALID_ROWS  TYPE TABLE OF TY_PO_ITEM, " 유효하지 않은 행 저장 테이블
        LT_VALID_ROWS    TYPE TABLE OF TY_PO_ITEM, " 유효한 행 저장 테이블
        LS_ROW           TYPE TY_PO_ITEM,      " 행 데이터 구조
        LV_EXISTS        TYPE C LENGTH 1.        " 자재번호 존재 여부 플래그


  " 유효성 검사
  LOOP AT GT_ALV_DATA INTO GS_ALV_ROW.

    " 유효성 초기화
    LV_INVALID = ' '.

    " 자재번호 유효성 검사 (ZMAT07에서 존재 여부 확인)
    CLEAR LV_EXISTS.
    SELECT SINGLE MATNR
      INTO LV_EXISTS
      FROM ZMAT07
      WHERE MATNR = GS_ALV_ROW-MATNR.

    IF SY-SUBRC <> 0. " 자재번호가 ZMAT07에 존재하지 않으면
      LV_INVALID = 'X'.
    ENDIF.

    " 납품일 유효성 검사
    IF GS_ALV_ROW-VALID_PRDAT <> 'X'.
      LV_INVALID = 'X'.
    ENDIF.

    " 플랜트 유효성 검사
    IF GS_ALV_ROW-VALID_WERKS <> 'X'.
      LV_INVALID = 'X'.
    ENDIF.

    " 저장위치 유효성 검사
    IF GS_ALV_ROW-VALID_LGORT <> 'X'.
      LV_INVALID = 'X'.
    ENDIF.

    " 유효하지 않은 데이터 처리
    IF LV_INVALID = 'X'.
      APPEND GS_ALV_ROW TO LT_INVALID_ROWS.
      LV_INVALID_COUNT = LV_INVALID_COUNT + 1.
    ELSE.
      " 유효한 데이터만 저장
      APPEND GS_ALV_ROW TO LT_VALID_ROWS.
      LV_VALID_COUNT = LV_VALID_COUNT + 1.
    ENDIF.

  ENDLOOP.

  " 유효하지 않은 데이터가 있는 경우
  IF LV_INVALID_COUNT > 0.
    MESSAGE |유효하지 않은 데이터 { LV_INVALID_COUNT }건이 발견되었습니다. 저장할 수 없습니다.| TYPE 'E'.
    RETURN. " 저장 프로세스 중단
  ENDIF.

  PERFORM INSERT_PO USING LT_VALID_ROWS.

  " 성공 메시지
  MESSAGE |{ LV_VALID_COUNT }건의 데이터가 성공적으로 저장되었습니다.| TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERT_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_VALID_ROWS  text
*----------------------------------------------------------------------*
FORM INSERT_PO  USING    P_VALID_ROWS TYPE STANDARD TABLE.
  CLEAR : GS_ALV_ROW.

  "구매오더번호 자동채번
  DATA: LV_EBELN TYPE ZEKKO07-EBELN.
  "품목번호(IN EKPO)
  DATA : LV_NEW_EBELP TYPE ZEKPO07-EBELP.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR                   = '01'
      OBJECT                        = 'ZEBELN07'
      QUANTITY                      = '1'
     IMPORTING
       NUMBER                        = LV_EBELN
                 .
  IF SY-SUBRC <> 0.
      MESSAGE '구매오더번호 생성 실패' TYPE 'E'.
      EXIT.
  ENDIF.

  "헤더 데이터 세팅
  CLEAR GS_SAVE_EKKO.
  GS_SAVE_EKKO-EBELN = LV_EBELN. "자동 채번된 구매오더번호
  GS_SAVE_EKKO-BUKRS = P_BUKRS. "회사 코드
  GS_SAVE_EKKO-LIFNR = P_LIFNR. "구매처 번호
  GS_SAVE_EKKO-BEDAT = P_BEDAT. "증빙일
  GS_SAVE_EKKO-EKORG = EKORG_IO. "구매조직
  GS_SAVE_EKKO-EKGRP = EKGRP_IO. "구매그룹
  GS_SAVE_EKKO-WAERS = WAERS_IO. "통화

  "헤더 데이터 테이블에 추가
  APPEND GS_SAVE_EKKO TO GT_SAVE_EKKO.

  "품목 번호 초기화
  LV_NEW_EBELP = 10.

  "아이템 데이터
  LOOP AT P_VALID_ROWS INTO GS_ALV_ROW.
    CLEAR GS_SAVE_EKPO.

    MOVE-CORRESPONDING GS_ALV_ROW TO GS_SAVE_EKPO.

    GS_SAVE_EKPO-EBELN = LV_EBELN. "구매오더번호 (헤더와 동일)

    GS_SAVE_EKPO-EBELP = LV_NEW_EBELP. " 품목번호
    LV_NEW_EBELP = LV_NEW_EBELP + 10. " 다음 품목번호 계산

    APPEND GS_SAVE_EKPO TO GT_SAVE_EKPO.
  ENDLOOP.

  "데이터베이스에 삽입
  INSERT ZEKKO07 FROM TABLE GT_SAVE_EKKO.
  INSERT ZEKPO07 FROM TABLE GT_SAVE_EKPO.

     IF SY-SUBRC = 0.
       MESSAGE '저장성공' TYPE 'I'.
     ELSE.
       MESSAGE '저장실패' TYPE 'I'.
     ENDIF.

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
        K~BUKRS        "회사코드
        K~EKGRP        "구매그룹
        K~EKORG        "구매조직
        K~LIFNR        "구매처번호
        K~BEDAT        "증빙일
        P~EBELN        "구매오더번호
        P~EBELP        "품목
        P~MATNR        "자재번호
        P~MAKTX        "자재명
        P~MENGE        "PO수량
        P~MEINS        "수량 단위
        P~NETPR        "단가 금액
        P~BPRME        "단가 단위
        P~WAERS        "통화
        P~MWSKZ        "세금코드
        P~PRDAT        "납품일
        P~WERKS        "플랜트
        P~LGORT         "저장위치
      INTO CORRESPONDING FIELDS OF TABLE GT_SEARCH_DATA
      FROM ZEKPO07 AS P
      INNER JOIN ZEKKO07 AS K
        ON P~EBELN = K~EBELN
      WHERE K~BUKRS = P_BUKRS            "회사코드 필터
        AND K~LIFNR = P_LIFNR           "구매처번호 필터
        AND P~EBELN IN S_EBELN           "구매오더번호 필터
        .

    LOOP AT GT_SEARCH_DATA INTO GS_SEARCH_DATA.
      GS_SEARCH_DATA-TOTAL_AMT = GS_SEARCH_DATA-MENGE * GS_SEARCH_DATA-NETPR.
      MODIFY GT_SEARCH_DATA FROM GS_SEARCH_DATA.
    ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT_SEARCH .
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
*&      Form  FIELD_CATALOG_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG_SEARCH .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELN'.
  GS_FIELDCAT-COLTEXT = '구매오더번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELP'.
  GS_FIELDCAT-COLTEXT = '품목'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BUKRS'.
  GS_FIELDCAT-COLTEXT = '회사코드'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EKORG'.
  GS_FIELDCAT-COLTEXT = '구매조직'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EKGRP'.
  GS_FIELDCAT-COLTEXT = '구매그룹'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LIFNR'.
  GS_FIELDCAT-COLTEXT = '구매처번호'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BEDAT'.
  GS_FIELDCAT-COLTEXT = '증빙일'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MATNR'.
  GS_FIELDCAT-COLTEXT = '자재번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MAKTX'.
  GS_FIELDCAT-COLTEXT = '자재명'.
  GS_FIELDCAT-OUTPUTLEN = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = 'PO수량'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MEINS'.
  GS_FIELDCAT-COLTEXT = '수량 단위'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'NETPR'.
  GS_FIELDCAT-COLTEXT = '단가 금액'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BPRME'.
  GS_FIELDCAT-COLTEXT = '단가 단위'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'TOTAL_AMT'.
  GS_FIELDCAT-COLTEXT = '총 금액'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-EMPHASIZE = 'X'.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MWSKZ'.
  GS_FIELDCAT-COLTEXT = '세금코드'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'PRDAT'.
  GS_FIELDCAT-COLTEXT = '납품일'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WERKS'.
  GS_FIELDCAT-COLTEXT = '플랜트'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LGORT'.
  GS_FIELDCAT-COLTEXT = '저장위치'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY_SEARCH .
CALL METHOD GC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
 EXPORTING
   IS_LAYOUT                     =  GS_LAYOUT
  CHANGING
    IT_OUTTAB                     = GT_SEARCH_DATA
    IT_FIELDCATALOG               = GT_FIELDCAT
        .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_LAYOUT_SEARCH .
   GS_LAYOUT-ZEBRA = 'X'. "라인 단위 별로 줄무늬 패턴을 설정
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_SORT_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_SORT_SEARCH .
  CLEAR : GS_SORT, GT_SORT.

    GS_SORT-SPOS = 1.
    GS_SORT-FIELDNAME = 'EBELN'. "구매오더번호
    GS_SORT-UP = 'X'.
    GS_SORT-SUBTOT = 'X'.
    APPEND GS_SORT TO GT_SORT.

    CLEAR : GS_SORT.
    GS_SORT-SPOS = 2.
    GS_SORT-FIELDNAME = 'EBELP'. "품목번호
    GS_SORT-UP = 'X'.
    APPEND GS_SORT TO GT_SORT.

ENDFORM.
