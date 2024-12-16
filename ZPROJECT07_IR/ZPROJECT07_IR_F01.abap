*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_IR_F01
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
  DATA : LV_CHECK_BLDAT TYPE C. "송장처리일 -> 입고 처리 시 필수

  IF P_EBELN IS NOT INITIAL.
    LV_CHECK_EBELN = 'X'.
  ENDIF.

  IF P_WERKS IS NOT INITIAL.
    LV_CHECK_WERKS = 'X'.
  ENDIF.

  IF P_BLDAT IS NOT INITIAL.
    LV_CHECK_BLDAT = 'X'.
  ENDIF.

  IF LV_CHECK_EBELN = '' OR LV_CHECK_WERKS = '' OR LV_CHECK_BLDAT = ''.
    MESSAGE E000.
    EXIT.
  ENDIF.

  IF P_R1 = C_X. "송장 처리
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
*&      Form  GET_PO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PO_DATA .
  " 이미 송장처리 된 데이터 조회
 PERFORM CHECK_IR.

  "구매오더 데이터 조회
  SELECT
      K~BUKRS "회사코드
      P~EBELN "구매오더번호
      P~EBELP "품목번호
      P~MATNR "자재번호
      P~MAKTX "자재명
      P~MENGE "수량
      P~BPRME "단가단위
      P~MEINS "수량단위
      P~NETPR "단가
      K~WAERS "통화
      P~WERKS "플랜트
      K~LIFNR "구매처번호
      P~MWSKZ "세금코드
    INTO CORRESPONDING FIELDS OF TABLE GT_ALV_DATA
    FROM ZEKPO07 AS P
    INNER JOIN ZEKKO07 AS K ON P~EBELN = K~EBELN
    WHERE K~EBELN = P_EBELN AND P~WERKS = P_WERKS
    " 조건: 입력된 구매오더번호, 플랜트
    .

    LOOP AT GT_ALV_DATA INTO GS_ALV_DATA.
      READ TABLE GT_RECEIVED_GOODS WITH KEY
        EBELN = GS_ALV_DATA-EBELN
        EBELP = GS_ALV_DATA-EBELP
        MATNR = GS_ALV_DATA-MATNR
        TRANSPORTING NO FIELDS.

      IF SY-SUBRC = 0.
        DELETE GT_ALV_DATA WHERE
          EBELN = GS_ALV_DATA-EBELN AND
          EBELP = GS_ALV_DATA-EBELP AND
          MATNR = GS_ALV_DATA-MATNR.
      ENDIF.
    ENDLOOP.

    LOOP AT GT_ALV_DATA INTO GS_ALV_DATA.
      DATA : LV_TAX_AMOUNT TYPE P DECIMALS 2. "세액

      GS_ALV_DATA-DMBTR = GS_ALV_DATA-NETPR * GS_ALV_DATA-MENGE. "공급가액 = 단가 * 수량

      PERFORM CALCULATE_TAX USING GS_ALV_DATA-DMBTR GS_ALV_DATA-MWSKZ CHANGING LV_TAX_AMOUNT.

      GS_ALV_DATA-MWSTS = LV_TAX_AMOUNT. "세액
      GS_ALV_DATA-WRBTR = GS_ALV_DATA-DMBTR + GS_ALV_DATA-MWSTS. "금액 = 공급가액 + 세액

       MODIFY GT_ALV_DATA FROM GS_ALV_DATA INDEX SY-TABIX.
    ENDLOOP.

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

IF P_R1 = C_X. "송장 생성

  "송장 처리 체크 박스
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'L_CHECK'.
  GS_FIELDCAT-COLTEXT = '체크'.
  GS_FIELDCAT-OUTPUTLEN = 3.
  GS_FIELDCAT-EDIT = 'X'.
  GS_FIELDCAT-CHECKBOX = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "회사코드
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BUKRS'.
  GS_FIELDCAT-COLTEXT = '회사코드'.
  GS_FIELDCAT-OUTPUTLEN = 8.
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

  "단가
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'NETPR'.
  GS_FIELDCAT-COLTEXT = '단가'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "수량
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = '수량'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "공급가액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'DMBTR'.
  GS_FIELDCAT-COLTEXT = '공급가액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "세액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MWSTS'.
  GS_FIELDCAT-COLTEXT = '세액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "금액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WRBTR'.
  GS_FIELDCAT-COLTEXT = '금액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "통화
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "세금코드
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MWSKZ'.
  GS_FIELDCAT-COLTEXT = '세금코드'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매처번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'LIFNR'.
  GS_FIELDCAT-COLTEXT = '구매처번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ELSEIF P_R2 = C_X. "송장 조회

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'L_CHECK'.
  GS_FIELDCAT-COLTEXT = '체크'.
  GS_FIELDCAT-OUTPUTLEN = 3.
  GS_FIELDCAT-EDIT = 'X'.
  GS_FIELDCAT-CHECKBOX = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "송장문서번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BELNR'.
  GS_FIELDCAT-COLTEXT = '송장문서번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "송장연도
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'GJAHR'.
  GS_FIELDCAT-COLTEXT = '송장연도'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "송장아이템번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BUZEI'.
  GS_FIELDCAT-COLTEXT = '송장아이템번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매오더번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELN'.
  GS_FIELDCAT-COLTEXT = '구매오더번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "구매오더 아이템번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'EBELP'.
  GS_FIELDCAT-COLTEXT = '구매오더 아이템번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "자재번호
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MATNR'.
  GS_FIELDCAT-COLTEXT = '자재번호'.
  GS_FIELDCAT-OUTPUTLEN = 10.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "회사코드
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'BUKRS'.
  GS_FIELDCAT-COLTEXT = '회사코드'.
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

  "단가
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'NETPR'.
  GS_FIELDCAT-COLTEXT = '단가'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "수량
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = '수량'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "공급가액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'DMBTR'.
  GS_FIELDCAT-COLTEXT = '공급가액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "세액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MWSTS'.
  GS_FIELDCAT-COLTEXT = '세액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 8.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "금액
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WRBTR'.
  GS_FIELDCAT-COLTEXT = '금액'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  GS_FIELDCAT-OUTPUTLEN = 15.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "통화
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-OUTPUTLEN = 4.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  "세금코드
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'MWSKZ'.
  GS_FIELDCAT-COLTEXT = '세금코드'.
  GS_FIELDCAT-OUTPUTLEN = 8.
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
    GS_SORT-FIELDNAME = 'BELNR'. "송장문서번호
    GS_SORT-SUBTOT = 'X'.
    GS_SORT-UP = 'X'.
    APPEND GS_SORT TO GT_SORT.

    CLEAR : GS_SORT.
    GS_SORT-SPOS = 2.
    GS_SORT-FIELDNAME = 'BUZEI'. "송장 아이템 번호
    GS_SORT-UP = 'X'.
    APPEND GS_SORT TO GT_SORT.
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
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV_DATA  text
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
*&      Form  CHECK_IR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_IR . "송장처리가 된 데이터 조회
  CLEAR : GT_RECEIVED_GOODS.

  SELECT DISTINCT
    R~BELNR   "송장문서번호
    R~GJAHR   "송장연도
    R~BUZEI   "송장아이템번호
    R~EBELN   "구매오더번호
    R~EBELP   "구매오더 아이템번호
    R~MATNR   "자재번호
  INTO CORRESPONDING FIELDS OF TABLE GT_RECEIVED_GOODS
  FROM ZRSEG07 AS R
  INNER JOIN ZEKPO07 AS P
    ON R~EBELN = P~EBELN
  WHERE R~EBELN = P_EBELN
    AND P~WERKS = P_WERKS " 플랜트 조건
    AND R~DEL_FLAG = ''. " 삭제되지 않은 데이터

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_TAX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ALV_DATA_DMBTR  text
*      -->P_GS_ALV_DATA_MWSKZ  text
*      <--P_LV_TAX_AMOUNT  text
*----------------------------------------------------------------------*
FORM CALCULATE_TAX  USING    P_ALV_DATA_DMBTR  "공급가액
                             P_ALV_DATA_MWSKZ  "세금코드
                    CHANGING P_TAX_AMOUNT.     "세액


  CONSTANTS: LC_TAX_RATE_10 TYPE P DECIMALS 2 VALUE '0.10',
             LC_TAX_RATE_0  TYPE P DECIMALS 2 VALUE '0.00'.

  CASE P_ALV_DATA_MWSKZ.
    WHEN 'V1'. "매입일반 10%
      P_TAX_AMOUNT = P_ALV_DATA_DMBTR * LC_TAX_RATE_10.
    WHEN 'V2'. "매입계산 0%
      P_TAX_AMOUNT = P_ALV_DATA_DMBTR * LC_TAX_RATE_0.
    WHEN 'V3'. "매입영세 0%
      P_TAX_AMOUNT = 0. "세액 없음
    WHEN 'V4'.
      P_TAX_AMOUNT = P_ALV_DATA_DMBTR * LC_TAX_RATE_10. " 계산하되 공제 불가로 표시
    WHEN 'V5'.
      P_TAX_AMOUNT = P_ALV_DATA_DMBTR * LC_TAX_RATE_10. " 고정자산 처리
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILTER_CHECKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILTER_CHECKED .
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

  PERFORM INSERT_IR_DATA USING LT_SELECTED. "송장 테이블에 값 넣기

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERT_IR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_SELECTED  text
*----------------------------------------------------------------------*
FORM INSERT_IR_DATA  USING    P_SELECTED TYPE STANDARD TABLE.
  DATA : LV_BELNR TYPE ZRBKP07-BELNR. "송장문서번호
  DATA : LV_GJAHR TYPE ZRBKP07-GJAHR. "송장연도
  DATA : LV_BUZEI TYPE ZRSEG07-BUZEI VALUE 10. "송장 아이템 번호
  DATA : LV_SGTXT TYPE ZRSEG07-SGTXT. "텍스트
  "헤더에 넣을
  DATA : LV_WRBTR TYPE ZRBKP07-WRBTR. "송장 전체 금액: 공급가액 + 세액
  DATA : LV_MWSTS TYPE ZRBKP07-MWSTS.  "송장 세액

  "송장문서번호 자동채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '02'
      object      = 'ZBELNR07'
    IMPORTING
      number      = LV_BELNR.

  IF sy-subrc <> 0.
    MESSAGE '송장문서번호 생성 실패' TYPE 'E'.
    EXIT.
  ENDIF.

  LV_GJAHR = P_BLDAT+0(4). "입력받은 송장처리일의 연도 추출

  "헤더 테이블
  CLEAR : GS_IR_HEADER.
  GS_IR_HEADER-BELNR = LV_BELNR. "송장 문서 번호
  GS_IR_HEADER-GJAHR = LV_GJAHR. "송장연도
  GS_IR_HEADER-BLDAT = P_BLDAT. "송장문서날짜
  GS_IR_HEADER-BUDAT = P_BLDAT. "송장입력날짜

  "회사코드
  SELECT SINGLE BUKRS INTO GS_IR_HEADER-BUKRS
  FROM ZEKKO07 AS K
  WHERE K~EBELN = P_EBELN.

  "공급업체코드(구매처코드)
  SELECT SINGLE LIFNR INTO GS_IR_HEADER-LIFNR
  FROM ZEKKO07 AS K
  WHERE K~EBELN = P_EBELN.

  "통화
  SELECT SINGLE WAERS INTO GS_IR_HEADER-WAERS
  FROM ZEKKO07 AS K
  WHERE K~EBELN = P_EBELN.

  "세금코드
  SELECT SINGLE MWSKZ INTO GS_IR_HEADER-MWSKZ
  FROM ZEKPO07 AS P
  WHERE P~EBELN = P_EBELN AND P~WERKS = P_WERKS.

  "지급조건
   SELECT SINGLE ZTERM INTO GS_IR_HEADER-ZTERM
   FROM ZLFB107 AS L
   WHERE L~LIFNR = GS_IR_HEADER-LIFNR.

  CLEAR : GS_IR_ITEM.
  CLEAR  : GS_ALV_DATA.

  LOOP AT P_SELECTED INTO GS_ALV_DATA.
    CLEAR : GS_IR_ITEM.

    MOVE-CORRESPONDING GS_ALV_DATA TO GS_IR_ITEM.
    GS_IR_ITEM-BELNR = LV_BELNR. "송장 문서 번호
    GS_IR_ITEM-GJAHR = LV_GJAHR. "송장 연도
    GS_IR_ITEM-BUZEI = LV_BUZEI. "송장 아이템 번호
    LV_BUZEI = LV_BUZEI + 10.    "다음 송장 아이템 번호 지정
    GS_IR_ITEM-SHKZG = 'H'.      "대변
    GS_IR_ITEM-DMBTR = GS_ALV_DATA-DMBTR. "공급가액(단가*수량)
    GS_IR_ITEM-MWSTS = GS_ALV_DATA-MWSTS. "아이템 세액
    GS_IR_ITEM-WRBTR = GS_ALV_DATA-WRBTR. "공급가액 + 세액

    CONCATENATE P_EBELN '송장처리' INTO LV_SGTXT. "텍스트
    GS_IR_ITEM-SGTXT = LV_SGTXT.

    LV_MWSTS = LV_MWSTS + GS_IR_ITEM-MWSTS.   "송장 전체 세액에 포함
    LV_WRBTR = LV_WRBTR + GS_IR_ITEM-WRBTR. "송장 전체 금액에 포함

    APPEND GS_IR_ITEM TO GT_IR_ITEM.
  ENDLOOP.

  "헤더 구조체에 값 넣기
  GS_IR_HEADER-MWSTS = LV_MWSTS. "송장 총 금액
  GS_IR_HEADER-WRBTR = LV_WRBTR. "송장 세액

  APPEND GS_IR_HEADER TO GT_IR_HEADER.

  "데이터 저장
  INSERT ZRBKP07 FROM TABLE GT_IR_HEADER.
  INSERT ZRSEG07 FROM TABLE GT_IR_ITEM.

  IF SY-SUBRC = 0.
    MESSAGE '송장 처리 완료되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '송장 처리 중 오류가 발생했습니다.' TYPE 'E'.
  ENDIF.

  PERFORM REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_IR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_IR_DATA .

  "송장 처리 된 데이터를 조회해서 ALV에 출력시키기
  SELECT DISTINCT
    R~BELNR   "송장문서번호
    R~GJAHR   "송장연도
    R~BUZEI   "송장아이템번호
    R~EBELN   "구매오더번호
    R~EBELP   "구매오더 아이템번호
    R~MATNR   "자재번호
    R~BUKRS   "회사코드
    R~MATNR   "자재번호
    P~MAKTX   "자재명
    P~NETPR   "단가
    P~MENGE   "수량
    R~DMBTR   "공급가액(단가*수량)
    R~MWSTS   "세액
    R~WRBTR   "금액(공급가액 + 세액)
    R~WAERS   "통화
    R~MWSKZ   "세금코드
  INTO CORRESPONDING FIELDS OF TABLE GT_RECEIVED_GOODS
  FROM ZRSEG07 AS R
  INNER JOIN ZEKPO07 AS P
    ON R~EBELN = P~EBELN AND R~EBELP = P~EBELP
  WHERE R~EBELN = P_EBELN
    AND P~WERKS = P_WERKS " 플랜트 조건
    AND R~DEL_FLAG = ''. " 삭제되지 않은 데이터

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CANC_CHECKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANC_CHECKED .
  "구조체와 테이블 선언
  DATA : LS_SELECTED LIKE GS_RECEIVED_GOODS.
  DATA : LT_SELECTED LIKE TABLE OF GS_RECEIVED_GOODS.
  DATA : LV_BELNR LIKE ZRBKP07-REF_BELNR. "취소 헤더테이블 송장문서번호
  DATA : LV_SGTXT TYPE ZRSEG07-SGTXT. "텍스트

  "송장처리된 것들을 반복문으로 돌면서 체크한 것들은 LS_SELECTED에 추가
  LOOP AT GT_RECEIVED_GOODS INTO LS_SELECTED.
    IF LS_SELECTED-L_CHECK = 'X'.
      APPEND LS_SELECTED TO LT_SELECTED.
    ENDIF.
  ENDLOOP.

  " 선택 항목이 없는 경우 에러 메시지
  IF LT_SELECTED IS INITIAL.
    MESSAGE '선택된 항목이 없습니다.' TYPE 'E'.
    EXIT.
  ENDIF.

  " 송장별로 그룹화하여 헤더 데이터 생성
  SORT LT_SELECTED BY BELNR.

  LOOP AT LT_SELECTED INTO LS_SELECTED.
    " 송장 문서번호가 변경될 때마다 새로운 헤더 데이터 생성
    AT NEW BELNR.
      " 송장문서번호 자동채번 (취소 송장 문서)
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '02'
          object      = 'ZBELNR07'
        IMPORTING
          number      = LV_BELNR.

      IF sy-subrc <> 0.
        MESSAGE '송장문서번호 생성 실패' TYPE 'E'.
        EXIT.
      ENDIF.

      " 헤더 테이블 데이터 초기화 및 설정
      CLEAR : GS_IR_HEADER.
      GS_IR_HEADER-BELNR = LV_BELNR. "새로운 송장문서번호
      GS_IR_HEADER-GJAHR = SY-DATUM(4). "송장연도
      GS_IR_HEADER-BLDAT = SY-DATUM.    "송장문서날짜
      GS_IR_HEADER-BUDAT = SY-DATUM.    "송장입력날짜
      GS_IR_HEADER-DEL_FLAG = 'C'.      "취소 플래그
      GS_IR_HEADER-REF_BELNR = LS_SELECTED-BELNR. "참조 송장문서번호

      " 구매처번호
      SELECT SINGLE LIFNR INTO GS_IR_HEADER-LIFNR
      FROM ZRBKP07 AS H
      WHERE H~BELNR = LS_SELECTED-BELNR.

      " 지급조건
      SELECT SINGLE ZTERM INTO GS_IR_HEADER-ZTERM
      FROM ZLFB107 AS L
      WHERE L~LIFNR = GS_IR_HEADER-LIFNR.

      "회사코드
      SELECT SINGLE BUKRS INTO GS_IR_HEADER-BUKRS
      FROM ZRBKP07 AS R
      WHERE R~BELNR = GS_IR_HEADER-REF_BELNR.

      "통화
      SELECT SINGLE WAERS INTO GS_IR_HEADER-WAERS
      FROM ZRBKP07 AS R
      WHERE R~BELNR = GS_IR_HEADER-REF_BELNR.

      "세금코드
      SELECT SINGLE MWSKZ INTO GS_IR_HEADER-MWSKZ
      FROM ZRBKP07 AS R
      WHERE R~BELNR = GS_IR_HEADER-REF_BELNR.
    ENDAT.

    " 아이템 테이블 플래그 변경
    UPDATE ZRSEG07
      SET DEL_FLAG = 'X'
      WHERE EBELN = LS_SELECTED-EBELN AND BUZEI = LS_SELECTED-BUZEI.

    GS_IR_HEADER-WRBTR = GS_IR_HEADER-WRBTR - LS_SELECTED-WRBTR. "송장 총 금액 (음수)
    GS_IR_HEADER-MWSTS = GS_IR_HEADER-MWSTS - LS_SELECTED-MWSTS. "송장 세액 (음수)

    " 헤더에 대한 플래그 변경 확인
    PERFORM HEADER_DEL_CHECK USING LS_SELECTED-BELNR.

    " 아이템 데이터 생성
    CLEAR : GS_IR_ITEM.
    MOVE-CORRESPONDING LS_SELECTED TO GS_IR_ITEM.

    GS_IR_ITEM-BELNR = LV_BELNR. "새로운 송장문서번호
    GS_IR_ITEM-SHKZG = 'S'.      "취소는 차변에 해당
    GS_IR_ITEM-MENGE = LS_SELECTED-MENGE * -1. "수량
    GS_IR_ITEM-DMBTR = LS_SELECTED-DMBTR * -1. "공급가액
    GS_IR_ITEM-MWSTS = LS_SELECTED-MWSTS * -1. "아이템 세액
    GS_IR_ITEM-WRBTR = LS_SELECTED-WRBTR * -1. "세금을 포함한 전체 금액
    GS_IR_ITEM-DEL_FLAG = 'C'.                "삭제 플래그 C
    GS_IR_ITEM-REF_BELNR = LS_SELECTED-BELNR. "참조 송장문서번호
    GS_IR_ITEM-MEINS = 'EA'.
    GS_IR_ITEM-BPRME = 'EA'.

    CONCATENATE LS_SELECTED-EBELN '송장취소' INTO LV_SGTXT.
    GS_IR_ITEM-SGTXT = LV_SGTXT.

    APPEND GS_IR_ITEM TO GT_IR_ITEM.

    " 헤더 데이터 추가
    AT END OF BELNR.
      APPEND GS_IR_HEADER TO GT_IR_HEADER.
    ENDAT.
  ENDLOOP.

  " 데이터베이스 삽입
  INSERT ZRBKP07 FROM TABLE GT_IR_HEADER. "헤더 테이블
  INSERT ZRSEG07 FROM TABLE GT_IR_ITEM.   "아이템 테이블

  IF SY-SUBRC = 0.
    MESSAGE '송장처리가 취소되었습니다.' TYPE 'I'.
  ELSE.
    MESSAGE '송장 테이블에서 데이터 삭제 실패' TYPE 'E'.
  ENDIF.

  PERFORM REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HEADER_DEL_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_SELECTED_MBLNR  text
FORM HEADER_DEL_CHECK USING P_BELNR.
  DATA: LV_COUNT TYPE I.

  " DEL_FLAG가 'X'가 아닌 항목의 개수 확인
  SELECT COUNT(*)
    INTO LV_COUNT
    FROM ZRSEG07
    WHERE BELNR = P_BELNR AND DEL_FLAG <> 'X'.

  " 모든 항목의 DEL_FLAG가 'X'라면, 헤더 테이블의 DEL_FLAG를 업데이트
  IF LV_COUNT = 0.
    UPDATE ZRBKP07
      SET DEL_FLAG = 'X'
      WHERE BELNR = P_BELNR.

    " SY-SUBRC 확인
    IF SY-SUBRC <> 0.
      MESSAGE '헤더 DEL_FLAG 업데이트 실패' TYPE 'E'.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.
