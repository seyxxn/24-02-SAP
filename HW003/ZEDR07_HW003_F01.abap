*&---------------------------------------------------------------------*
*&  Include           ZEDR07_HW003_F01
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
*&      Form  MAKE_ZFLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ALV_ZFLAG  text
*      <--P_GS_DELIVERY_ALV_ZCOLOR  text
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
*        GS_FIELDCAT-DO_SUM = 'X'.
         GS_FIELDCAT-CURRENCY = 'KRW'.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 10.
       GS_FIELDCAT-FIELDNAME = 'ZSLAMT'.
       GS_FIELDCAT-COLTEXT = '매출금액'.
*      GS_FIELDCAT-DO_SUM = 'X'.
       GS_FIELDCAT-CURRENCY = 'KRW'.
       APPEND GS_FIELDCAT TO GT_FIELDCAT.

       CLEAR : GS_FIELDCAT.
       GS_FIELDCAT-COL_POS = 11.
       GS_FIELDCAT-FIELDNAME = 'ZDCAMT'.
       GS_FIELDCAT-COLTEXT = '할인금액'.
*      GS_FIELDCAT-DO_SUM = 'X'.
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
*     GS_FIELDCAT-DO_SUM = 'X'.
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
 GS_LAYOUT-SEL_MODE = 'A'. "다중 선택 모드 설정

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

    DATA : LS_TOOLBAR TYPE STB_BUTTON.

    LS_TOOLBAR-FUNCTION = 'PDF'.
    LS_TOOLBAR-ICON = ICON_PRINT.
    LS_TOOLBAR-QUICKINFO = 'Save as PDF'.
    LS_TOOLBAR-TEXT = 'PDF'.

    APPEND LS_TOOLBAR TO P_OBJECT->MT_TOOLBAR.

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

ENDFORM.



FORM ALV_HANDLER_USER_COMMAND USING P_UCOMM. "PDF 선택을 인식하고, 사용자 선택값 체크

  DATA: SELECTED_ROWS TYPE LVC_T_ROW,          " 선택된 행 인덱스를 저장하는 테이블
        GS_ORDER_PDF LIKE GS_ORDER_ALV,        " 선택된 행의 데이터를 저장할 구조체
        SELECTED_ROW_IDX TYPE LVC_S_ROW-INDEX. " 선택된 하나의 행의 인덱스 저장

  CASE P_UCOMM.
    WHEN 'PDF'.

      " 선택된 행의 인덱스를 가져옴
      CALL METHOD GC_GRID->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = SELECTED_ROWS.

      "데이터를 선택하지 않은 경우
      IF LINES( SELECTED_ROWS ) = 0.
        MESSAGE '데이터를 선택해주세요.' TYPE 'E'.
        RETURN.
      ENDIF.

      " 여러 줄이 선택되었는지 확인
      IF LINES( SELECTED_ROWS ) <> 1.
        MESSAGE '한 데이터만 선택 가능합니다.' TYPE 'E'.
        RETURN.
      ENDIF.

      " 선택된 첫 번째 행 인덱스 가져오기
      READ TABLE SELECTED_ROWS INTO DATA(ROW) INDEX 1.
      SELECTED_ROW_IDX = ROW-INDEX.

     READ TABLE GT_ORDER_ALV INTO GS_ORDER_PDF INDEX SELECTED_ROW_IDX. "행의 값들 읽어오기

*     PERFORM EXPORT_TO_PDF USING GS_ORDER_PDF. "PDF로 변환하는 함수를 따로 빼고 사용자가 선택한 값들을 넘겨줌
      PERFORM EXPORT_TO_PDF_2 USING GS_ORDER_PDF.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXPORT_TO_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_PDF  text
*----------------------------------------------------------------------*
FORM EXPORT_TO_PDF  USING    P_ORDER_PDF LIKE GS_ORDER_ALV.

  DATA : LV_DIRECTORY TYPE STRING. "디렉터리 경로
  DATA : LV_EXCEL_PATH TYPE STRING. "엑셀 템플릿 파일 경로
  DATA : LV_PDF_PATH TYPE STRING. "PDF 파일 경로
  DATA : LV_RC TYPE I.

  "1. 디렉터리 지정 - 사용자에게 디렉터리 선택 창을 표시해서 디렉터리를 지정하게 함
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE         = '파일 저장 경로'
*      INITIAL_FOLDER       =
    CHANGING
      SELECTED_FOLDER      = LV_DIRECTORY
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      others               = 4
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

  IF LV_DIRECTORY IS INITIAL.
    MESSAGE '저장 경로를 선택하지 않았습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  "파일 명 설정
  LV_EXCEL_PATH = LV_DIRECTORY && '\ORDER_DATA.XLSX'.
*  LV_PDF_PATH = LV_DIRECTORY && '\ORDER_DATA.PDF'.

  "2. 엑셀 템플릿 다운로드
 DATA :   LS_WWWDATA   TYPE WWWDATATAB,
          LV_FILE   TYPE RLGRAP-FILENAME.

  " OBJID로 데이터 가져오기
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_WWWDATA
  FROM WWWDATA
  WHERE OBJID = 'Z_EXCEL_TEMPLATE_FOR_ORDER'.

  LV_FILE = LV_EXCEL_PATH. "형 변환

  "템플릿 다운로드
   CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
     EXPORTING
      KEY               = LS_WWWDATA
      DESTINATION       = LV_FILE.

  TYPE-POOLS OLE2.
  DATA: LV_APPLICATION TYPE OLE2_OBJECT,
        LV_WORKBOOK    TYPE OLE2_OBJECT,
        LV_WORKSHEET  TYPE OLE2_OBJECT.

  CREATE OBJECT LV_APPLICATION 'excel.application'.
    IF SY-SUBRC <> 0.
     MESSAGE 'Excel 애플리케이션을 생성할 수 없습니다.' TYPE 'E'.
      RETURN.
    ENDIF.

  CALL METHOD OF LV_APPLICATION 'WORKBOOS' = LV_WORKBOOK.

   CALL METHOD OF LV_WORKBOOK 'OPEN'
      EXPORTING
        #1 = LV_FILE.
   IF SY-SUBRC <> 0 OR LV_WORKBOOK IS INITIAL.
      MESSAGE '워크북을 열 수 없습니다.' TYPE 'E'.
      RETURN.
   ENDIF.

  SET PROPERTY OF LV_APPLICATION 'VISIBLE' = 1.

  GET PROPERTY OF LV_APPLICATION 'ACTIVESHEET' = LV_WORKBOOK.
  SET PROPERTY OF LV_WORKBOOK 'Name' = 'ORDER'.

    "3. 엑셀 템플릿 열기
*    CREATE OBJECT LV_APPLICATION 'EXCEL.APPLICATION'.
*      SET PROPERTY OF LV_APPLICATION 'Visible' = 1.
*    IF SY-SUBRC <> 0.
*     MESSAGE 'Excel 애플리케이션을 생성할 수 없습니다.' TYPE 'E'.
*      RETURN.
*    ENDIF.


*   TRY.
*       CREATE OBJECT LV_APPLICATION 'EXCEL.APPLICATION'.
*       SET PROPERTY OF LV_APPLICATION 'Visible' = 1.
*   CATCH CX_SY_CREATE_OBJECT_ERROR INTO DATA(LX_ERROR).
*       MESSAGE LX_ERROR->GET_TEXT( ) TYPE 'E'.
*       RETURN.
*   ENDTRY.

*    DATA: lv_file_exists TYPE abap_bool.
*    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
*      EXPORTING
*        FILE = LV_EXCEL_PATH
*      RECEIVING
*        RESULT   = lv_file_exists.
*
*    IF lv_file_exists = abap_false.
*      MESSAGE |파일이 존재하지 않습니다: { LV_EXCEL_PATH }| TYPE 'E'.
*      RETURN.
*    ENDIF.

*   CALL METHOD OF LV_APPLICATION 'WORKBOOKS' = LV_WORKBOOK.
*   IF LV_WORKBOOK IS INITIAL.
*    MESSAGE 'WORKBOOKS 객체를 가져올 수 없습니다.' TYPE 'E'.
*    RETURN.
*   ENDIF.

*   CALL METHOD OF LV_WORKBOOK 'OPEN'
*      EXPORTING
*        #1 = LV_FILE.
**        #1 = LV_EXCEL_PATH.
*   IF SY-SUBRC <> 0 OR LV_WORKBOOK IS INITIAL.
*      MESSAGE '워크북을 열 수 없습니다.' TYPE 'E'.
*      RETURN.
*   ENDIF.

    " 3. 워크시트 작업
    CALL METHOD OF LV_WORKBOOK 'WORKSHEETS' = LV_WORKSHEET
      EXPORTING
        #1 = 1.
    IF LV_WORKSHEET IS INITIAL.
      MESSAGE '워크시트 객체가 생성되지 않았습니다.' TYPE 'E'.
    ENDIF.

    "4. 데이터 쓰기
      CALL METHOD OF LV_WORKSHEET 'CELLS'
          EXPORTING
          #1 = 1
          #2 = 2
          #3 = P_ORDER_PDF-ZORDNO.
      CALL METHOD OF LV_WORKSHEET 'CELLS'
          EXPORTING
          #1 = 2
          #2 = 2
          #3 = P_ORDER_PDF-ZIDCODE.
      CALL METHOD OF LV_WORKSHEET 'CELLS'
          EXPORTING
          #1 = 3
          #2 = 2
          #3 = P_ORDER_PDF-ZMATNR.
      CALL METHOD OF LV_WORKSHEET 'CELLS'
          EXPORTING
          #1 = 4
          #2 = 2
          #3 = P_ORDER_PDF-ZMATNAME.
      CALL METHOD OF LV_WORKSHEET 'CELLS'
          EXPORTING
          #1 = 5
          #2 = 2
          #3 = P_ORDER_PDF-ZSLAMT.
      CALL METHOD OF LV_WORKSHEET 'CELLS'
          EXPORTING
          #1 = 6
          #2 = 2
          #3 = P_ORDER_PDF-ZJDATE.

    " 5. PDF로 저장
*      CALL METHOD OF LV_WORKBOOK 'ExportAsFixedFormat'
*        EXPORTING
*          #1 = 0                 " PDF 포맷 (xlTypePDF = 0)
*          #2 = lv_pdf_path       " PDF 파일 경로
*          #3 = 0.                " 표준 품질 출력 (Standard = 0)
*
*
*      MESSAGE |PDF 파일이 저장되었습니다: { lv_pdf_path }| TYPE 'I'.

      " 6. 엑셀 종료
      CALL METHOD OF LV_APPLICATION 'Quit'.
      FREE OBJECT LV_APPLICATION.
      FREE OBJECT  LV_WORKBOOK.
      FREE OBJECT LV_WORKSHEET.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXPORT_TO_PDF_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_PDF  text
*----------------------------------------------------------------------*
FORM EXPORT_TO_PDF_2 USING P_ORDER_PDF LIKE GS_ORDER_ALV.

  DATA : LV_FILE           TYPE STRING.         " 저장할 PDF 파일 전체 경로
  DATA : LV_DIR            TYPE STRING.         " 선택된 디렉토리 경로
  DATA : SPOOL_ID TYPE TSP01-RQIDENT.           " 생성된 스풀 ID
  DATA : PDF_DATA TYPE TABLE OF TLINE.          " PDF 변환된 데이터 저장되는  테이블

  " 매출 금액을 KRW로 포맷
  DATA: LV_AMOUNT_KRW TYPE STR.
  DATA: LV_AMOUNT_RAW TYPE P DECIMALS 2. " 금액 데이터를 저장할 변수

  LV_AMOUNT_RAW = P_ORDER_PDF-ZSLAMT.

  " 포맷된 문자열 생성
  WRITE LV_AMOUNT_RAW TO LV_AMOUNT_KRW CURRENCY 'KRW'.

  " 스풀 요청 생성 (선택된 데이터만 출력)
  NEW-PAGE PRINT ON "새로운 출력 페이지 생성, 프린터 스풀 요청 만들기
    NO DIALOG
    LINE-SIZE 132
    LINE-COUNT 65

    NEW LIST IDENTIFICATION 'Order Print'.
        SKIP.
      WRITE: / '주문번호 :', P_ORDER_PDF-ZORDNO.
        SKIP.
      WRITE: / '회원 ID  :', P_ORDER_PDF-ZIDCODE.
        SKIP.
      WRITE: / '제품번호 :', P_ORDER_PDF-ZMATNR.
        SKIP.
      WRITE: / '제품명   :', P_ORDER_PDF-ZMATNAME.
        SKIP.
      WRITE: / '매출금액 :', LV_AMOUNT_KRW , '원'. " 포맷된 문자열 출력
*      WRITE: / '매출금액 :', P_ORDER_PDF-ZSLAMT.
        SKIP.
      WRITE: / '판매일자 :', P_ORDER_PDF-ZJDATE.
  NEW-PAGE PRINT OFF. "스풀요청 종료



  " 스풀 ID 가져오기
  SPOOL_ID = SY-SPONO. "가장 최근의 스풀 요청 ID를 저장하는 시스템필드

  " 스풀 데이터를 PDF로 변환
  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
     EXPORTING
        SRC_SPOOLID                    = SPOOL_ID "변환할 스풀ID
     TABLES
        PDF                            =  PDF_DATA "변환된 PDF 데이터 저장할 테이블
                           .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  "저장 경로 선택
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE    = 'PDF 저장 경로 선택'
    CHANGING
      SELECTED_FOLDER = LV_DIR "선택된 디렉토리 경로 저장됨
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.

  IF SY-SUBRC <> 0 OR LV_DIR IS INITIAL.
    MESSAGE '저장 경로를 선택하지 않았습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  "전체 파일 경로 변수에 저장
  CONCATENATE LV_DIR '\ORDER_DATA.pdf' INTO LV_FILE.

  "PDF 데이터를 로컬 파일로 저장
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME = LV_FILE
      FILETYPE = 'BIN' "파일유형 바이너리
    TABLES
      DATA_TAB = PDF_DATA "저장할 데이터 테이블
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      OTHERS                  = 5.

  IF SY-SUBRC = 0.
    MESSAGE |PDF 파일이 성공적으로 저장되었습니다: { LV_FILE }| TYPE 'I'.
  ELSE.
    MESSAGE 'PDF 파일 저장 실패.' TYPE 'E'.
  ENDIF.

ENDFORM.
