*&---------------------------------------------------------------------*
*&  Include           ZEDR07_092_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0104  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0104 INPUT.
  CASE OK_CODE.
    WHEN 'SAVE'.
      LOOP AT GT_STUDENT INTO GS_STUDENT.
        MOVE-CORRESPONDING GS_STUDENT TO GS_SAVE.
        APPEND GS_SAVE TO GT_SAVE.
      ENDLOOP.

     MODIFY ZEDT07_001 FROM TABLE GT_SAVE.

     IF SY-SUBRC = 0.
       MESSAGE '저장성공' TYPE 'I'.
     ELSE.
       MESSAGE '저장실패' TYPE 'I'.
     ENDIF.
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
