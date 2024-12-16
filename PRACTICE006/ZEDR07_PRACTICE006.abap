*&---------------------------------------------------------------------*
*& Report ZEDR00_PRACTICE005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_PRACTICE006 MESSAGE-ID ZMED00.
TABLES : ZEDT00_004, ZEDT00_005, ZEDT00_006, ZEDT00_007, ZEDT00_008.

CONSTANTS : C_X TYPE CHAR1 VALUE 'X'.
RANGES : R_FLAG FOR ZEDT00_004-ZQFLAG.
*****1. 데이터선언
"1)ITAB
DATA : BEGIN OF GS_PERNR, "사원정보테이블
  ZPERNR LIKE ZEDT00_004-ZPERNR, "사원번호
  ZPNAME LIKE ZEDT00_005-ZPNAME, "사원이름
  ZDEPCODE LIKE ZEDT00_004-ZDEPCODE, "부서코드
  ZDEPRANK LIKE ZEDT00_004-ZDEPRANK, "직급
  ZEDATE LIKE ZEDT00_004-ZEDATE, "입사일
  ZQFLAG LIKE ZEDT00_004-ZQFLAG, "퇴직상태
  ZGENDER LIKE ZEDT00_005-ZGENDER, "성별
  ZADDRESS LIKE ZEDT00_005-ZADDRESS, "주소
  ZBANKCODE LIKE ZEDT00_008-ZBANKCODE, "은행코드
  ZACCOUNT LIKE ZEDT00_008-ZACCOUNT, "계좌번호
  END OF GS_PERNR.
DATA : GT_PERNR LIKE TABLE OF GS_PERNR.

DATA : BEGIN OF GS_PERNR_ALV, "사원정보 ALV출력용
  ZPERNR LIKE ZEDT00_004-ZPERNR, "사원번호
  ZPNAME LIKE ZEDT00_005-ZPNAME, "사원이름
  ZDEPCODE LIKE ZEDT00_004-ZDEPCODE, "부서코드
  ZDEPCODE_NAME(10), "부서명
  ZDEPRANK_NAME(6),  "직급명
  ZEDATE LIKE ZEDT00_004-ZEDATE, "입사일
  ZQFLAG_NAME(4), "퇴직상태
  ZGENDER_NAME(4), "성별
  ZADDRESS LIKE ZEDT00_005-ZADDRESS, "주소
  ZBANKCODE LIKE ZEDT00_008-ZBANKCODE, "은행코드
  ZBANK_NAME(10),"은행명
  ZACCOUNT LIKE ZEDT00_008-ZACCOUNT, "계좌번호
  END OF GS_PERNR_ALV.
DATA : GT_PERNR_ALV LIKE TABLE OF GS_PERNR_ALV.

DATA : BEGIN OF GS_SALARY, "월급지급테이블
  ZPERNR LIKE ZEDT00_004-ZPERNR, "사원번호
  ZSALARY LIKE ZEDT00_008-ZSALARY, "계약금액
  ZPAY LIKE ZEDT00_008-ZSALARY, "월급
  ZRANK LIKE ZEDT00_006-ZRANK, "평가등급
  END OF GS_SALARY.
DATA : GT_SALARY LIKE TABLE OF GS_SALARY.

DATA : BEGIN OF GS_ASSESS, "평가테이블
  ZPERNR LIKE ZEDT00_004-ZPERNR, "사원번호
  ZPNAME LIKE ZEDT00_005-ZPNAME, "사원이름
  ZDEPCODE LIKE ZEDT00_004-ZDEPCODE, "부서코드
  ZDEPRANK LIKE ZEDT00_004-ZDEPRANK, "직급
  ZEDATE LIKE ZEDT00_004-ZEDATE, "입사일
  ZSALARY LIKE ZEDT00_008-ZSALARY, "계약금액
  ZRANK LIKE ZEDT00_006-ZRANK, "평가등급
  END OF GS_ASSESS.
DATA : GT_ASSESS LIKE TABLE OF GS_ASSESS.

DATA : BEGIN OF GS_ASSESS_ALV, "평가테이블 ALV출력용
  ZPERNR LIKE ZEDT00_004-ZPERNR, "사원번호
  ZPNAME LIKE ZEDT00_005-ZPNAME, "사원이름
  ZDEPCODE LIKE ZEDT00_004-ZDEPCODE, "부서코드
  ZDEPCODE_NAME(10), "부서명
  ZDEPRANK_NAME(6),  "직급명
  ZEDATE LIKE ZEDT00_004-ZEDATE, "입사일
  ZSALARY LIKE ZEDT00_008-ZSALARY, "계약금액
  ZRANK LIKE ZEDT00_006-ZRANK, "평가등급
  ZMON LIKE ZEDT00_007-ZMON01, "월급
  END OF GS_ASSESS_ALV.
DATA : GT_ASSESS_ALV LIKE TABLE OF GS_ASSESS_ALV.

DATA : GV_YEAR(4),
       GV_MON(2) TYPE N.
DATA : GV_CHECK.

"2)필드카탈로그
DATA : GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
DATA : GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
"3)레이아웃
DATA : GS_LAYOUT TYPE SLIS_LAYOUT_ALV.
"4)SORT
DATA : GS_SORT TYPE SLIS_SORTINFO_ALV.
DATA : GT_SORT TYPE SLIS_T_SORTINFO_ALV.

*****2. SCREEN
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
 SELECT-OPTIONS : S_ZPERNR FOR ZEDT00_004-ZPERNR.
 SELECT-OPTIONS : S_DATE FOR ZEDT00_004-DATBI NO-EXTENSION MODIF ID M1.
 PARAMETERS : P_YEAR LIKE ZEDT00_007-ZYEAR DEFAULT SY-DATUM+0(4) MODIF ID M2.
 PARAMETERS : P_MON(2) DEFAULT SY-DATUM+4(2) MODIF ID M2 .
 SELECT-OPTIONS : S_ZDEP FOR ZEDT00_004-ZDEPCODE NO INTERVALS NO-EXTENSION MODIF ID M1.
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
 PARAMETERS : P_R1 RADIOBUTTON GROUP R1 DEFAULT 'X' USER-COMMAND UC1.
 PARAMETERS : P_R2 RADIOBUTTON GROUP R1.
 PARAMETERS : P_R3 RADIOBUTTON GROUP R1.
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME.
 PARAMETERS : P_CH1 AS CHECKBOX DEFAULT 'X' MODIF ID M1.
SELECTION-SCREEN END OF BLOCK B3.

*****3. 초기값 설정
INITIALIZATION.
  PERFORM SET_DATE.

*****4. 스크린 제어
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.

*****5. MAIN PROGRAM
START-OF-SELECTION.
  PERFORM CHECK_DATA.

  CASE C_X.
    WHEN P_R1. "사원정보
      PERFORM SELECT_DATA_R1.
      IF GT_PERNR[] IS INITIAL.
        MESSAGE I001.
        EXIT.
      ENDIF.
      PERFORM MODIFY_DATA_R1.
      PERFORM ALV_DISPLAY_R1.
    WHEN P_R2. "월급지급
      PERFORM SELECT_DATA_R2.
      IF GT_SALARY[] IS INITIAL.
        MESSAGE I001.
        EXIT.
      ENDIF.
      PERFORM MODIFY_DATA_R2.
    WHEN P_R3. "평가정보
      PERFORM SELECT_DATA_R3.
      IF GT_ASSESS[] IS INITIAL.
        MESSAGE I001.
        EXIT.
      ENDIF.
      PERFORM MODIFY_DATA_R3.
      PERFORM ALV_DISPLAY_R3.
  ENDCASE.

END-OF-SELECTION.
  CHECK P_R2 = C_X.
      IF GV_CHECK = C_X.
        MESSAGE I002.
      ELSE.
        MESSAGE I003.
      ENDIF.

***************************************************************************
*****6. PERFORM
*&---------------------------------------------------------------------*
*&      Form  SET_DATE
*&---------------------------------------------------------------------*
FORM SET_DATE .

  IF S_DATE[] IS INITIAL.
    CONCATENATE SY-DATUM(4) '01' '01' INTO S_DATE-LOW.
    S_DATE-HIGH = SY-DATUM(6) && '01'. "&&로도 표현 가능 (=CONCATENATE)
    S_DATE-SIGN = 'I'.
    S_DATE-OPTION = 'BT'.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = S_DATE-HIGH
      IMPORTING
        LAST_DAY_OF_MONTH = S_DATE-HIGH.

    APPEND S_DATE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN
*&---------------------------------------------------------------------*
FORM SET_SCREEN .

  LOOP AT SCREEN.
    IF P_R1 = C_X.
      IF SCREEN-GROUP1 = 'M2'.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ELSE.
      IF SCREEN-GROUP1 = 'M1'.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
FORM CHECK_DATA .

  "조회조건 점검
  IF P_R1 = C_X.
    IF  S_DATE IS INITIAL .
      MESSAGE I000.
      STOP.
    ENDIF.
  ELSE.
    IF ( P_YEAR IS INITIAL ) OR ( P_MON IS INITIAL ).
      MESSAGE I000.
      STOP.
    ENDIF.
  ENDIF.

  "전역변수 점검
  CLEAR : GV_YEAR, GV_MON, GV_CHECK.
  GV_YEAR = P_YEAR.
  GV_MON = P_MON.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA_R1
*&---------------------------------------------------------------------*
FORM SELECT_DATA_R1 .

  CLEAR R_FLAG.

  IF P_CH1 = C_X.
  ELSE.
    R_FLAG-SIGN = 'I'.
    R_FLAG-OPTION = 'BT'.
    R_FLAG-LOW = ' '.
    APPEND R_FLAG.
    R_FLAG-LOW = C_X.
    APPEND R_FLAG.
  ENDIF.

  SELECT A~ZPERNR "사원번호
         B~ZPNAME "사원이름
         A~ZDEPCODE "부서코드
         A~ZDEPRANK "직급코드
         A~ZEDATE "입사일
         A~ZQFLAG "퇴직상태
         B~ZGENDER "성별
         B~ZADDRESS "주소
         C~ZBANKCODE "은행코드
         C~ZACCOUNT "계좌번호
    INTO CORRESPONDING FIELDS OF TABLE GT_PERNR
    FROM ZEDT00_004 AS A  INNER JOIN ZEDT00_005 AS B
    ON A~ZPERNR = B~ZPERNR
    INNER JOIN ZEDT00_008 AS C
    ON A~ZPERNR = C~ZPERNR
    WHERE A~ZPERNR IN S_ZPERNR
    AND   A~DATBI => S_DATE-LOW
    AND   A~DATAB > S_DATE-HIGH
    AND   A~ZDEPCODE IN S_ZDEP
    AND   A~ZQFLAG IN R_FLAG.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R1
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_R1 .

  LOOP AT GT_PERNR INTO GS_PERNR.
    CLEAR : GS_PERNR_ALV.
    MOVE-CORRESPONDING GS_PERNR TO GS_PERNR_ALV.

    PERFORM MAKE_DEPCODE USING GS_PERNR_ALV-ZDEPCODE
                         CHANGING GS_PERNR_ALV-ZDEPCODE_NAME.
    PERFORM MAKE_RANK USING GS_PERNR-ZDEPRANK
                      CHANGING GS_PERNR_ALV-ZDEPRANK_NAME.

    IF GS_PERNR-ZQFLAG = C_X.
      GS_PERNR_ALV-ZQFLAG_NAME = '퇴직'.
    ELSE.
      GS_PERNR_ALV-ZQFLAG_NAME = '재직'.
    ENDIF.

    IF GS_PERNR-ZGENDER = 'M'.
      GS_PERNR_ALV-ZGENDER_NAME = '남자'.
    ELSEIF GS_PERNR-ZGENDER = 'F'.
      GS_PERNR_ALV-ZGENDER_NAME = '여자'.
    ENDIF.

    PERFORM MAKE_BANKCODE USING GS_PERNR-ZBANKCODE
                          CHANGING GS_PERNR_ALV-ZBANK_NAME.

    APPEND GS_PERNR_ALV TO GT_PERNR_ALV.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_R1
*&---------------------------------------------------------------------*
FORM ALV_DISPLAY_R1 .

  PERFORM FIELD_CATALOG.
  PERFORM SET_LAYOUT.
  PERFORM SET_SORT.
  PERFORM CALL_ALV USING GT_PERNR_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA_R2
*&---------------------------------------------------------------------*
FORM SELECT_DATA_R2 .

  SELECT A~ZPERNR "사원번호
         B~ZRANK "평가등급
         C~ZSALARY "연봉
    INTO CORRESPONDING FIELDS OF TABLE GT_SALARY
    FROM ZEDT00_004 AS A  INNER JOIN ZEDT00_006 AS B
    ON A~ZPERNR = B~ZPERNR
    INNER JOIN ZEDT00_008 AS C
    ON A~ZPERNR = C~ZPERNR
    WHERE A~ZPERNR IN S_ZPERNR
    AND   A~ZQFLAG NE C_X
    AND   B~ZYEAR = P_YEAR
    AND   C~ZYEAR = P_YEAR.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_DEPCODE
*&---------------------------------------------------------------------*
FORM MAKE_DEPCODE USING P_ZEDPCODE
                  CHANGING P_ZEDPCODE_NAME.
  CASE P_ZEDPCODE.
    WHEN 'SS0001'.
      P_ZEDPCODE_NAME = '회계팀'.
    WHEN 'SS0002'.
      P_ZEDPCODE_NAME = '구매팀'.
    WHEN 'SS0003'.
      P_ZEDPCODE_NAME = '인사팀'.
    WHEN 'SS0004'.
      P_ZEDPCODE_NAME = '영업팀'.
    WHEN 'SS0005'.
      P_ZEDPCODE_NAME = '생산팀'.
    WHEN 'SS0006'.
      P_ZEDPCODE_NAME = '관리팀'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_RANK
*&---------------------------------------------------------------------*
FORM MAKE_RANK USING P_RANK
               CHANGING P_RANK_NAME.

  CASE P_RANK.
    WHEN 'A'.
      P_RANK_NAME = '인턴'.
    WHEN 'B'.
      P_RANK_NAME = '사원'.
    WHEN 'C'.
      P_RANK_NAME = '대리'.
    WHEN 'D'.
      P_RANK_NAME = '과장'.
    WHEN 'E'.
      P_RANK_NAME = '차장'.
    WHEN 'F'.
      P_RANK_NAME = '부장'.
    WHEN 'G'.
      P_RANK_NAME = '임원'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_BANKCODE
*&---------------------------------------------------------------------*
FORM MAKE_BANKCODE USING P_BANKCODE
                   CHANGING P_BANKNAME.
  CASE P_BANKCODE.
    WHEN '001'.
      P_BANKNAME = '신한'.
    WHEN '002'.
      P_BANKNAME = '우리'.
    WHEN '003'.
      P_BANKNAME = '하나'.
    WHEN '004'.
      P_BANKNAME = '국민'.
    WHEN '005'.
      P_BANKNAME = '카카오'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM FIELD_CATALOG.

  DATA : L_TEXT(10).

  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-SELTEXT_M = '사원번호'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPNAME'.
  GS_FIELDCAT-SELTEXT_M = '사원이름'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZDEPCODE'.
  GS_FIELDCAT-SELTEXT_M = '부서코드'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZDEPCODE_NAME'.
  GS_FIELDCAT-SELTEXT_M = '부서명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZDEPRANK_NAME'.
  GS_FIELDCAT-SELTEXT_M = '직급명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZEDATE'.
  GS_FIELDCAT-SELTEXT_M = '입사일'.
  GS_FIELDCAT-OUTPUTLEN = '10'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  IF P_R1 = C_X.
    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 7.
    GS_FIELDCAT-FIELDNAME = 'ZQFLAG_NAME'.
    GS_FIELDCAT-SELTEXT_M = '퇴직상태'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 8.
    GS_FIELDCAT-FIELDNAME = 'ZGENDER_NAME'.
    GS_FIELDCAT-SELTEXT_M = '성별'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 9.
    GS_FIELDCAT-FIELDNAME = 'ZADDRESS'.
    GS_FIELDCAT-SELTEXT_M = '주소'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 10.
    GS_FIELDCAT-FIELDNAME = 'ZBANKCODE'.
    GS_FIELDCAT-SELTEXT_M = '은행코드'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 11.
    GS_FIELDCAT-FIELDNAME = 'ZBANK_NAME'.
    GS_FIELDCAT-SELTEXT_M = '은행명'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 11.
    GS_FIELDCAT-FIELDNAME = 'ZACCOUNT'.
    GS_FIELDCAT-SELTEXT_M = '계좌번호'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
  ELSEIF P_R3 = 'X'.
    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 7.
    GS_FIELDCAT-FIELDNAME = 'ZSALARY'.
    GS_FIELDCAT-SELTEXT_M = '계약금액'.
    GS_FIELDCAT-OUTPUTLEN = '20'.
    GS_FIELDCAT-CURRENCY = 'KRW'.
    GS_FIELDCAT-DO_SUM = C_X.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 8.
    GS_FIELDCAT-FIELDNAME = 'ZRANK'.
    GS_FIELDCAT-SELTEXT_M = '평가등급'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT, L_TEXT.
    GS_FIELDCAT-COL_POS = 9.
    GS_FIELDCAT-FIELDNAME = 'ZMON'.
    CONCATENATE P_MON '월지급액' INTO L_TEXT.
    GS_FIELDCAT-SELTEXT_M = L_TEXT.
    GS_FIELDCAT-CURRENCY = 'KRW'.
    GS_FIELDCAT-DO_SUM = C_X.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_LAYOUT.

  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA = C_X.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_SORT
*&---------------------------------------------------------------------*
FORM SET_SORT.

  CLEAR : GS_SORT, GT_SORT.

  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = C_X.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
FORM CALL_ALV USING PT_ALV TYPE STANDARD TABLE.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     IT_FIELDCAT = GT_FIELDCAT
     IS_LAYOUT = GS_LAYOUT
     IT_SORT = GT_SORT
    TABLES
      T_OUTTAB = PT_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_R2.

  LOOP AT GT_SALARY INTO GS_SALARY.
    GS_SALARY-ZPAY = GS_SALARY-ZSALARY / 12.
    IF GS_SALARY-ZRANK = 'A'.
      GS_SALARY-ZPAY = GS_SALARY-ZPAY + '500.00'.
    ENDIF.

    CHECK GS_SALARY-ZPAY NE 0.

    PERFORM UPDATE_PAY USING GV_YEAR GV_MON
                             GS_SALARY-ZPERNR
                             GS_SALARY-ZPAY
                       CHANGING GV_CHECK.
    IF GV_CHECK = C_X.
      STOP.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA_R3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_DATA_R3.

  SELECT A~ZPERNR "사원번호
         B~ZPNAME "사원이름
         A~ZDEPCODE "부서코드
         A~ZDEPRANK "직급코드
         A~ZEDATE "입사일
         A~ZQFLAG "퇴직상태
         C~ZRANK "평가등급
         D~ZSALARY "계약금액
    INTO CORRESPONDING FIELDS OF TABLE GT_ASSESS
    FROM ZEDT00_004 AS A  INNER JOIN ZEDT00_005 AS B
    ON A~ZPERNR = B~ZPERNR
    INNER JOIN ZEDT00_006 AS C
    ON A~ZPERNR = C~ZPERNR
    INNER JOIN ZEDT00_008 AS D
    ON A~ZPERNR = D~ZPERNR
    WHERE A~ZPERNR IN S_ZPERNR
    AND   A~ZQFLAG NE C_X
    AND   C~ZYEAR = P_YEAR
    AND   D~ZYEAR = P_YEAR.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R3
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_R3.

  LOOP AT GT_ASSESS INTO GS_ASSESS.
    CLEAR : GS_ASSESS_ALV.
    MOVE-CORRESPONDING GS_ASSESS TO GS_ASSESS_ALV.


    PERFORM GET_PAY USING GV_YEAR GV_MON
                          GS_ASSESS_ALV-ZPERNR
                    CHANGING GS_ASSESS_ALV-ZMON.

    PERFORM MAKE_DEPCODE USING GS_ASSESS_ALV-ZDEPCODE
                         CHANGING GS_ASSESS_ALV-ZDEPCODE_NAME.
    PERFORM MAKE_RANK USING GS_ASSESS-ZDEPRANK
                      CHANGING GS_ASSESS_ALV-ZDEPRANK_NAME.

    APPEND GS_ASSESS_ALV TO GT_ASSESS_ALV.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_R3
*&---------------------------------------------------------------------*
FORM ALV_DISPLAY_R3.

  PERFORM FIELD_CATALOG.
  PERFORM SET_LAYOUT.
  PERFORM SET_SORT.
  PERFORM CALL_ALV USING GT_ASSESS_ALV.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_PAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L  text
*----------------------------------------------------------------------*
FORM GET_PAY USING PV_YEAR PV_MON P_ZPERNR
                   CHANGING P_ZMON.

  CASE PV_MON.
    WHEN '01'.
      SELECT SINGLE ZMON01 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '02'.
      SELECT SINGLE ZMON02 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '03'.
      SELECT SINGLE ZMON03 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '04'.
      SELECT SINGLE ZMON04 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '05'.
      SELECT SINGLE ZMON05 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '06'.
      SELECT SINGLE ZMON06 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '07'.
      SELECT SINGLE ZMON07 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '08'.
      SELECT SINGLE ZMON08 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '09'.
      SELECT SINGLE ZMON09 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '10'.
      SELECT SINGLE ZMON10 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '11'.
      SELECT SINGLE ZMON11 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
    WHEN '012'.
      SELECT SINGLE ZMON12 FROM ZEDT00_007 INTO P_ZMON
        WHERE ZPERNR = P_ZPERNR
        AND ZYEAR = PV_YEAR.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_PAY
*&---------------------------------------------------------------------*
FORM UPDATE_PAY USING PV_YEAR PV_MON P_ZPERNR P_ZPAY
                CHANGING PV_CHECK.

  CASE PV_MON.
    WHEN '01'.
      UPDATE ZEDT00_007 SET ZMON01 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '02'.
      UPDATE ZEDT00_007 SET ZMON02 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '03'.
      UPDATE ZEDT00_007 SET ZMON03 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '04'.
      UPDATE ZEDT00_007 SET ZMON04 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '05'.
      UPDATE ZEDT00_007 SET ZMON05 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '06'.
      UPDATE ZEDT00_007 SET ZMON06 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '07'.
      UPDATE ZEDT00_007 SET ZMON07 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '08'.
      UPDATE ZEDT00_007 SET ZMON08 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '09'.
      UPDATE ZEDT00_007 SET ZMON09 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '10'.
      UPDATE ZEDT00_007 SET ZMON10 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '11'.
      UPDATE ZEDT00_007 SET ZMON11 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
    WHEN '12'.
      UPDATE ZEDT00_007 SET ZMON12 = P_ZPAY
      WHERE ZPERNR = P_ZPERNR
      AND   ZYEAR = PV_YEAR.

      IF SY-SUBRC NE 0.
        PV_CHECK = C_X.
      ENDIF.
  ENDCASE.

ENDFORM.
