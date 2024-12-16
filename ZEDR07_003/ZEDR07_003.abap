*&---------------------------------------------------------------------*
*& Report ZEDR07_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_003.

DATA : BEGIN OF GS_LINE,
COL1 TYPE C,
END OF GS_LINE.

DATA : GT_LINE LIKE TABLE OF GS_LINE.

DATA : GV_LINE TYPE I.

GS_LINE-COL1 = SY-INDEX.
APPEND GS_LINE TO GT_LINE.

GS_LINE-COL1 = '2'.
APPEND GS_LINE TO GT_LINE.

GS_LINE-COL1 = '3'.
APPEND GS_LINE TO GT_LINE.

DESCRIBE TABLE GT_LINE LINES GV_LINE.

WRITE : GV_LINE.
