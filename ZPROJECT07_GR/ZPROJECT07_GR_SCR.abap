*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_GR_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  "입고 처리 : 구매오더, 플랜트, 입고처리일(시스템변수)  ZEKKO07
  "입고 조회 : 구매오더, 플랜트
  PARAMETERS : P_EBELN TYPE ZMSEG07-EBELN.  "구매오더
  PARAMETERS : P_WERKS TYPE ZMSEG07-WERKS. "플랜트
  PARAMETERS : P_BLDAT TYPE ZMKPF07-BLDAT DEFAULT SY-DATUM MODIF ID M1. "입고 처리일 (입고 처리 시에만 보임)
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  PARAMETERS : P_R1 RADIOBUTTON GROUP R1 USER-COMMAND UC1 DEFAULT 'X'. "입고 처리
  PARAMETERS : P_R2 RADIOBUTTON GROUP R1. "입고 조회
SELECTION-SCREEN END OF BLOCK B2.
