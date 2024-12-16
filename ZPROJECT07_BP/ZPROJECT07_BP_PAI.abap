*&---------------------------------------------------------------------*
*&  Include           ZEDR07_PROJECT001_PAI
*&---------------------------------------------------------------------*
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
  CASE OK_CODE.
    WHEN 'SAVE'.
      LOOP AT GT_ALV_DATA INTO GS_ALV_ROW.
*       BREAK-POINT.

       " 수정된 데이터를 데이터베이스에 반영
       UPDATE ZLFA107
       SET STCD1 = GS_ALV_ROW-STCD1
           STCD2 = GS_ALV_ROW-STCD2
       WHERE LIFNR = GS_ALV_ROW-LIFNR.

        IF SY-SUBRC <> 0.
          MESSAGE '저장 실패' TYPE 'E'.
        ENDIF.
      ENDLOOP.


      MESSAGE '저장 성공' TYPE 'I'.
  ENDCASE.
ENDMODULE.
