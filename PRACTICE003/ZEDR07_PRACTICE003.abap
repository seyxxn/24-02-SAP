*&---------------------------------------------------------------------*
*& Report ZEDR07_PRACTICE003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_PRACTICE003.

RANGES GR_ZCODE FOR ZEDT07_001-ZCODE. "RANGE TABLE 사용

DATA : GS_STUDENT TYPE ZEDT07_001. "구조체 정의
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT. "인터널 테이블 정의

"조건 추가 (SSU-90 ~ 99에 해당하는 값을 가져오기)
GR_ZCODE-SIGN = 'I'.
GR_ZCODE-OPTION = 'BT'.
GR_ZCODE-LOW = 'SSU-90'.
GR_ZCODE-HIGH = 'SSU-99'.
APPEND GR_ZCODE.

"테이블을 읽어서 GR_ZCODE에 해댕하는 데이터들을 인터널테이블에 담기
SELECT * FROM ZEDT00_001
  INTO CORRESPONDING FIELDS OF TABLE GT_STUDENT
  WHERE ZCODE IN GR_ZCODE.


LOOP AT GT_STUDENT INTO GS_STUDENT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "FUNCTION을 호출해서 0을 채움
    EXPORTING
      INPUT         = GS_STUDENT-ZPERNR
   IMPORTING
     OUTPUT        = GS_STUDENT-ZPERNR.

  "변환된 값을 GT_STUDENT 테이블에 반영함
  MODIFY GT_STUDENT FROM GS_STUDENT TRANSPORTING ZPERNR.

ENDLOOP.

"변환된 데이터를 ZEDT07_001 테이블에 저장함
MODIFY ZEDT07_001 FROM TABLE GT_STUDENT.
