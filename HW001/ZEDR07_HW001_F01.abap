*&---------------------------------------------------------------------*
*&  Include           ZEDR07_HW001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATE .
    "주문일자 세팅
  IF S_ZJDATE[] IS INITIAL.
    CONCATENATE SY-DATUM(4) '01' '01' INTO S_ZJDATE-LOW.
    CONCATENATE SY-DATUM(6) '01' INTO S_ZJDATE-HIGH.
    S_ZJDATE-SIGN = 'I'.
    S_ZJDATE-OPTION = 'BT'.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN                  = S_ZJDATE-HIGH
     IMPORTING
       LAST_DAY_OF_MONTH       = S_ZJDATE-HIGH.

      APPEND S_ZJDATE.
    ENDIF.

  "배송일자 세팅
  IF S_ZDDATE[] IS INITIAL.
    CONCATENATE SY-DATUM(4) '01' '01' INTO S_ZDDATE-LOW.
    CONCATENATE SY-DATUM(6) '01' INTO S_ZDDATE-HIGH.
    S_ZJDATE-SIGN = 'I'.
    S_ZJDATE-OPTION = 'BT'.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN                  = S_ZDDATE-HIGH
     IMPORTING
       LAST_DAY_OF_MONTH       = S_ZDDATE-HIGH.

      APPEND S_ZDDATE.
    ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .
  "조회조건 점검

  "주문번호를 입력하여 조회할 때는 주문 일자를 입력하지 않아도되지만
  "회원ID가 입력될 때는 주문일자를 반드시 입력해야 함 -> 주문일자 미 입력시 ERROR뿌리고 레포트 미실행

  DATA : LV_CHECK_ORDNO TYPE C, LV_CHECK_ID TYPE C,LV_CHECK_DATE TYPE C.
  "입력되었는지 확인하기 위한 체크 변수(입력되었다면 X값을 가짐)

  IF S_ZORDNO[] IS NOT INITIAL.
    LV_CHECK_ORDNO = C_X.
  ENDIF.

  IF S_ZID[] IS NOT INITIAL.
    LV_CHECK_ID = C_X.
  ENDIF.

  IF P_R1 = C_X.
    IF S_ZJDATE[] IS NOT INITIAL.
      LV_CHECK_DATE = C_X.
    ENDIF.
  ELSEIF P_R2 = C_X.
    IF S_ZDDATE[] IS NOT INITIAL.
      LV_CHECK_DATE = C_X.
    ENDIF.
  ENDIF.

  "주문번호 또는 회원 ID가 필수적으로 입력되어야 함. 둘다 입력되지 않으면 ERROR
  IF LV_CHECK_ORDNO = '' AND LV_CHECK_ID = ''.
    MESSAGE E000.
    EXIT.
  ENDIF.

  "회원 ID가 입력될 때(주문 번호는 입력받지 않은 상태에서?)는 주문일자가 반드시 입력되어야 함
  IF LV_CHECK_ORDNO = '' AND LV_CHECK_ID = C_X.
    IF LV_CHECK_DATE = ''.
      MESSAGE E000.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_R1 .
   CLEAR R_REFUND.

  IF Z_CHECK = 'X'. "반품내역포함에 체크한 경우 반품내역까지 모두 보여야함
    R_REFUND-SIGN = 'I'.
    R_REFUND-OPTION = 'EQ'.
    R_REFUND-LOW = '1'.
    APPEND R_REFUND.

    R_REFUND-LOW = '2'.
    APPEND R_REFUND.
  ELSE. "반품내역포함에 체크 안한 경우 반품 내역은 보이지 않아야 함
    R_REFUND-SIGN = 'E'.
    R_REFUND-OPTION = 'EQ'.
    R_REFUND-LOW = '2'.
    APPEND R_REFUND.
  ENDIF.

    SELECT
    A~ZORDNO "주문번호
    A~ZIDCODE "회원ID
    A~ZMATNR "제품번호
    A~ZMATNAME "제품명
    A~ZMTART "제품유형
    A~ZVOLUM "수량
    A~VRKME "단위
    A~ZNSAMT "판매금액
    A~ZSLAMT "매출금액
    A~ZDCAMT "할인금액
    A~ZSALE_FG "매출구분
    A~ZJDATE "판매일자
    A~ZRET_FG "반품구분
    A~ZRDATE "반품일자
  FROM ZEDT07_100 AS A
  INTO CORRESPONDING FIELDS OF TABLE GT_ORDER
  WHERE A~ZORDNO IN S_ZORDNO "주문번호 조건
    AND A~ZIDCODE IN S_ZID "회원ID 조건
    AND A~ZMATNR IN S_ZMATNR "제품번호 조건
    AND A~ZJDATE IN S_ZJDATE "주문일자 조건
    AND A~ZSALE_FG IN R_REFUND. "반품 조건

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_R1 .

  LOOP AT GT_ORDER INTO GS_ORDER.
    CLEAR : GS_ORDER_ALV.
    MOVE-CORRESPONDING GS_ORDER TO GS_ORDER_ALV.

    "제품유형 키워드로 변경
  PERFORM MAKE_ZMTART USING GS_ORDER_ALV-ZMTART
                      CHANGING GS_ORDER_ALV-ZMTART_NAME.

   "매출구분 키워드로 변경, 신호등 색상 설정
   PERFORM MAKE_ZSALE USING GS_ORDER_ALV-ZSALE_FG
                      CHANGING GS_ORDER_ALV-ZSALE_FG_NAME GS_ORDER_ALV-ZCOLOR.

   "반품구분 키워드로 변경
   PERFORM MAKE_ZRET USING GS_ORDER_ALV-ZRET_FG
                     CHANGING GS_ORDER_ALV-ZRET_FG_NAME.

   APPEND GS_ORDER_ALV TO GT_ORDER_ALV.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZMTART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_ALV_ZMTART  text
*      <--P_GS_ORDER_ALV_ZMTART_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZMTART  USING    P_ZMTART
                  CHANGING P_ZMTART_N.

   CASE P_ZMTART. "제품유형
      WHEN '001'.
       P_ZMTART_N = '식품'.
      WHEN '002'.
       P_ZMTART_N = '상품'.
      WHEN '003'.
       P_ZMTART_N = '제품'.
      WHEN '004'.
       P_ZMTART_N = '의류'.
      WHEN '005'.
       P_ZMTART_N = '도서'.
      WHEN '006'.
      P_ZMTART_N = '서비스'.
    ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZSALE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_ALV_ZSALE_FG  text
*      <--P_GS_ORDER_ALV_ZSALE_FG_NAME  text
*      <--P_GS_ORDER_ALV_ZCOLOR  text
*----------------------------------------------------------------------*
FORM MAKE_ZSALE  USING    P_ZSALE_FG
                 CHANGING P_ZSALE_FG_N
                          P_ZCOLOR.

    CASE P_ZSALE_FG. "매출구분
      WHEN '1'.
        P_ZSALE_FG_N = '매출'.
        P_ZCOLOR = '@08@'. "매출이면 초록색
      WHEN '2'.
        P_ZSALE_FG_N = '반품'.
        P_ZCOLOR = '@0A@'. "반품이면 빨간색
    ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZRET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_ALV_ZRET_FG  text
*      <--P_GS_ORDER_ALV_ZRET_FG_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZRET  USING    P_ZRET_FG
                CHANGING P_ZRET_FG_N.
    CASE P_ZRET_FG. "반품구분
      WHEN '1'.
        P_ZRET_FG_N = '단순변심'.
      WHEN '2'.
        P_ZRET_FG_N = '제품하자'.
      WHEN '3'.
        P_ZRET_FG_N = '배송문제'.
    ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_R2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_R2 .
CLEAR R_REFUND.

  IF Z_CHECK = 'X'.
    R_REFUND-SIGN = 'I'.
    R_REFUND-OPTION = 'BT'.
    R_REFUND-LOW = ''.
    R_REFUND-HIGH = 'X'.
  ELSE.
    R_REFUND-SIGN = 'E'.
    R_REFUND-OPTION = 'EQ'.
    R_REFUND-LOW = 'X'.
  ENDIF.

    APPEND R_REFUND.

    SELECT
    A~ZORDNO "주문번호
    A~ZIDCODE "회원ID
    A~ZMATNR "제품번호
    A~ZMATNAME "제품명
    A~ZMTART "제품유형
    A~ZVOLUM "수량
    A~VRKME "단위
    A~ZSLAMT "매출금액
    A~ZDFLAG "배송현황
    A~ZDGUBUN "배송지역
    A~ZDDATE "배송일자
    A~ZRDATE "반품일자
    A~ZFLAG "반품체크
  FROM ZEDT07_101 AS A
  INTO CORRESPONDING FIELDS OF TABLE GT_DELIVERY
  WHERE A~ZORDNO IN S_ZORDNO "주문번호 조건
    AND A~ZIDCODE IN S_ZID "회원ID 조건
    AND A~ZMATNR IN S_ZMATNR "제품번호 조건
    AND A~ZDDATE IN S_ZDDATE "배송일자 조건
    AND A~ZFLAG IN R_REFUND. "반품조건
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_R2 .

    LOOP AT GT_DELIVERY INTO GS_DELIVERY.
    CLEAR : GS_DELIVERY_ALV.

    MOVE-CORRESPONDING GS_DELIVERY TO GS_DELIVERY_ALV.

    "제품유형 키워드로 변경
  PERFORM MAKE_ZMTART USING GS_DELIVERY_ALV-ZMTART
                      CHANGING GS_DELIVERY_ALV-ZMTART_NAME.

  "배송현황 키워드로 변경
  PERFORM MAKE_ZDFLAG USING GS_DELIVERY_ALV-ZDFLAG
                      CHANGING GS_DELIVERY_ALV-ZDFLAG_NAME.

  "배송지역 키워드로 변경
  PERFORM MAKE_ZDGUBUN USING GS_DELIVERY_ALV-ZDGUBUN
                       CHANGING GS_DELIVERY_ALV-ZDGUBUN_NAME.

  "반품구분 키워드로 변경
  PERFORM MAKE_ZFLAG USING GS_DELIVERY_ALV-ZFLAG
                     CHANGING GS_DELIVERY_ALV-ZCOLOR.

   APPEND GS_DELIVERY_ALV TO GT_DELIVERY_ALV.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZFLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ALV_ZRET_FG  text
*      <--P_GS_DELIVERY_ALV_ZRET_FG_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZFLAG  USING    P_ZFLAG
                 CHANGING P_ZCOLOR.
  IF P_ZFLAG = 'X'.
    P_ZCOLOR = '@0A@'. "반품이면 빨간색
  ELSE.
    P_ZCOLOR = '@08@'. "매출이면 초록색
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZDFLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ALV_ZDFLAG  text
*      <--P_GS_DELIVERY_ALV_ZDFLAG_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZDFLAG  USING    P_ZDFLAG
                  CHANGING P_ZDFLAG_N.
      CASE P_ZDFLAG.
        WHEN '1'.
          P_ZDFLAG_N = '배송시작'.
        WHEN '2'.
          P_ZDFLAG_N = '배송중'.
        WHEN '3'.
          P_ZDFLAG_N = '배송완료'.
      ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZDGUBUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ALV_ZDGUBUN  text
*      <--P_GS_DELIVERY_ALV_ZDGUBUN_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZDGUBUN  USING    P_ZDGUBUN
                   CHANGING P_ZDGUBUN_N.
      CASE P_ZDGUBUN.
        WHEN '1'.
          P_ZDGUBUN_N = '서울'.
        WHEN '2'.
          P_ZDGUBUN_N = '경기도'.
        WHEN '3'.
          P_ZDGUBUN_N = '충청도'.
        WHEN '4'.
          P_ZDGUBUN_N = '경상도'.
        WHEN '5'.
          P_ZDGUBUN_N = '강원도'.
        WHEN '6'.
          P_ZDGUBUN_N = '전라도'.
        WHEN '7'.
          P_ZDGUBUN_N = '제주도'.
      ENDCASE.

ENDFORM.
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
    IF SCREEN-GROUP1 = 'M1'.
      IF P_R1 = C_X.
        SCREEN-ACTIVE = '1'.
      ELSEIF P_R2 = C_X.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'.
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
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT .
  CREATE OBJECT GC_DOCKING "도킹 컨테이너 객체 생성
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
  GS_FIELDCAT-FIELDNAME = 'ZCOLOR'.
  GS_FIELDCAT-COLTEXT = '구분'.
  GS_FIELDCAT-ICON = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZORDNO'.
  GS_FIELDCAT-COLTEXT = '주문번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZIDCODE'.
  GS_FIELDCAT-COLTEXT = '회원ID'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZMATNR'.
  GS_FIELDCAT-COLTEXT = '제품번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZMATNAME'.
  GS_FIELDCAT-COLTEXT = '제품명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZMTART_NAME'.
  GS_FIELDCAT-COLTEXT = '제품유형'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZVOLUM'.
  GS_FIELDCAT-COLTEXT = '수량'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'VRKME'.
  GS_FIELDCAT-COLTEXT = '단위'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  IF P_R1 = C_X.
      CLEAR : GS_FIELDCAT.
         GS_FIELDCAT-COL_POS = 9.
         GS_FIELDCAT-FIELDNAME = 'ZNSAMT'.
         GS_FIELDCAT-COLTEXT = '판매금액'.
         GS_FIELDCAT-DO_SUM = 'X'.
         GS_FIELDCAT-CURRENCY = 'KRW'.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 10.
       GS_FIELDCAT-FIELDNAME = 'ZSLAMT'.
       GS_FIELDCAT-COLTEXT = '매출금액'.
       GS_FIELDCAT-DO_SUM = 'X'.
       GS_FIELDCAT-CURRENCY = 'KRW'.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 11.
       GS_FIELDCAT-FIELDNAME = 'ZDCAMT'.
       GS_FIELDCAT-COLTEXT = '할인금액'.
       GS_FIELDCAT-DO_SUM = 'X'.
       GS_FIELDCAT-CURRENCY = 'KRW'.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 12.
       GS_FIELDCAT-FIELDNAME = 'ZSALE_FG_NAME'.
       GS_FIELDCAT-COLTEXT = '매출구분'.
       GS_FIELDCAT-EMPHASIZE = 'X'. "색상강조
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 13.
       GS_FIELDCAT-FIELDNAME = 'ZJDATE'.
       GS_FIELDCAT-COLTEXT = '판매일자'.
       GS_FIELDCAT-OUTPUTLEN = 10.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 14.
       GS_FIELDCAT-FIELDNAME = 'ZRET_FG_NAME'.
       GS_FIELDCAT-COLTEXT = '반품구분'.
       IF Z_CHECK NE C_X. "반품 구분에 체크하지 않은 경우
         GS_FIELDCAT-NO_OUT = 'X'.
       ENDIF.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 15.
       GS_FIELDCAT-FIELDNAME = 'ZRDATE'.
       GS_FIELDCAT-COLTEXT = '반품일'.
       GS_FIELDCAT-OUTPUTLEN = 10.
       IF Z_CHECK NE C_X. "반품 구분에 체크하지 않은 경우
         GS_FIELDCAT-NO_OUT = 'X'.
       ENDIF.
  ELSEIF P_R2 = C_X.
         CLEAR : GS_FIELDCAT.
      GS_FIELDCAT-COL_POS = 9.
      GS_FIELDCAT-FIELDNAME = 'ZSLAMT'.
      GS_FIELDCAT-COLTEXT = '매출금액'.
      GS_FIELDCAT-DO_SUM = 'X'.
      GS_FIELDCAT-CURRENCY = 'KRW'.
      APPEND GS_FIELDCAT TO GT_FIELDCAT.

      CLEAR : GS_FIELDCAT.
      GS_FIELDCAT-COL_POS = 10.
      GS_FIELDCAT-FIELDNAME = 'ZDFLAG_NAME'.
      GS_FIELDCAT-COLTEXT = '배송현황'.
      APPEND GS_FIELDCAT TO GT_FIELDCAT.

      CLEAR : GS_FIELDCAT.
      GS_FIELDCAT-COL_POS = 11.
      GS_FIELDCAT-FIELDNAME = 'ZDGUBUN_NAME'.
      GS_FIELDCAT-COLTEXT = '배송지역'.
      GS_FIELDCAT-EMPHASIZE = 'X'. "색상강조
      APPEND GS_FIELDCAT TO GT_FIELDCAT.

      CLEAR : GS_FIELDCAT.
      GS_FIELDCAT-COL_POS = 12.
      GS_FIELDCAT-FIELDNAME = 'ZDDATE'.
      GS_FIELDCAT-COLTEXT = '배송일자'.
      GS_FIELDCAT-OUTPUTLEN = 10.
      APPEND GS_FIELDCAT TO GT_FIELDCAT.

      CLEAR : GS_FIELDCAT.
      GS_FIELDCAT-COL_POS = 13.
      GS_FIELDCAT-FIELDNAME = 'ZRDATE'.
      GS_FIELDCAT-COLTEXT = '반품일자'.
      GS_FIELDCAT-OUTPUTLEN = 10.
        IF Z_CHECK NE C_X. "반품 구분에 체크하지 않은 경우
        GS_FIELDCAT-NO_OUT = 'X'.
      ENDIF.
      APPEND GS_FIELDCAT TO GT_FIELDCAT.

      CLEAR : GS_FIELDCAT.
      GS_FIELDCAT-COL_POS = 14.
      GS_FIELDCAT-FIELDNAME = 'ZFLAG'.
      GS_FIELDCAT-COLTEXT = '반품체크'.
      GS_FIELDCAT-EMPHASIZE = 'X'. "색상강조.
        IF Z_CHECK NE C_X. "반품 구분에 체크하지 않은 경우
        GS_FIELDCAT-NO_OUT = 'X'.
      ENDIF.
  ENDIF.

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
 GS_LAYOUT-ZEBRA = 'X'. "라인 단위 별로 줄무늬 패턴을 설정
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
  GS_SORT-FIELDNAME = 'ZIDCODE'.
  GS_SORT-UP = 'X'. "오름차순
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.
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
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ORDER_ALV  text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY  USING  P_GT_ALV TYPE STANDARD TABLE.
  CALL METHOD GC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = P_GT_ALV
      IT_FIELDCATALOG               = GT_FIELDCAT
      IT_SORT                       = GT_SORT
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

ENDFORM.
