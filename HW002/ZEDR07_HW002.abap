*&---------------------------------------------------------------------*
*& Report ZEDR07_HW002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR07_HW002 MESSAGE-ID ZMED07.

INCLUDE ZEDR07_HW002_TOP. "변수 선언
INCLUDE ZEDR07_HW002_SCR. "스크린 관련
INCLUDE ZEDR07_HW002_F01. "함수
INCLUDE ZEDR07_HW002_PBO. "스크린 출력 전
INCLUDE ZEDR07_HW002_PAI. "사용자 입력 후

"초기값 설정
INITIALIZATION.
  PERFORM SET_DATE.

"스크린 제어
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.


START-OF-SELECTION.
  PERFORM CHECK_DATA.

  IF P_R1 = C_X. "주문내역
    PERFORM GET_DATA_R1.
    IF GT_ORDER[] IS INITIAL.
      MESSAGE I001.
      EXIT.
    ENDIF.
  PERFORM MODIFY_DATA_R1.
  PERFORM MODIFY_DATA_COM.
  CALL SCREEN 100.

  ELSEIF P_R2 = C_X. "배송내역
   PERFORM GET_DATA_R2.
    IF GT_DELIVERY[] IS INITIAL.
      MESSAGE I001.
      EXIT.
    ENDIF.
   PERFORM MODIFY_DATA_R2.
   PERFORM MODIFY_DATA_COM.
  CALL SCREEN 200.
  ENDIF.

END-OF-SELECTION.
