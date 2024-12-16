*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_IR_SCR
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  "송장 처리 : 구매오더, 플랜트, 송장 처리일(시스템변수)
  "송장 조회 : 구매오더, 플랜트
  PARAMETERS : P_EBELN TYPE ZEKKO07-EBELN. "구매오더
  PARAMETERS : P_WERKS TYPE ZEKPO07-WERKS. "플랜트
  PARAMETERS : P_BLDAT TYPE ZRBKP07-BLDAT DEFAULT SY-DATUM MODIF ID M1. "송장 처리일 (송장 처리 일때만 보임)
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  PARAMETERS : P_R1 RADIOBUTTON GROUP R1 USER-COMMAND UC1 DEFAULT 'X'. "송장 처리
  PARAMETERS : P_R2 RADIOBUTTON GROUP R1. "송장 조회
SELECTION-SCREEN END OF BLOCK B2.
