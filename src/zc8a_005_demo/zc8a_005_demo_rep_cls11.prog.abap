*&---------------------------------------------------------------------*
*& Include          ZC8A_005_DEMO_REP_CLS11
*&---------------------------------------------------------------------*

CLASS lcl_add01_demo_anytab DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_screen_in TYPE ts_screen_in.

    METHODS sh.

  PRIVATE SECTION.

    DATA msr_screen_in TYPE REF TO ts_screen_in.

    METHODS avoid_commit_in_current_proc .
ENDCLASS.


CLASS lcl_add01_demo_anytab IMPLEMENTATION.
  METHOD constructor.
    msr_screen_in = REF #( is_screen_in ).
  ENDMETHOD.

  METHOD sh.

    IF msr_screen_in->do_break EQ abap_true.
      BREAK-POINT.
    ENDIF.

    avoid_commit_in_current_proc( ).

  ENDMETHOD.

  METHOD avoid_commit_in_current_proc.
    DATA lc_db_tab_sample TYPE tabname VALUE 'ZTC8A005_SAMPLE'.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.


    IF msr_screen_in->background_mode EQ abap_false.
      EXIT.
    ENDIF.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'AVOID_CUR_COMMIT1_MOD' entity_param1 = 'DEST1NONE' entity_param2 = '1234512121' entity_param3 = sy-uzeit entity_param4 = sy-datum )
        ( entity_guid = 'AVOID_CUR_COMMIT2_MOD' entity_param1 = 'DEST2NONE' entity_param2 = '0102030405' entity_param3 = sy-uzeit entity_param4 = sy-datum )
        ( entity_guid = 'AVOID_CUR_COMMIT3_MOD' entity_param1 = 'DEST3NONE' entity_param2 = '220629909'  entity_param3 = sy-uzeit entity_param4 = sy-datum )
        ).

    " обновление происходит не в текущем процессе, а параллельном через DESTINATION 'NONE'
    " нужно для случаев, когда в текущем процессе необходимость COMMIT пока не определена,
    " или он будет позже
    NEW zcl_c8a005_save2db(
      )->save2db( iv_tabname = lc_db_tab_sample
                  it_tab_content = lt_sample_tab
                  iv_dest_none = abap_true ).
  ENDMETHOD.

ENDCLASS.
