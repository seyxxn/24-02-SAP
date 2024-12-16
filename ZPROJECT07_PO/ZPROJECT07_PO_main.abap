*&---------------------------------------------------------------------*
*& Report ZPROJECT07_PO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROJECT07_PO MESSAGE-ID ZMED07.

INCLUDE ZPROJECT07_PO_CLS.
INCLUDE ZPROJECT07_PO_TOP.
INCLUDE ZPROJECT07_PO_SCR.
INCLUDE ZPROJECT07_PO_F01.
INCLUDE ZPROJECT07_PO_PBO.
INCLUDE ZPROJECT07_PO_PAI.

"스크린 제어
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.

START-OF-SELECTION.
  PERFORM CHECK_INITIAL_DATA.

  IF P_R1 = C_X.
   CALL SCREEN 200.
  ELSEIF P_R2 = C_X.
   PERFORM GET_DATA.
   CALL SCREEN 300.
  ENDIF.
