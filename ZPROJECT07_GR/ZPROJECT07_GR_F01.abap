*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_GR_F01
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
    IF SCREEN-GROUP1 = 'M1'.
      IF P_R2 = C_X.
        SCREEN-ACTIVE = '0'.
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
  DATA : LV_CHECK_EBELN TYPE C. "구매오더 -> 필수
  DATA : LV_CHECK_WERKS TYPE C. "플랜트 -> 필수
  DATA : LV_CHECK_BLDAT TYPE C. "입고처리일 -> 입고 처리 시 필수

  IF P_EBELN IS NOT INITIAL.
    LV_CHECK_EBELN = 'X'.
  ENDIF.

  IF P_WERKS IS NOT INITIAL.
    LV_CHECK_WERKS = 'X'.
  ENDIF.

  IF P_BLDAT IS NOT INITIAL.
    LV_CHECK_BLDAT = 'X'.
  ENDIF.

   IF LV_CHECK_EBELN = '' OR LV_CHECK_WERKS = ''.
    MESSAGE E000.
    EXIT.
  ENDIF.

  IF P_R1 = C_X. "입고 처리
    IF LV_CHECK_BLDAT = ''. "입고 처리일 값 들어왔는지 체크
      MESSAGE E000.
      EXIT.
     ENDIF.

    "입고 처리 시에 PO번호 정합성체크 필수
     PERFORM CHECK_EBELN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_EBELN . "사용자에게 입력받은 구매오더 번호가 ZEKKO07에 실제로 존재하는지 정합성 체크

  "ZEKKO07 테이블에서 구매 오더 헤더 정보 읽기
  SELECT SINGLE *
    INTO GS_EKKO
    FROM ZEKKO07
    WHERE EBELN = P_EBELN.

  IF SY-SUBRC <> 0.
    MESSAGE '입력한 PO번호에 대한 데이터가 존재하지 않습니다.' TYPE 'E'.
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
  "ALV 도킹 컨테이너 생성
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

  "그리드 생성
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

IF P_R1 = C_X.
  "입고체크박스
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'L_CHECK'.
  GS_FIELDCAT-COLTEXT = '체크'.
  GS_FIELDCAT-OUTPUTLEN = 3.
  GS_FIELDCAT-EDIT = 'X'.
  GS_FIELDCAT-CHECKBOX = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매오더번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELN'.
  GS_FIELDCAT-COLTEXT = '구매오더번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "품목번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELP'.
  GS_FIELDCAT-COLTEXT = '품목'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매처번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LIFNR'.
  GS_FIELDCAT-COLTEXT = '구매처번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "증빙일
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BEDAT'.
  GS_FIELDCAT-COLTEXT = '증빙일'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "자재번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MATNR'.
  GS_FIELDCAT-COLTEXT = '자재번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "자재명
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MAKTX'.
  GS_FIELDCAT-COLTEXT = '자재명'.
  GS_FIELDCAT-OUTPUTLEN = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "수량
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = '수량'.
*  GS_FIELDCAT-EDIT = 'X'. "수량 부분입고 ..
  GS_FIELDCAT-OUTPUTLEN = 4.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "단위
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MEINS'.
  GS_FIELDCAT-COLTEXT = '단위'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "단가
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'NETPR'.
  GS_FIELDCAT-COLTEXT = '단가'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "통화
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "납품일
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'PRDAT'.
  GS_FIELDCAT-COLTEXT = '납품일'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "플랜트
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WERKS'.
  GS_FIELDCAT-COLTEXT = '플랜트'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "저장위치
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LGORT'.
  GS_FIELDCAT-COLTEXT = '저장위치'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ELSEIF P_R2 = C_X.
  "취소체크박스
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'L_CHECK'.
  GS_FIELDCAT-COLTEXT = '체크'.
  GS_FIELDCAT-OUTPUTLEN = 3.
  GS_FIELDCAT-EDIT = 'X'.
  GS_FIELDCAT-CHECKBOX = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "입고문서번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MBLNR'.
  GS_FIELDCAT-COLTEXT = '입고문서번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  GS_FIELDCAT-EMPHASIZE = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "회계연도
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MJAHR'.
  GS_FIELDCAT-COLTEXT = '회계연도'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "전표유형
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BLART'.
  GS_FIELDCAT-COLTEXT = '전표유형'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "증빙일
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BLDAT'.
  GS_FIELDCAT-COLTEXT = '증빙일'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "전기일
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BUDAT'.
  GS_FIELDCAT-COLTEXT = '전기일'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매오더번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELN'.
  GS_FIELDCAT-COLTEXT = '구매오더번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "아이템번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'ZEILE'.
  GS_FIELDCAT-COLTEXT = '아이템번호'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "자재번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MATNR'.
  GS_FIELDCAT-COLTEXT = '자재번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "플랜트
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WERKS'.
  GS_FIELDCAT-COLTEXT = '플랜트'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "저장위치
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LGORT'.
  GS_FIELDCAT-COLTEXT = '저장위치'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매처번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LIFNR'.
  GS_FIELDCAT-COLTEXT = '구매처번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "수량
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = '수량'.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "단위
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MEINS'.
  GS_FIELDCAT-COLTEXT = '단위'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "금액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'DMBTR'.
  GS_FIELDCAT-COLTEXT = '금액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  GS_FIELDCAT-DO_SUM = 'X'. "합계 표기
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "통화
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "회사코드
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BUKRS'.
  GS_FIELDCAT-COLTEXT = '회사코드'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "회계연도
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'GJAHR'.
  GS_FIELDCAT-COLTEXT = '회계연도'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "전표번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BELNR'.
  GS_FIELDCAT-COLTEXT = '전표번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "차대변
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'SHKZG'.
  GS_FIELDCAT-COLTEXT = '차대변'.
  GS_FIELDCAT-OUTPUTLEN = 5.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDIF.

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
  GS_LAYOUT-ZEBRA = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY USING P_ALV_DATA TYPE STANDARD TABLE.
  CALL METHOD GC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      I_STRUCTURE_NAME              =
*      IS_VARIANT                    =
*      I_SAVE                        =
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = P_ALV_DATA
      IT_FIELDCATALOG               = GT_FIELDCAT
      IT_SORT                       = GT_SORT
*      IT_FILTER                     =
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

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CALL METHOD GC_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_PO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PO_DATA .
  " 입고된 데이터 조회
  PERFORM CHECK_STOCK.

  " 구매오더 데이터 조회
  SELECT
      P~EBELN "구매오더번호
      P~EBELP "품목번호
      K~LIFNR "구매처번호
      K~BEDAT "증빙일
      P~MATNR "자재번호
      P~MAKTX "자재명
      P~MENGE "수량
      P~MEINS "단위
      P~NETPR "단가
      K~WAERS "통화
      P~PRDAT "납품일
      P~WERKS "플랜트
      P~LGORT "저장위치
      K~BUKRS  "회사코드
    INTO CORRESPONDING FIELDS OF TABLE GT_ALV_DATA
    FROM ZEKPO07 AS P
    INNER JOIN ZEKKO07 AS K ON P~EBELN = K~EBELN
    WHERE K~EBELN = P_EBELN  " 조건: 입력된 구매오더번호
    .


  "GT_STOCK의 데이터를 기준으로 GT_ALV_DATA 필터링
    LOOP AT GT_ALV_DATA INTO GS_ALV_DATA.
      READ TABLE GT_STOCK WITH KEY MATNR = GS_ALV_DATA-MATNR TRANSPORTING NO FIELDS.

      IF SY-SUBRC = 0.
        DELETE GT_ALV_DATA WHERE MATNR = GS_ALV_DATA-MATNR.
      ENDIF.

    ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILTER_CHECKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILTER_CHECKED.
  " 구조체와 테이블 선언
  DATA : LS_SELECTED LIKE GS_ALV_DATA.
  DATA : LT_SELECTED LIKE TABLE OF GS_ALV_DATA.

  " 체크된 데이터 필터링
  LOOP AT GT_ALV_DATA INTO LS_SELECTED.
    IF LS_SELECTED-L_CHECK = 'X'.
      APPEND LS_SELECTED TO LT_SELECTED.
    ENDIF.
  ENDLOOP.

  " 선택 항목이 없는 경우 에러 메시지
  IF LT_SELECTED IS INITIAL.
    MESSAGE '선택된 항목이 없습니다.' TYPE 'E'.
    EXIT.
  ENDIF.

  " LT_SELECTED -> 체크된 데이터 값들을 가짐

  PERFORM INSERT_GR_DATA USING LT_SELECTED. "입고 테이블에 값 넣기

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



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERT_GR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_SELECTED  text
*----------------------------------------------------------------------*
FORM INSERT_GR_DATA  USING    P_SELECTED TYPE STANDARD TABLE.
  DATA : LV_MBLNR TYPE ZMKPF07-MBLNR. "입고문서번호
  DATA : LV_MJAHR TYPE ZMKPF07-MJAHR. "회계연도
  DATA : LV_ZEILE TYPE ZMSEG07-ZEILE VALUE 10. "아이템 번호 초기값
  DATA : LV_BELNR TYPE ZMSEG07-BELNR. "전표번호

  " 입고문서번호 자동채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZMBLNR07'
    IMPORTING
      number      = LV_MBLNR.

  IF sy-subrc <> 0.
    MESSAGE '입고문서번호 생성 실패' TYPE 'E'.
    EXIT.
  ENDIF.

  "전표번호 자동채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZBELNR07'
    IMPORTING
      number      = LV_BELNR.

  IF sy-subrc <> 0.
    MESSAGE '전표번호 생성 실패' TYPE 'E'.
    EXIT.
  ENDIF.

  LV_MJAHR = P_BLDAT+0(4). "입력받은 입고처리일의 연도 추출

  "헤더 테이블
  CLEAR : GS_GR_HEADER.
  GS_GR_HEADER-MBLNR = LV_MBLNR. "입고문서번호
  GS_GR_HEADER-MJAHR = LV_MJAHR. "회계연도
  GS_GR_HEADER-BLART = 'WE'.     "전표유형(입고전표)
  GS_GR_HEADER-BLDAT = P_BLDAT.  "증빙일
  GS_GR_HEADER-BUDAT = P_BLDAT.  "전기일

  APPEND GS_GR_HEADER TO GT_GR_HEADER.

  "아이템 테이블
  CLEAR : GS_GR_ITEM.
  CLEAR : GS_ALV_DATA.
  LOOP AT P_SELECTED INTO GS_ALV_DATA.
    CLEAR : GS_GR_ITEM.

    MOVE-CORRESPONDING GS_ALV_DATA TO GS_GR_ITEM.
    GS_GR_ITEM-WERKS = P_WERKS.  "입력받은 플랜트 값으로 넣기
    GS_GR_ITEM-MBLNR = LV_MBLNR. "입고문서번호
    GS_GR_ITEM-MJAHR = LV_MJAHR. "회계연도
    GS_GR_ITEM-GJAHR = LV_MJAHR. "회계연도(전기일기준)
    GS_GR_ITEM-ZEILE = LV_ZEILE. "아이템 번호 설정
    LV_ZEILE = LV_ZEILE + 10. "다음 아이템 번호
    GS_GR_ITEM-SHKZG = 'S'. "재고 증가 -> S(차변)
    GS_GR_ITEM-DMBTR = GS_ALV_DATA-MENGE * GS_ALV_DATA-NETPR. "금액 계산
    GS_GR_ITEM-BELNR = LV_BELNR. "전표번호

    APPEND GS_GR_ITEM TO GT_GR_ITEM.
  ENDLOOP.

*  BREAK-POINT.

  "자재마스터에 데이터 변경
  LOOP AT P_SELECTED INTO GS_ALV_DATA.
    UPDATE ZMAT07
    SET MENGE = MENGE + GS_ALV_DATA-MENGE
    WHERE MATNR = GS_ALV_DATA-MATNR AND WERKS = GS_ALV_DATA-WERKS AND LGORT = GS_ALV_DATA-LGORT.
  ENDLOOP.

  " 데이터 저장
  INSERT ZMKPF07 FROM TABLE GT_GR_HEADER.
  INSERT ZMSEG07 FROM TABLE GT_GR_ITEM.

  IF SY-SUBRC = 0.
    MESSAGE '입고 처리 완료되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '입고 처리 중 오류가 발생했습니다.' TYPE 'E'.
  ENDIF.

  PERFORM REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_GR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_GR_DATA .
  "입고된 데이터를 조회해서 ALV에 출력시키기
  SELECT
    P~MBLNR P~MJAHR P~BLART P~BLDAT P~BUDAT
    M~EBELN M~ZEILE M~MATNR M~WERKS M~LGORT M~LIFNR M~WAERS M~MENGE M~MEINS M~BUKRS M~GJAHR M~BELNR M~SHKZG M~DMBTR
  INTO CORRESPONDING FIELDS OF TABLE GT_STOCK
  FROM ZMKPF07 AS P
  INNER JOIN ZMSEG07 AS M ON P~MBLNR = M~MBLNR
  WHERE M~EBELN = P_EBELN AND M~WERKS = P_WERKS
        AND M~DEL_FLAG <> 'X'
  .

* BREAK-POINT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_STOCK . "입고된 데이터 조회 (구매오더번호가 동일한)
  SELECT
    M~EBELN "구매오더번호
    M~MBLNR "입고문서번호
    M~ZEILE "아이템번호
    M~MATNR "자재번호
    M~BELNR "전표번호
  INTO CORRESPONDING FIELDS OF TABLE GT_STOCK
  FROM ZMSEG07 AS M
  WHERE M~EBELN = P_EBELN AND
        M~DEL_FLAG <> 'X'.
  .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CANC_CHECKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANC_CHECKED . "취소할 입고데이터 체크
  "구조체와 테이블 선언
  DATA : LS_SELECTED LIKE GS_STOCK.
  DATA : LT_SELECTED LIKE TABLE OF GS_STOCK.

  LOOP AT GT_STOCK INTO LS_SELECTED.
    IF LS_SELECTED-L_CHECK = 'X'.
      APPEND LS_SELECTED TO LT_SELECTED.
    ENDIF.
  ENDLOOP.

    " 선택 항목이 없는 경우 에러 메시지
  IF LT_SELECTED IS INITIAL.
    MESSAGE '선택된 항목이 없습니다.' TYPE 'E'.
    EXIT.
  ENDIF.

  "LT_SELECTED -> 입고 취소할 데이터들의 값들을 가짐

  " 입고 테이블에서 삭제플래그 변경
  LOOP AT LT_SELECTED INTO LS_SELECTED.
*    DELETE FROM ZMSEG07 WHERE
*      MBLNR = LS_SELECTED-MBLNR AND
*      MATNR = LS_SELECTED-MATNR.

    UPDATE ZMSEG07
    SET DEL_FLAG = 'X'
    WHERE MBLNR = LS_SELECTED-MBLNR AND
          MATNR = LS_SELECTED-MATNR.

    PERFORM HEADER_DEL_CHECK USING LS_SELECTED-MBLNR.
  ENDLOOP.

  "자재마스터에 데이터 변경
  LOOP AT LT_SELECTED INTO LS_SELECTED.
    UPDATE ZMAT07
    SET MENGE = MENGE - LS_SELECTED-MENGE
    WHERE MATNR = LS_SELECTED-MATNR AND WERKS = LS_SELECTED-WERKS AND LGORT = LS_SELECTED-LGORT.
  ENDLOOP.

   IF SY-SUBRC = 0.
      MESSAGE '입고가 취소되었습니다.' TYPE 'I'.
    ELSE.
      MESSAGE '입고 테이블에서 데이터 삭제 실패' TYPE 'E'.
    ENDIF.

  PERFORM REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HEADER_DEL_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HEADER_DEL_CHECK USING P_MBLNR.
   DATA : LV_ITEM_COUNT TYPE I.
   DATA : LV_DEL_COUNT TYPE I.

   SELECT COUNT(*) INTO LV_ITEM_COUNT
     FROM ZMSEG07
     WHERE MBLNR = P_MBLNR.

   SELECT COUNT(*) INTO LV_DEL_COUNT
     FROM ZMSEG07
     WHERE MBLNR = P_MBLNR AND DEL_FLAG = 'X'.

   IF LV_ITEM_COUNT = LV_DEL_COUNT.
     UPDATE ZMKPF07
       SET DEL_FLAG = 'X'
       WHERE MBLNR = P_MBLNR.

     IF SY-SUBRC <> 0.
       MESSAGE '헤더 업데이트 중 오류 발생' TYPE 'E'.
     ENDIF.
   ENDIF.

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

  IF P_R1 = C_X. "생성
    GS_SORT-SPOS = 1.
    GS_SORT-FIELDNAME = 'EBELN'. "구매오더번호
    GS_SORT-UP = 'X'.
    APPEND GS_SORT TO GT_SORT.

    CLEAR : GS_SORT.
    GS_SORT-SPOS = 2.
    GS_SORT-FIELDNAME = 'EBELP'. "품목번호
    GS_SORT-UP = 'X'.
    APPEND GS_SORT TO GT_SORT.

  ELSEIF P_R2 = C_X. "조회
    GS_SORT-SPOS = 1.
    GS_SORT-FIELDNAME = 'MBLNR'. "입고문서번호
    GS_SORT-UP = 'X'.
    GS_SORT-SUBTOT = 'X'.
    APPEND GS_SORT TO GT_SORT.

    CLEAR : GS_SORT.
    GS_SORT-SPOS = 2.
    GS_SORT-FIELDNAME = 'ZEILE'. "아이템번호
    GS_SORT-UP = 'X'.
    APPEND GS_SORT TO GT_SORT.

  ENDIF.


ENDFORM.
