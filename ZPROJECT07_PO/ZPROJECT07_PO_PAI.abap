*&---------------------------------------------------------------------*
*&  Include           ZPROJECT07_PO_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE OK_CODE.
      WHEN 'ADD'. "ADD 버튼 클릭 시
        CLEAR GS_ALV_ROW.
*       PERFORM ADD_ROW_TO_ALV.
        APPEND GS_ALV_ROW TO GT_ALV_DATA.
        PERFORM REFRESH.
     WHEN 'REMOVE'. "REMOVE 버튼 클릭시
        PERFORM REMOVE_ROW_FROM_ALV.
        PERFORM REFRESH.
     WHEN 'SAVE'.
       PERFORM VALIDATE_AND_SAVE.
   ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE OK_CODE.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

ENDMODULE.
