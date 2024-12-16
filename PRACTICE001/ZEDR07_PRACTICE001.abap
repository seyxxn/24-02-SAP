*&---------------------------------------------------------------------*
*& Report ZEDR07_PRACTICE001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_PRACTICE001.

DATA : GT_GRADE TYPE TABLE OF ZEDT07_003, "내부 테이블 선언
       GS_GRADE TYPE ZEDT07_003. "구조체 정의

SELECT * FROM ZEDT07_003
  INTO CORRESPONDING FIELDS OF TABLE GT_GRADE. "데이터 가져오기

CLEAR : GS_GRADE.
SORT GT_GRADE BY ZCODE ZEXAM. "학생코드, 시험구분 순으로 정렬

DATA : ZSTART_IDX TYPE I. "새로운 학생코드가 시작되는 인덱스를 저장할 변수
DATA : ZEND_IDX TYPE I. "마지막 학생코드가 나타나는 인덱스를 저장할 변수
DATA : ZCHECK_A TYPE C. "모든 성적이 A인지 확인하는 변수 (X면 모두 A)

DATA: ZUNDERGRAUATE_RATE TYPE P DECIMALS 2 VALUE '0.8', "학부생 납부 비율
      ZPOSTGRADUATE_RATE TYPE P DECIMALS 2 VALUE '0.9'. "대학원생 납부 비율


LOOP AT GT_GRADE INTO GS_GRADE.

  AT NEW ZCODE. "새로운 학생 코드가 시작될 때
    ZSTART_IDX = SY-TABIX.
    ZCHECK_A = 'X'.
  ENDAT.

  AT END OF ZCODE. " 마지막 학생 코드
    ZEND_IDX = SY-TABIX. " 현재 인덱스 저장

    " START_IDX부터 END_IDX까지 체크
    LOOP AT GT_GRADE INTO GS_GRADE FROM ZSTART_IDX TO ZEND_IDX.
      IF GS_GRADE-ZGRADE NE 'A'. " 하나라도 A가 아닌 경우
        ZCHECK_A = ''. " 체크 변수 빈값으로 변경
      ENDIF.
    ENDLOOP.

    IF ZCHECK_A = 'X'. "모든 성적이 A인 경우
      LOOP AT GT_GRADE INTO GS_GRADE FROM ZSTART_IDX TO ZEND_IDX.
        GS_GRADE-ZFLAG = 'X'.

        IF GS_GRADE-ZSCHOOL = 'A'. "학부생인 경우
          GS_GRADE-ZAMOUNT = GS_GRADE-ZSUM * ZUNDERGRAUATE_RATE.
        ELSEIF GS_GRADE-ZSCHOOL = 'B'. " 대학원생인 경우
          GS_GRADE-ZAMOUNT = GS_GRADE-ZSUM * ZPOSTGRADUATE_RATE.
        ENDIF.
        MODIFY GT_GRADE FROM GS_GRADE INDEX SY-TABIX. " 수정된 값 테이블에 반영
      ENDLOOP.
    ELSE.
      LOOP AT GT_GRADE INTO GS_GRADE FROM ZSTART_IDX TO ZEND_IDX.
        GS_GRADE-ZAMOUNT = GS_GRADE-ZSUM.
        MODIFY GT_GRADE FROM GS_GRADE INDEX SY-TABIX. " 수정된 값 테이블에 반영
      ENDLOOP.
    ENDIF.

  ENDAT.

  CLEAR GS_GRADE.
ENDLOOP.

"학생코드가 같은 경우 중복을 제거
DELETE ADJACENT DUPLICATES FROM GT_GRADE COMPARING ZCODE.

DATA : ZSUM TYPE ZEDT07_003-ZAMOUNT.

LOOP AT GT_GRADE INTO GS_GRADE.
ZSUM = ZSUM + GS_GRADE-ZAMOUNT.
  AT FIRST.
    WRITE :/ '------------------------------------------------------------------------'.
    WRITE :/ '|   학생코드   |        전공명        |  장학구분  |      납부금액     |'.
    WRITE :/ '------------------------------------------------------------------------'.
  ENDAT.

  WRITE: / '| ', GS_GRADE-ZCODE, ' |', GS_GRADE-ZMNAME, '|    ', GS_GRADE-ZFLAG, '     |', GS_GRADE-ZAMOUNT CURRENCY 'KRW', '|'.
  WRITE :/ '------------------------------------------------------------------------'.

  AT LAST.
    WRITE :/ '|                합계                              |', ZSUM CURRENCY 'KRW', '|'.
    WRITE :/ '------------------------------------------------------------------------'.
  ENDAT.
ENDLOOP.
