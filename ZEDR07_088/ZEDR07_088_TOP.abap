*&---------------------------------------------------------------------*
*&  Include           ZEDR07_088_TOP
*&---------------------------------------------------------------------*

TABLES : ZEDT07_001. "데이터 가져올 DB

DATA : GS_STUDENT TYPE ZEDT07_001.
DATA : GT_STUDENT LIKE TABLE OF GS_STUDENT. "인터널테이블 선언

"OK_CODE
DATA : OK_CODE TYPE SY-UCOMM.

"도킹컨테이너 객체 변수
DATA : GC_DOCKING TYPE REF TO CL_GUI_DOCKING_CONTAINER. "스필릿 컨테이너를 만들기 위해서는 도킹컨테이너가 필요함

"스필릿컨테이너 객체 변수
DATA : GC_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

"스필릿컨테이너를 이용해서 2개로 창을 나눌 것임 -> 컨테이너 변수 2개가 필요하다
DATA : GC_CONTAINER1 TYPE REF TO CL_GUI_CONTAINER.
DATA : GC_CONTAINER2 TYPE REF TO CL_GUI_CONTAINER.

"그리드 객체 변수 -> 컨테이너의 수만큼 그리드가 필요함
DATA : GC_GRID1 TYPE REF TO CL_GUI_ALV_GRID.
DATA : GC_GRID2 TYPE REF TO CL_GUI_ALV_GRID.

"필드 카탈로그 -> 컨테이너 수만큼 카탈로그 인터널테이블
DATA : GS_FIELDCAT TYPE LVC_S_FCAT.
DATA : GT_FIELDCAT1 TYPE LVC_T_FCAT.
DATA : GT_FIELDCAT2 TYPE LVC_T_FCAT.

"레이아웃
DATA : GS_LAYOUT TYPE LVC_S_LAYO.

"정렬
DATA : GS_SORT TYPE LVC_S_SORT.
DATA : GT_SORT1 TYPE LVC_T_SORT.
DATA : GT_SORT2 TYPE LVC_T_SORT.
