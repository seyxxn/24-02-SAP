*&---------------------------------------------------------------------*
*&  Include           ZEDR07_091_CLS
*&---------------------------------------------------------------------*

"클래스 정의부 생성
CLASS EVENT DEFINITION. "EVENT 라는 클래스 생성
  PUBLIC SECTION.

  "EVENT 클래스 내에 HANDLER_TOOLBAR 라는 메서드를 생성
  METHODS HANDLER_TOOLBAR FOR EVENT TOOLBAR "TOOLBAR 라는 이벤트를 이용할 것이다(사용할 이벤트명)
                          OF CL_GUI_ALV_GRID "그리드 클래스 내의 이벤트를 이용할 것이다
                          IMPORTING E_OBJECT "파라미터는 2개가 필요함 (SE21로 클래스빌더 들어가서 TOOLBAR에 필요한 파라미터 확인)
                                    E_INTERACTIVE.

  "EVENT 클래스 내에 HANDLER_USER_COMMAND 라는 메서드를 생성
  METHODS HANDLER_USER_COMMAND FOR EVENT USER_COMMAND
                               OF CL_GUI_ALV_GRID
                               IMPORTING E_UCOMM.

  "EVENT 클래스 내에 HANDLER_HOTSPOT_CLICK 라는 메서드 생성
  METHODS HANDLER_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK
                                OF CL_GUI_ALV_GRID
                                IMPORTING E_ROW_ID
                                          E_COLUMN_ID
                                          ES_ROW_NO.

  "EVENT 클래스 내에 HANDLER_DOUBLE_CLICK 라는 메서드 생성
  METHODS HANDLER_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK
                               OF CL_GUI_ALV_GRID
                               IMPORTING E_ROW
                                         E_COLUMN
                                         ES_ROW_NO.

ENDCLASS.

"클래스 실행부 생성
CLASS EVENT IMPLEMENTATION.
  METHOD HANDLER_TOOLBAR. "반드시 위에 생성해준 이름과 동일해야 함 -> 이제 여기서 로직을 작성해야 함
    PERFORM ALV_HANDLER_TOOLBAR USING E_OBJECT E_INTERACTIVE. "PERFORM으로 함수 생성했음
  ENDMETHOD.

  METHOD HANDLER_USER_COMMAND.
     PERFORM ALV_HANDLER_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.

  METHOD HANDLER_HOTSPOT_CLICK.
    PERFORM ALV_HANDLER_HOTSPOT_CLICK USING E_ROW_ID
                                            E_COLUMN_ID
                                            ES_ROW_NO.
  ENDMETHOD.

  METHOD HANDLER_DOUBLE_CLICK.
    PERFORM ALV_HANDLER_DOUBLE_CLICK USING E_ROW
                                           E_COLUMN
                                           ES_ROW_NO.
  ENDMETHOD.
ENDCLASS.
