*&---------------------------------------------------------------------*
*&  Include           ZEDT01_HW003_PAI
*&---------------------------------------------------------------------*

MODULE USER_COMMAND_0100 INPUT.


ENDMODULE.

MODULE EXIT_COMMAND INPUT.

  CASE OK_CODE.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
