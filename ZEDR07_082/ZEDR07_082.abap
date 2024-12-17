*&---------------------------------------------------------------------*
*& Report ZEDR16_015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR17_081.
DATA : GS_STUDENT TYPE ZEDT16_002.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT.

"필드 카탈로글르 사용해서 인터널테이블과 구조체를 선언하는 것이다.
DATA : GS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.
DATA : GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.



TABLES : ZEDT16_002.  "테이블을 받아서 쓸수 있게 만들어준다.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  SELECT-OPTIONS : S_ZCODE FOR ZEDT16_002-ZCODE. "범위를 주고 선택하게 할 때는 SELECT OPTIONS를 사용하는 것이다.
*  PARAMETERS : P_ZPERNR LIKE ZEDT16_001-ZPERNR.
*  PARAMETERS : P_ZGEN LIKE ZEDT16_001-ZGENDER DEFAULT 'M' MODIF ID SC1.
SELECTION-SCREEN END OF BLOCK B1.

INITIALIZATION.
S_ZCODE-LOW = 'SSU-01'.
S_ZCODE-HIGH = 'SSU-99'.
APPEND S_ZCODE.

*AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN. "스크린에 나오는 것들을 반복하면서 진행한다는 뜻이다.
*    IF SCREEN-GROUP1 = 'SC1'.
*      SCREEN-INPUT = 0.
*    ENDIF.
*    MODIFY SCREEN. "결국에 이걸 해줘야지 SCREEN에 결과값이 반영되게끔 되는 것이다.
* ENDLOOP.

"INITIALIZATION이 있다면 START OF SELECTION을 반드시 붙혀야 한다.

START-OF-SELECTION.
  PERFORM GET_DATA.
*  PERFORM MODIFY_DATA.
END-OF-SELECTION.
  PERFORM ALV_DISPLAY.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .
  PERFORM FIELD_CATALOG.
  PERFORM CALL_ALV.
ENDFORM.

FORM CALL_ALV.
 CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IT_FIELDCAT = GT_FIELDCAT
    TABLES
      T_OUTTAB = GT_STUDENT.
ENDFORM.

FORM GET_DATA .
  SELECT * FROM ZEDT16_002
    INTO CORRESPONDING FIELDS OF TABLE GT_STUDENT
    WHERE ZCODE IN S_ZCODE.
ENDFORM.

"카탈로그에 필드를 채워나가는 FORM이다.
"이렇게 필드 카탈로그를 채워나가면서 ALV로 보이는 화면을 설정할 수 있다.
"각각의 필드 카탈로그가 어떤 역할을 하는지 정리하면서 나아갈 수 있다.

FORM FIELD_CATALOG .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1. "이것은 컬럼의 OUTPUT순서를 결정하는 것이다.
  GS_FIELDCAT-FIELDNAME = 'ZCODE'. "필드 카탈로그의 필드 이름을 나타내는 것이다. ALV를 출력할 때 사용하게 되면 인터널테이블의 필드 이름과 같아야한다.
  GS_FIELDCAT-SELTEXT_M = '학생코드'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-JUST = 'L'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'. "필드 이름을 제대로 설정하지 않으면 전에 것과 같은 값이 나오게 되는 것이다.
  GS_FIELDCAT-SELTEXT_M = '출석번호'.
  GS_FIELDCAT-JUST = 'C'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZKNAME'.
  GS_FIELDCAT-SELTEXT_M = '이름'.
  GS_FIELDCAT-JUST = 'R'.
  GS_FIELDCAT-NO_OUT = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZMNAME'.
  GS_FIELDCAT-SELTEXT_M = '전공명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZSUM'.
  GS_FIELDCAT-SELTEXT_M = '등록금액'.
  GS_FIELDCAT-DO_SUM = 'X'.
  GS_FIELDCAT-CURRENCY = 'KRW'.
  GS_FIELDCAT-NO_ZERO = 'X'.
  GS_FIELDCAT-NO_SIGN = 'X'.
  GS_FIELDCAT-OUTPUTLEN = 20.
  GS_FIELDCAT-EMPHASIZE = 'X'.
  GS_FIELDCAT-EDIT = 'X'.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-SELTEXT_M = '통화'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

*  CLEAR : GS_FIELDCAT.
*  GS_FIELDCAT-COL_POS = 7.
*  GS_FIELDCAT-FIELDNAME = 'CRDATE'.
*  GS_FIELDCAT-SELTEXT_M = '생성일'.
*  GS_FIELDCAT-EDIT_MASK = '____-__-__'.
*  APPEND GS_FIELDCAT TO GT_FIELDCAT.
ENDFORM.
