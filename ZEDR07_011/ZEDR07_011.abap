*&---------------------------------------------------------------------*
*& Report ZEDR07_011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_011.

DATA : GV_NUM1 TYPE I,
      GV_NUM2 TYPE I,
      GV_NUM3 TYPE I.

GV_NUM1 = 100.
GV_NUM2 = 120.
GV_NUM3 = 110.

WRITE : / '**1번-IF문에 WRITE문 출력'.
WRITE :/ GV_NUM1.
WRITE :/ GV_NUM2.


IF GV_NUM1 < GV_NUM2.
  WRITE : / 'GV_NUM1이 GV_NUM2보다 작습니다.'.
ELSEIF GV_NUM1 = GV_NUM2.
  WRITE : / 'GV_NUM1과 GV_NUM2은 같습니다.'.
ELSE.
  WRITE : / 'GV_NUM1이 GV_NUM2보다 큽니다.'.
ENDIF.

WRITE : /'-----------------------------------------'.


WRITE : / '**2번-IF문에 WRITE문 출력'.
WRITE :/ GV_NUM1.
WRITE :/ GV_NUM2.
WRITE :/ GV_NUM3.

IF ( GV_NUM1 < GV_NUM2 ) AND ( GV_NUM1 < GV_NUM3 ).
  WRITE : / 'GV_NUM1이 GV_NUM2, GV_NUM3보다 작습니다.'.
ENDIF.

WRITE : /'-----------------------------------------'.

WRITE : / '**3번-ELSE문에 WRITE문 출력'.
WRITE :/ GV_NUM1.
WRITE :/ GV_NUM2.

IF GV_NUM1 > GV_NUM2.
  WRITE : / 'GV_NUM1이 GV_NUM2보다 큽니다.'.
ELSEIF GV_NUM1 = GV_NUM2.
  WRITE : / 'GV_NUM1과 GV_NUM2은 같습니다.'.
ELSE.
  WRITE : / 'GV_NUM2이 GV_NUM1보다 큽니다.'.
ENDIF.

WRITE : /'-----------------------------------------'.

WRITE : / '**4번-NUM1, NUM2, NUM3 모든 변수를 사용하여 WRITE문 출력'.

IF ( GV_NUM1 > GV_NUM2 ) AND ( GV_NUM1 > GV_NUM3 ).
  WRITE :/ 'GV_NUM1이'.
  WRITE : GV_NUM1.
  WRITE : '가장 큰수입니다.'.
ELSEIF ( GV_NUM2 > GV_NUM1 ) AND ( GV_NUM2 > GV_NUM3 ).
  WRITE :/ 'GV_NUM2이'.
  WRITE : GV_NUM2.
  WRITE : '가장 큰수입니다.'.
ELSE.
  WRITE :/ 'GV_NUM3이'.
  WRITE : GV_NUM3.
  WRITE : '가장 큰수입니다.'.
ENDIF.
