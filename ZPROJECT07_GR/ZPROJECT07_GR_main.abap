*&---------------------------------------------------------------------*
*& Report ZPROJECT07_GR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROJECT07_GR MESSAGE-ID ZMED07.

INCLUDE ZPROJECT07_GR_CLS.
INCLUDE ZPROJECT07_GR_TOP.
INCLUDE ZPROJECT07_GR_SCR.
INCLUDE ZPROJECT07_GR_F01.
INCLUDE ZPROJECT07_GR_PBO.
INCLUDE ZPROJECT07_GR_PAI.

"스크린 제어
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.

START-OF-SELECTION.
  PERFORM CHECK_INITIAL_DATA.

  IF P_R1 = C_X.
    PERFORM GET_PO_DATA.
    CALL SCREEN 200.
  ELSEIF P_R2 = C_X.
    PERFORM GET_GR_DATA.
    CALL SCREEN 300.
  ENDIF.
