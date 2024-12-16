*&---------------------------------------------------------------------*
*&  Include           ZEDR07_HW002_F01
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

  IF GT_ORDER IS NOT INITIAL.
    SELECT
      B~ZCODE
      B~ZKNAME
      B~ZENAME
      B~ZGENDER
      B~ZTEL
      FROM ZEDT07_001 AS B
      INTO CORRESPONDING FIELDS OF TABLE GT_MEMBER
      FOR ALL ENTRIES IN GT_ORDER
      WHERE B~ZCODE = GT_ORDER-ZIDCODE. " GT_ORDER의 회원 ID를 조건으로 사용
  ENDIF.

  IF GT_ORDER IS NOT INITIAL.
      SELECT
      C~ZWERKS
      C~ZLGORT
      C~ZMATNR
      C~ZMATNAME
      C~ZMTART
      C~STPRS
      C~WAERS
      C~MENGE
      C~MEINS
    FROM ZEDT07_102 AS C
    INTO CORRESPONDING FIELDS OF TABLE GT_MARA
    FOR ALL ENTRIES IN GT_ORDER
    WHERE C~ZMATNR = GT_ORDER-ZMATNR. "GT_ORDER의 제품번호를 조건으로 사용
  ENDIF.

* LOOP AT gt_member INTO gs_member.
*   WRITE: / gs_member-zcode.
* ENDLOOP.


* LOOP AT GT_MARA INTO GS_MARA.
*   WRITE :/ GS_MARA-ZWERKS, GS_MARA-ZLGORT, GS_MARA-ZMATNR.
* ENDLOOP.

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

   IF GT_DELIVERY IS NOT INITIAL.
    SELECT
      B~ZCODE
      B~ZKNAME
      B~ZENAME
      B~ZGENDER
      B~ZTEL
      FROM ZEDT07_001 AS B
      INTO CORRESPONDING FIELDS OF TABLE GT_MEMBER
      FOR ALL ENTRIES IN GT_DELIVERY
      WHERE B~ZCODE = GT_DELIVERY-ZIDCODE. " GT_DELIVERY의 회원 ID를 조건으로 사용
  ENDIF.

  IF GT_DELIVERY IS NOT INITIAL.
      SELECT
      C~ZWERKS
      C~ZLGORT
      C~ZMATNR
      C~ZMATNAME
      C~ZMTART
      C~STPRS
      C~WAERS
      C~MENGE
      C~MEINS
    FROM ZEDT07_102 AS C
    INTO CORRESPONDING FIELDS OF TABLE GT_MARA
    FOR ALL ENTRIES IN GT_DELIVERY
    WHERE C~ZMATNR = GT_DELIVERY-ZMATNR. "GT_ORDER의 제품번호를 조건으로 사용
  ENDIF.

*  LOOP AT gt_member INTO gs_member.
*    WRITE: / gs_member-zcode.
*  ENDLOOP.


*  LOOP AT GT_MARA INTO GS_MARA.
*    WRITE :/ GS_MARA-ZWERKS, GS_MARA-ZLGORT, GS_MARA-ZMATNR.
*  ENDLOOP.

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
*&      Form  MODIFY_DATA_COM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_COM .
  LOOP AT GT_MEMBER INTO GS_MEMBER.
    CLEAR : GS_MEMBER_ALV.
    MOVE-CORRESPONDING GS_MEMBER TO GS_MEMBER_ALV.

    "성별
    PERFORM MAKE_ZGENDER USING GS_MEMBER_ALV-ZGENDER
                         CHANGING GS_MEMBER_ALV-ZGENDER_NAME.

    APPEND GS_MEMBER_ALV TO GT_MEMBER_ALV.
  ENDLOOP.

  LOOP AT GT_MARA INTO GS_MARA.
    CLEAR : GS_MARA_ALV.

    MOVE-CORRESPONDING GS_MARA TO GS_MARA_ALV.

    "플랜트
    PERFORM MAKE_ZWERKS USING GS_MARA_ALV-ZWERKS
                        CHANGING GS_MARA_ALV-ZWERKS_NAME.
    "저장위치
    PERFORM MAKE_ZLGORT USING GS_MARA_ALV-ZLGORT
                        CHANGING GS_MARA_ALV-ZLGORT_NAME.
    "자재유형
    PERFORM MAKE_ZMTARTT USING GS_MARA_ALV-ZMTART
                         CHANGING GS_MARA_ALV-ZMTART_NAME.

    APPEND GS_MARA_ALV TO GT_MARA_ALV.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZGENDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_MEMBER_ALV_ZGENDER  text
*      <--P_GS_MEMBER_ALV_ZGENDER_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZGENDER  USING    P_MEMBER_ZGENDER
                   CHANGING P_MEMBER_ZGENDER_NAME.

   CASE P_MEMBER_ZGENDER.
     WHEN 'F'.
       P_MEMBER_ZGENDER_NAME = '여성'.
     WHEN 'M'.
       P_MEMBER_ZGENDER_NAME = '남성'.
   ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZWERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_MARA_ALV_ZWERKS  text
*      <--P_GS_MARA_ALV_ZWERKS_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZWERKS  USING    P_MARA_ZWERKS
                  CHANGING P_MARA_ZWERKS_NAME.
  CASE P_MARA_ZWERKS.
    WHEN '1000'.
       P_MARA_ZWERKS_NAME = '서울공장'.
    WHEN '1100'.
      P_MARA_ZWERKS_NAME = '천안공장'.
    WHEN '1200'.
      P_MARA_ZWERKS_NAME = '대전공장'.
    WHEN '1300'.
      P_MARA_ZWERKS_NAME = '부산공장'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZLGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_MARA_ALV_ZLGORT  text
*      <--P_GS_MARA_ALV_ZLGORT_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZLGORT  USING    P_MARA_ZLGORT
                  CHANGING P_MARA_ZLGORT_NAME.
    CASE P_MARA_ZLGORT.
      WHEN '1000'.
        P_MARA_ZLGORT_NAME = '일반창고'.
      WHEN '2000'.
        P_MARA_ZLGORT_NAME = '반품창고'.
      WHEN '3000'.
        P_MARA_ZLGORT_NAME = '폐기창고'.
    ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_ZMTARTT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_MARA_ALV_ZMTART  text
*      <--P_GS_MARA_ALV_ZMTART_NAME  text
*----------------------------------------------------------------------*
FORM MAKE_ZMTARTT  USING    P_MARA_ZMTART
                   CHANGING P_MARA_ZMTART_NAME.

    CASE P_MARA_ZMTART.
      WHEN 'Z001'.
        P_MARA_ZMTART_NAME = '제품'.
      WHEN 'Z002'.
        P_MARA_ZMTART_NAME = '반제품'.
      WHEN 'Z003'.
        P_MARA_ZMTART_NAME = '상품'.
      WHEN 'Z004'.
        P_MARA_ZMTART_NAME = '원재료'.
      WHEN 'Z005'.
        P_MARA_ZMTART_NAME = '포장재'.
      WHEN 'Z006'.
        P_MARA_ZMTART_NAME = '서비스'.
    ENDCASE.

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
  "DOCKING CONTAINER
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

  "SPLITTER_TOP -> 2행 1열로 나눔
  CREATE OBJECT GC_SPLITTER_TOP
    EXPORTING
      PARENT            = GC_DOCKING
      ROWS              = 2
      COLUMNS           = 1
      .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "TOP에 CONTAINER1 호출
  CALL METHOD GC_SPLITTER_TOP->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER1.
      .

  "SPLITTER_BOTTOM -> 하단을 1행 2열로 나눔
  CREATE OBJECT GC_SPLITTER_BOTTOM
    EXPORTING
      PARENT            = gc_splitter_top->get_container( row = 2 column = 1 )
      ROWS              = 1
      COLUMNS           = 2
      .
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "하단의 왼쪽 화면
  CALL METHOD GC_SPLITTER_BOTTOM->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER2.
      .

  "하단의 오른쪽 화면
     CALL METHOD GC_SPLITTER_BOTTOM->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GC_CONTAINER3.
      .

   "그리드 생성
   CREATE OBJECT GC_GRID1
     EXPORTING
       I_PARENT          = GC_CONTAINER1
       .
   IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

      "그리드 생성
   CREATE OBJECT GC_GRID2
     EXPORTING
       I_PARENT          = GC_CONTAINER2
       .
   IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

      "그리드 생성
   CREATE OBJECT GC_GRID3
     EXPORTING
       I_PARENT          = GC_CONTAINER3
       .
   IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

  PERFORM CONTAINER2_FIELD.
  PERFORM CONTAINER3_FIELD.
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
  CLEAR : GS_SORT, GT_SORT.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZIDCODE'.
  GS_SORT-UP = 'X'. "오름차순
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.

  CLEAR : GS_SORT, GT_SORT2.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZCODE'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT2.

  CLEAR : GS_SORT, GT_SORT3.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZMATNR'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT3.

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

    CALL METHOD GC_GRID3->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STABLE
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.


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
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-COLTEXT = '한국이름'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZENAME'.
  GS_FIELDCAT-COLTEXT = '영문이름'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZGENDER_NAME'.
  GS_FIELDCAT-COLTEXT = '성별'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZTEL'.
  GS_FIELDCAT-COLTEXT = '전화번호'.
  GS_FIELDCAT-OUTPUTLEN = 13. "문자 열 너비 설정
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER3_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER3_FIELD .
  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZMATNR'.
  GS_FIELDCAT-COLTEXT = '제품번호'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZMATNAME'.
  GS_FIELDCAT-COLTEXT = '제품명'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZWERKS_NAME'.
  GS_FIELDCAT-COLTEXT = '플랜트명'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZLGORT_NAME'.
  GS_FIELDCAT-COLTEXT = '저장위치명'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZMTART_NAME'.
  GS_FIELDCAT-COLTEXT = '자재유형명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

    CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'STPRS'.
  GS_FIELDCAT-COLTEXT = '단가'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'WAERS'.
  GS_FIELDCAT-COLTEXT = '통화'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'MENGE'.
  GS_FIELDCAT-COLTEXT = '수량'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 9.
  GS_FIELDCAT-FIELDNAME = 'MEIN'.
  GS_FIELDCAT-COLTEXT = '단위'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-QFIELDNAME = 'MEINS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ORDER_ALV  text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY  USING  P_GT_ALV TYPE STANDARD TABLE.
   CALL METHOD GC_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
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

  CALL METHOD GC_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      IS_VARIANT                    =
*      I_SAVE                        =
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_MEMBER_ALV
      IT_FIELDCATALOG               = GT_FIELDCAT2
      IT_SORT                       = GT_SORT2
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

    CALL METHOD GC_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      IS_VARIANT                    =
*      I_SAVE                        =
      IS_LAYOUT                     = GS_LAYOUT
    CHANGING
      IT_OUTTAB                     = GT_MARA_ALV
      IT_FIELDCATALOG               = GT_FIELDCAT3
      IT_SORT                       = GT_SORT3
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.


ENDFORM.
