*&---------------------------------------------------------------------*
*& Report ZPROJECT07_IR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROJECT07_IR MESSAGE-ID ZMED07.

INCLUDE ZPROJECT07_IR_CLS.
INCLUDE ZPROJECT07_IR_TOP.
INCLUDE ZPROJECT07_IR_SCR.
INCLUDE ZPROJECT07_IR_F01.
INCLUDE ZPROJECT07_IR_PBO.
INCLUDE ZPROJECT07_IR_PAI.

"스크린 제어
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.

START-OF-SELECTION.
  PERFORM CHECK_INITIAL_DATA.

  IF P_R1 = C_X.
    PERFORM GET_PO_DATA.
    CALL SCREEN 200.
  ELSEIF P_R2 = C_X.
    PERFORM GET_IR_DATA.
    CALL SCREEN 300.
  ENDIF.
