*&---------------------------------------------------------------------*
*& Report ZEDR07_PRACTICE005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_PRACTICE005 MESSAGE-ID ZMED07. "메세지 사용을 위해 추가함

TABLES : ZEDT07_004,ZEDT07_007, ZEDT07_006, ZEDT07_008.
RANGES : R_QFLAG FOR ZEDT07_004-ZQFLAG. "퇴직여부 체크조건 제어를 위한 RANGES
CONSTANTS C_BONUS TYPE P LENGTH 6 DECIMALS 2 VALUE '500.00'.

*****1. 데이터 선언
" 사원정보 관련 구조체
DATA : BEGIN OF GS_WORKER.
  DATA : ZPERNR TYPE ZEDT07_004-ZPERNR. "사원번호
  DATA : ZPNAME TYPE ZEDT07_005-ZPNAME. "이름
  DATA : ZDEPCODE TYPE ZEDT07_004-ZDEPCODE. "부서코드
  DATA : ZDNAME TYPE STR. "부서명(4-부서코드ZDEPCODE에서 가져오기)
  DATA : ZDRNAME TYPE STR. "직급명(4-직급코드ZDEPRANK에서 가져오기) -> 출력
  DATA : ZDEPRANK TYPE ZEDT07_004-ZDEPRANK. "직급명 -> 가져오기 위해
  DATA : ZEDATE TYPE ZEDT07_004-ZEDATE. "입사일자
  DATA : ZQFLAG TYPE ZEDT07_004-ZQFLAG. "퇴사상태
  DATA : ZQNAME TYPE STR. "퇴사상태 출력을 위해(퇴직, 재직)
  DATA : ZGENDER TYPE ZEDT07_005-ZGENDER. "성별
  DATA : ZGENNAME TYPE STR. "성별 출력을 위함
  DATA : ZADDRESS TYPE ZEDT07_005-ZADDRESS. "주소
  DATA : ZBANKCODE TYPE ZEDT07_008-ZBANKCODE. "은행코드
  DATA : ZBANKNAME TYPE STR. "은행명(8-은행코드ZBANKCODE에서 가져오기)
  DATA : ZACCOUNT TYPE ZEDT07_008-ZACCOUNT. "계좌번호
  DATA END OF GS_WORKER.
DATA : GT_WORKER LIKE TABLE OF GS_WORKER. "인터널테이블 선언

" 월급지급 관련 구조체
DATA : BEGIN OF GS_PAYROLL.
  DATA : ZPERNR TYPE ZEDT07_004-ZPERNR. "사원번호
  DATA : ZQFLAG TYPE ZEDT07_004-ZQFLAG. "퇴사상태
  DATA : ZYEAR TYPE ZEDT07_006-ZYEAR. "평가년도
  DATA : ZRANK TYPE ZEDT07_006-ZRANK. "평가등급
  DATA : ZSALARY TYPE ZEDT07_008-ZSALARY. "연봉
  DATA END OF GS_PAYROLL.
DATA : GT_PAYROLL LIKE TABLE OF GS_PAYROLL.

"월급(월마다 지급된 내역)관련 구조체
DATA : BEGIN OF GS_MONSAL.
  DATA : ZPERNR TYPE ZEDT07_007-ZPERNR. "사원번호
  DATA : ZYEAR TYPE ZEDT07_007-ZYEAR. "지급년도
  DATA : ZMON01 TYPE ZEDT07_007-ZMON01. "1월급여
  DATA : ZMON02 TYPE ZEDT07_007-ZMON02. "2월급여
  DATA : ZMON03 TYPE ZEDT07_007-ZMON03. "3월급여
  DATA : ZMON04 TYPE ZEDT07_007-ZMON04. "4월급여
  DATA : ZMON05 TYPE ZEDT07_007-ZMON05. "5월급여
  DATA : ZMON06 TYPE ZEDT07_007-ZMON06. "6월급여
  DATA : ZMON07 TYPE ZEDT07_007-ZMON07. "7월급여
  DATA : ZMON08 TYPE ZEDT07_007-ZMON08. "8월급여
  DATA : ZMON09 TYPE ZEDT07_007-ZMON09. "9월급여
  DATA : ZMON10 TYPE ZEDT07_007-ZMON10. "10월급여
  DATA : ZMON11 TYPE ZEDT07_007-ZMON11. "11월급여
  DATA : ZMON12 TYPE ZEDT07_007-ZMON12. "12월급여
  DATA END OF GS_MONSAL.
DATA : GT_MONSAL LIKE TABLE OF GS_MONSAL.

"평가확인에 필요한 구조체선언
DATA : BEGIN OF GS_CHECK.
  DATA : WORKER LIKE GS_WORKER.
  DATA : PAYROLL LIKE GS_PAYROLL.
  DATA : MONSAL LIKE GS_MONSAL.
DATA END OF GS_CHECK.
DATA : GT_CHECK LIKE TABLE OF GS_CHECK.

" 필드 카탈로그 관련 데이터 선언
DATA : GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

" 레이아웃 관련 데이터 선언
DATA : GS_LAYOUT TYPE SLIS_LAYOUT_ALV.

" 정렬 관련 데이터 선언
DATA : GS_SORT TYPE SLIS_SORTINFO_ALV.
DATA : GT_SORT TYPE SLIS_T_SORTINFO_ALV.

*****2. 스크린
"검색 정보 입력
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  SELECT-OPTIONS : S_ZPERNR FOR ZEDT07_004-ZPERNR. "사원번호
  SELECT-OPTIONS : S_DATE FOR ZEDT07_004-DATBI MODIF ID M1 NO-EXTENSION.
  SELECT-OPTIONS : S_ZDCODE FOR ZEDT07_004-ZDEPCODE MODIF ID M1 NO INTERVALS NO-EXTENSION.
  PARAMETERS : S_YEAR LIKE ZEDT07_007-ZYEAR MODIF ID M2 DEFAULT SY-DATUM(4). "연도 (시스템 연도 고정)
  PARAMETERS : S_MONTH TYPE C LENGTH 2 MODIF ID M2 DEFAULT SY-DATUM+4(2). "월(시스템 월 고정)
SELECTION-SCREEN END OF BLOCK B1.

"라디오 버튼 입력
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  PARAMETERS : P_R1 RADIOBUTTON GROUP R1 USER-COMMAND UC1 DEFAULT 'X'.
  PARAMETERS : P_R2 RADIOBUTTON GROUP R1.
  PARAMETERS : P_R3 RADIOBUTTON GROUP R1.
SELECTION-SCREEN END OF BLOCK B2.

"재직여부 체크박스
SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME.
  PARAMETERS : Z_CHECK AS CHECKBOX DEFAULT 'X' MODIF ID M1.
SELECTION-SCREEN END OF BLOCK B3.

*****3. 초기값 설정
INITIALIZATION.
  PERFORM SET_DATE.

*****4. 스크린 제어
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.

*****5. MAIN PROGRAM
START-OF-SELECTION.
  PERFORM CHECK_DATA. "필수 조회조건값이 들어가있는지 확인하기 위한 함수

  IF P_R1 = 'X'. "사원 정보를 선택한 경우
    PERFORM GET_DATA_R1.
    IF GT_WORKER[] IS INITIAL. "조회조건내 데이터가 없을시 메세지문으로 처리
      MESSAGE I001.
      EXIT.
    ENDIF.
    PERFORM MODIFY_DATA_R1.
    PERFORM ALV_DISPLAY_R1.
  ELSEIF P_R2 = 'X'. "월급 지급을 선택한 경우
    PERFORM GET_DATA_R2.
    IF GT_PAYROLL[] IS INITIAL. "조회조건 내 데이터가 없을시 메세지문으로 처리
      MESSAGE I001.
      EXIT.
    ENDIF.
    PERFORM MODIFY_DATA_R2.
  ELSEIF P_R3 = 'X'. "평가 정보를 선택한 경우

    PERFORM GET_DATA_R1.
    IF GT_WORKER[] IS INITIAL.
      MESSAGE I001.
      EXIT.
    ENDIF.
    PERFORM MODIFY_DATA_R1.

    PERFORM GET_DATA_R2.
    IF GT_PAYROLL[] IS INITIAL.
      MESSAGE I001.
      EXIT.
    ENDIF.

    PERFORM GET_DATA_R3.
    PERFORM ALV_DISPLAY_R3.

  ENDIF.
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .
  IF P_R1 = 'X'. "사원정보 조회시 -> 기간 필수 입력
    IF S_DATE IS INITIAL.
      MESSAGE I000. "에러메세지 처리
      STOP.
    ENDIF.
  ELSE. "월급지급, 평가확인 조회시 -> 년도와 월 필수 입력
    IF ( S_YEAR IS INITIAL ) OR ( S_MONTH IS INITIAL ).
      MESSAGE I000. "에러메세지 처리
      STOP.
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

  CLEAR R_QFLAG.

   " 재직여부에 체크한 경우 퇴사자는 보이면 안됨 (즉, 체크하지 않은 경우는 "", "X" 상태모두 가져와야 함)
  IF Z_CHECK = 'X'.
    " 재직여부 체크한 경우: 퇴사자 보이지 않음
    R_QFLAG-SIGN = 'E'.      " 제외
    R_QFLAG-OPTION = 'EQ'.   " = 조건
    R_QFLAG-LOW = 'X'.       " X 상태만 선택
  ELSE.
    " 체크하지 않은 경우: 재직상태 모두 가져오기
    R_QFLAG-SIGN = 'I'.      " 포함
    R_QFLAG-OPTION = 'BT'.   " BETWEEN 조건
    R_QFLAG-LOW = ' '.       " 공백부터
    R_QFLAG-HIGH = 'X'.      " X까지
  ENDIF.
    APPEND R_QFLAG.
  SELECT "DB에 있는 필드값들만 쓸 수 있음
    A~ZPERNR "사원번호
    B~ZPNAME "이름
    A~ZDEPCODE "부서코드
    A~ZDEPRANK "직급명
    A~ZEDATE "입사일자
    A~ZQFLAG "퇴사상태
    B~ZGENDER "성별
    B~ZADDRESS "주소
    C~ZBANKCODE "은행코드
    C~ZACCOUNT "계좌번호
  FROM ZEDT07_004 AS A
  INNER JOIN ZEDT07_005 AS B ON A~ZPERNR = B~ZPERNR
  INNER JOIN ZEDT07_008 AS C ON A~ZPERNR = C~ZPERNR
  INTO CORRESPONDING FIELDS OF TABLE GT_WORKER
  WHERE A~ZPERNR IN S_ZPERNR "사원번호 조건
    AND A~ZDEPCODE IN S_ZDCODE "부서코드 조건
    AND A~ZQFLAG IN R_QFLAG "퇴사상태 조건
    AND A~DATBI => S_DATE-LOW "유효기간 시작일이 사용자가 입력한 시작일보다 크거나 같아야 함
    AND A~DATAB > S_DATE-HIGH "유효기간이 종료일보다 입력한 종료일이 작아야 함
    .
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY_R1.
  PERFORM FIELD_CATALOG_R1.
  PERFORM ALV_LAYOUT.
  PERFORM ALV_SORT.
  PERFORM CALL_ALV_R1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG_R1.
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-SELTEXT_M = '사원번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPNAME'.
  GS_FIELDCAT-SELTEXT_M = '이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZDEPCODE'.
  GS_FIELDCAT-SELTEXT_M = '부서코드'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZDNAME'.
  GS_FIELDCAT-SELTEXT_M = '부서명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZDRNAME'.
  GS_FIELDCAT-SELTEXT_M = '직급명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZEDATE'.
  GS_FIELDCAT-SELTEXT_M = '입사일자'.
  GS_FIELDCAT-OUTPUTLEN = 10. "문자 열 너비 설정
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZQNAME'.
  GS_FIELDCAT-SELTEXT_M = '퇴사상태'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'ZGENNAME'.
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
  GS_FIELDCAT-FIELDNAME = 'ZBANKNAME'.
  GS_FIELDCAT-SELTEXT_M = '은행명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 12.
  GS_FIELDCAT-FIELDNAME = 'ZACCOUNT'.
  GS_FIELDCAT-SELTEXT_M = '계좌번호'.
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
*&      Form  CALL_ALV_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_ALV_R1.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     IS_LAYOUT                         = GS_LAYOUT
     IT_FIELDCAT                       = GT_FIELDCAT
    TABLES
      T_OUTTAB                          = GT_WORKER.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_R1.
  LOOP AT GT_WORKER INTO GS_WORKER.

    CASE GS_WORKER-ZDEPCODE.
      WHEN 'SS0001'.
        GS_WORKER-ZDNAME = '회계팀'.
      WHEN 'SS0002'.
        GS_WORKER-ZDNAME = '구매팀'.
      WHEN 'SS0003'.
        GS_WORKER-ZDNAME = '인사팀'.
      WHEN 'SS0004'.
        GS_WORKER-ZDNAME = '영업팀'.
      WHEN 'SS0005'.
        GS_WORKER-ZDNAME = '생산팀'.
      WHEN 'SS0006'.
        GS_WORKER-ZDNAME = '관리팀'.
    ENDCASE.

    CASE GS_WORKER-ZDEPRANK.
      WHEN 'A'.
        GS_WORKER-ZDRNAME = '인턴'.
      WHEN 'B'.
        GS_WORKER-ZDRNAME = '사원'.
      WHEN 'C'.
        GS_WORKER-ZDRNAME = '대리'.
      WHEN 'D'.
        GS_WORKER-ZDRNAME = '과장'.
      WHEN 'E'.
        GS_WORKER-ZDRNAME = '차장'.
      WHEN 'F'.
        GS_WORKER-ZDRNAME = '부장'.
      WHEN 'G'.
        GS_WORKER-ZDRNAME = '임원'.
    ENDCASE.

    CASE GS_WORKER-ZBANKCODE.
      WHEN '001'.
        GS_WORKER-ZBANKNAME = '신한'.
      WHEN '002'.
        GS_WORKER-ZBANKNAME = '우리'.
      WHEN '003'.
        GS_WORKER-ZBANKNAME = '하나'.
      WHEN '004'.
        GS_WORKER-ZBANKNAME = '국민'.
      WHEN '005'.
        GS_WORKER-ZBANKNAME = '카카오'.
    ENDCASE.

    IF GS_WORKER-ZQFLAG = 'X'.
      GS_WORKER-ZQNAME = '퇴직'.
    ELSE.
      GS_WORKER-ZQNAME = '재직'.
    ENDIF.

    IF GS_WORKER-ZGENDER = 'M'.
      GS_WORKER-ZGENNAME = '남자'.
    ELSEIF GS_WORKER-ZGENDER = 'F'.
      GS_WORKER-ZGENNAME = '여자'.
    ENDIF.

    MODIFY GT_WORKER FROM GS_WORKER INDEX SY-TABIX.
  ENDLOOP.

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
  GS_SORT-FIELDNAME = 'ZPERNR'. "정렬 기준
  GS_SORT-UP = 'X'. "오름차순
  APPEND GS_SORT TO GT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATE .
  IF S_DATE[] IS INITIAL. "날짜 초기값 설정
    CONCATENATE SY-DATUM(4) '01' '01' INTO S_DATE-LOW. "시스템연도(4) 01 01로 LOW값 초기 설정
    S_DATE-HIGH = SY-DATUM.  "현재날짜로 HIGH값 초기 설정
    S_DATE-SIGN = 'I'.
    S_DATE-OPTION = 'BT'.

    APPEND S_DATE.
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
"라디오 선택에 따라 보이는 입력 스크린이 달라지도록 함
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
      IF P_R1 = 'X'.
        SCREEN-ACTIVE = '1'.
      ELSEIF P_R2 = 'X'.
        SCREEN-ACTIVE = '0'.
      ELSEIF P_R3 = 'X'.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'.
      IF P_R1 = 'X'.
        SCREEN-ACTIVE = '0'.
      ELSEIF P_R2 = 'X'.
        SCREEN-ACTIVE = '1'.
      ELSEIF P_R3 = 'X'.
        SCREEN-ACTIVE = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
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
  SELECT
    A~ZPERNR "사원번호
    A~ZQFLAG "퇴사여부
    B~ZYEAR "평가연도
    B~ZRANK "평가등급
    C~ZSALARY "연봉
  FROM ZEDT07_004 AS A
  INNER JOIN ZEDT07_006 AS B ON A~ZPERNR = B~ZPERNR
  INNER JOIN ZEDT07_008 AS C ON A~ZPERNR = C~ZPERNR
  INTO CORRESPONDING FIELDS OF TABLE GT_PAYROLL
  WHERE A~ZPERNR IN S_ZPERNR "사원번호 조건
  AND A~ZQFLAG NE 'X' "퇴사처리된 아이디는 지급에서 제외
  AND B~ZYEAR = S_YEAR "해당연도에 대한 평가데이터가 있어야 함
  .

  SELECT
    A~ZPERNR
    A~ZYEAR
    A~ZMON01
    A~ZMON02
    A~ZMON03
    A~ZMON04
    A~ZMON05
    A~ZMON06
    A~ZMON07
    A~ZMON08
    A~ZMON09
    A~ZMON10
    A~ZMON11
    A~ZMON12
  FROM ZEDT07_007 AS A
  INTO CORRESPONDING FIELDS OF TABLE GT_MONSAL.
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
  DATA : LV_SALARY TYPE P DECIMALS 2, "월급
         LV_BONUS TYPE P DECIMALS 2, "보너스
         LV_UPDATE_SUCCESS TYPE C VALUE 'X'. "업데이트를 성공했는지의 여부

* WRITE :/ '---------- 변경전 -------'.
* LOOP AT GT_PAYROLL INTO GS_PAYROLL.
*   WRITE :/ GS_PAYROLL-ZPERNR, GS_PAYROLL-ZQFLAG, GS_PAYROLL-ZYEAR, GS_PAYROLL-ZRANK, GS_PAYROLL-ZSALARY.
*
* ENDLOOP.

  LOOP AT GT_MONSAL INTO GS_MONSAL.
    LOOP AT GT_PAYROLL INTO GS_PAYROLL.
      IF GS_PAYROLL-ZPERNR = GS_MONSAL-ZPERNR AND GS_PAYROLL-ZYEAR = GS_MONSAL-ZYEAR.

         LV_SALARY = GS_PAYROLL-ZSALARY / 12. "월급은 연봉의 1/12
         LV_BONUS = 0. "보너스 일단 0으로 초기화

         "평가가 A인 경우 보너스
          IF GS_PAYROLL-ZRANK = 'A'.
           LV_BONUS = C_BONUS.
          ENDIF.

         "월급 업데이트 함수 호출
          PERFORM UPDATE_MONTHLY_FIELD USING S_MONTH CHANGING GS_MONSAL LV_SALARY LV_BONUS.

          "DB 변경하는 함수 호출
          PERFORM UPDATE_DB_MONSAL USING GS_MONSAL.

          IF SY-SUBRC <> 0.
            MESSAGE I002.
            LV_UPDATE_SUCCESS = ''.
            EXIT.
          ENDIF.

      ENDIF.
    ENDLOOP.

* WRITE :/ '---------- 변경후---'.
* LOOP AT GT_MONSAL INTO GS_MONSAL.
* WRITE :/ GS_MONSAL-ZPERNR, GS_MONSAL-ZYEAR, GS_MONSAL-ZMON01, GS_MONSAL-ZMON02, GS_MONSAL-ZMON03, GS_MONSAL-ZMON04, GS_MONSAL-ZMON05, GS_MONSAL-ZMON06, GS_MONSAL-ZMON07, GS_MONSAL-ZMON08, GS_MONSAL-ZMON09, GS_MONSAL-ZMON10, GS_MONSAL-ZMON11,
*S_MONSAL-ZMON12.

ENDLOOP.

"모든 업데이트가 성공했는지 확인
IF LV_UPDATE_SUCCESS = 'X'.
  MESSAGE I003.
ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MONTHLY_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_MONTH  text
*      <--P_GS_MONSAL  text
*      <--P_LV_SALARY  text
*      <--P_LV_BONUS  text
*----------------------------------------------------------------------*
FORM UPDATE_MONTHLY_FIELD  USING    P_MONTH
                           CHANGING P_MONSAL LIKE GS_MONSAL
                                    P_SALARY
                                    P_BONUS.

    CASE P_MONTH.
      WHEN 1.
        P_MONSAL-ZMON01 = P_SALARY.
        P_MONSAL-ZMON01 = P_MONSAL-ZMON01 + P_BONUS.
      WHEN 2.
        P_MONSAL-ZMON02 = P_SALARY.
        P_MONSAL-ZMON02 = P_MONSAL-ZMON02 + P_BONUS.
      WHEN 3.
        P_MONSAL-ZMON03 = P_SALARY.
        P_MONSAL-ZMON03 = P_MONSAL-ZMON03 + P_BONUS.
      WHEN 4.
        P_MONSAL-ZMON04 = P_SALARY.
        P_MONSAL-ZMON04 = P_MONSAL-ZMON04 + P_BONUS.
      WHEN 5.
        P_MONSAL-ZMON05 = P_SALARY.
        P_MONSAL-ZMON05 = P_MONSAL-ZMON05 + P_BONUS.
      WHEN 6.
        P_MONSAL-ZMON06 = P_SALARY.
        P_MONSAL-ZMON06 = P_MONSAL-ZMON06 + P_BONUS.
      WHEN 7.
        P_MONSAL-ZMON07 = P_SALARY.
        P_MONSAL-ZMON07 = P_MONSAL-ZMON07 + P_BONUS.
      WHEN 8.
        P_MONSAL-ZMON08 = P_SALARY.
        P_MONSAL-ZMON08 = P_MONSAL-ZMON08 + P_BONUS.
      WHEN 9.
        P_MONSAL-ZMON09 = P_SALARY.
        P_MONSAL-ZMON09 = P_MONSAL-ZMON09 + P_BONUS.
      WHEN 10.
        P_MONSAL-ZMON10 = P_SALARY.
        P_MONSAL-ZMON10 = P_MONSAL-ZMON10 + P_BONUS.
      WHEN 11.
        P_MONSAL-ZMON11 = P_SALARY.
        P_MONSAL-ZMON11 = P_MONSAL-ZMON11 + P_BONUS.
      WHEN 12.
        P_MONSAL-ZMON12 = P_SALARY.
        P_MONSAL-ZMON12 = P_MONSAL-ZMON12 + P_BONUS.
    ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DB_MONSAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_MONSAL  text
*----------------------------------------------------------------------*
FORM UPDATE_DB_MONSAL  USING   P_MONSAL LIKE GS_MONSAL.
      UPDATE ZEDT07_007
           SET ZMON01 = P_MONSAL-ZMON01
               ZMON02 = P_MONSAL-ZMON02
               ZMON03 = P_MONSAL-ZMON03
               ZMON04 = P_MONSAL-ZMON04
               ZMON05 = P_MONSAL-ZMON05
               ZMON06 = P_MONSAL-ZMON06
               ZMON07 = P_MONSAL-ZMON07
               ZMON08 = P_MONSAL-ZMON08
               ZMON09 = P_MONSAL-ZMON09
               ZMON10 = P_MONSAL-ZMON10
               ZMON11 = P_MONSAL-ZMON11
               ZMON12 = P_MONSAL-ZMON12
               CRNAME = SY-UNAME
               CRDATE = SY-DATUM
               CRZEIT = SY-UZEIT
       WHERE ZPERNR = P_MONSAL-ZPERNR AND ZYEAR = P_MONSAL-ZYEAR.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_R3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_R3 .
  DATA: LV_CHECK LIKE GS_CHECK,
        LV_WORKER LIKE GS_WORKER,
        LV_PAYROLL LIKE GS_PAYROLL,
        LV_MONSAL LIKE GS_MONSAL.

   LOOP AT GT_WORKER INTO LV_WORKER.
     READ TABLE GT_PAYROLL INTO LV_PAYROLL WITH KEY ZPERNR = LV_WORKER-ZPERNR.

     READ TABLE GT_MONSAL INTO LV_MONSAL WITH KEY ZPERNR = LV_WORKER-ZPERNR.

     CLEAR LV_CHECK.
     LV_CHECK-WORKER = LV_WORKER.
     LV_CHECK-PAYROLL = LV_PAYROLL.
     LV_CHECK-MONSAL = LV_MONSAL.

     "마스터에 퇴사처리된 아이디는 평가확인에서 제외
     CHECK LV_CHECK-WORKER-ZQFLAG NE 'X'. "퇴사처리가 아닌 아이디만 추가
       APPEND LV_CHECK TO GT_CHECK.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_R3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY_R3 .
  PERFORM FIELD_CATALOG_R3.
  PERFORM ALV_LAYOUT.
  PERFORM ALV_SORT.
  PERFORM CALL_ALV_R3.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG_R3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG_R3 .
    CLEAR : GS_FIELDCAT, GT_FIELDCAT.
    GS_FIELDCAT-COL_POS = 1.
    GS_FIELDCAT-FIELDNAME = 'WORKER-ZPERNR'.
    GS_FIELDCAT-SELTEXT_M = '사원번호'.
    GS_FIELDCAT-KEY = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

   CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'WORKER-ZPNAME'.
  GS_FIELDCAT-SELTEXT_M = '이름'.
  GS_FIELDCAT-KEY = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'WORKER-ZDEPCODE'.
  GS_FIELDCAT-SELTEXT_M = '부서코드'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'WORKER-ZDNAME'.
  GS_FIELDCAT-SELTEXT_M = '부서명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'WORKER-ZDRNAME'.
  GS_FIELDCAT-SELTEXT_M = '직급명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'WORKER-ZEDATE'.
  GS_FIELDCAT-SELTEXT_M = '입사일자'.
  GS_FIELDCAT-OUTPUTLEN = 10. "문자 열 너비 설정
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'PAYROLL-ZSALARY'.
  GS_FIELDCAT-SELTEXT_M = '계약금액'.
  GS_FIELDCAT-CURRENCY = 'KRW'. "한화로 표기
  GS_FIELDCAT-DO_SUM = 'X'. "합계표기
  GS_FIELDCAT-OUTPUTLEN = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'PAYROLL-ZRANK'.
  GS_FIELDCAT-SELTEXT_M = '평가등급'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 9.

  CASE S_MONTH.
    WHEN 1.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON01'.
      GS_FIELDCAT-SELTEXT_M = '1월지급액'.
    WHEN 2.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON02'.
      GS_FIELDCAT-SELTEXT_M = '2월지급액'.
    WHEN 3.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON03'.
      GS_FIELDCAT-SELTEXT_M = '3월지급액'.
    WHEN 4.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON04'.
      GS_FIELDCAT-SELTEXT_M = '4월지급액'.
    WHEN 5.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON05'.
      GS_FIELDCAT-SELTEXT_M = '5월지급액'.
    WHEN 6.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON06'.
      GS_FIELDCAT-SELTEXT_M = '6월지급액'.
    WHEN 7.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON07'.
      GS_FIELDCAT-SELTEXT_M = '7월지급액'.
    WHEN 8.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON08'.
      GS_FIELDCAT-SELTEXT_M = '8월지급액'.
    WHEN 9.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON09'.
      GS_FIELDCAT-SELTEXT_M = '9월지급액'.
    WHEN 10.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON10'.
      GS_FIELDCAT-SELTEXT_M = '10월지급액'.
    WHEN 11.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON11'.
      GS_FIELDCAT-SELTEXT_M = '11월지급액'.
    WHEN 12.
      GS_FIELDCAT-FIELDNAME = 'MONSAL-ZMON12'.
      GS_FIELDCAT-SELTEXT_M = '12월지급액'.
  ENDCASE.
  GS_FIELDCAT-CURRENCY = 'KRW'.
  GS_FIELDCAT-DO_SUM = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 20.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV_R3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_ALV_R3 .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     IS_LAYOUT                         = GS_LAYOUT
     IT_FIELDCAT                       = GT_FIELDCAT
    TABLES
      T_OUTTAB                          = GT_CHECK.
      .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
