*&---------------------------------------------------------------------*
*&  Include           ZEDR07_088_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.
  CASE OK_CODE.
    WHEN 'APND'.
      CLEAR GS_STUDENT.
      GS_STUDENT-ZPERNR = '0000000077'.
      GS_STUDENT-ZCODE = 'SSU-77'.
      GS_STUDENT-ZKNAME = '추가요'.
      GS_STUDENT-ZENAME = 'APND'.
      GS_STUDENT-ZGENDER = 'F'.
      GS_STUDENT-ZTEL = '010-7777-7777'.
      APPEND GS_STUDENT TO GT_STUDENT.
    WHEN 'SAVE'.
      MODIFY ZEDT07_001 FROM TABLE GT_STUDENT. "DB에 저장시키기
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
