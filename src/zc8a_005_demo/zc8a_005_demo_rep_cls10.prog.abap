*&---------------------------------------------------------------------*
*& Include          ZC8A_005_DEMO_REP_CLS10
*&---------------------------------------------------------------------*

CLASS lcl_base_demo_anytab DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_screen_in TYPE ts_screen_in.

    METHODS sh.

  PRIVATE SECTION.

    DATA msr_screen_in TYPE REF TO ts_screen_in.

    METHODS demo_modify_if_need.
    METHODS demo_simple_modify.
    METHODS demo_few_tabs_modify.
    METHODS demo_upd_v1_non_emp_if_need.
    METHODS demo_upd_v2_empty.
    METHODS demo_upd_v1_full_key.
    METHODS demo_upd_v1_non_full_key.
    METHODS demo_delete_by_key.

    METHODS demo_function4modify.

ENDCLASS.


CLASS lcl_base_demo_anytab IMPLEMENTATION.
  METHOD constructor.
    msr_screen_in = REF #( is_screen_in ).
  ENDMETHOD.

  METHOD sh.

    IF msr_screen_in->do_break EQ abap_true.
      BREAK-POINT.
    ENDIF.


    IF msr_screen_in->use_anytab_upd_class EQ abap_true.
      demo_modify_if_need( ).
    ENDIF.

    IF msr_screen_in->update_by_non_empty EQ abap_true.
      demo_upd_v1_non_emp_if_need( ).
    ENDIF.

    IF msr_screen_in->update_empty_fields EQ abap_true.
      demo_upd_v2_empty( ).
    ENDIF.

    IF msr_screen_in->delete_by_tab_key EQ abap_true.
      demo_delete_by_key( ).
    ENDIF.

    IF msr_screen_in->use_function_module EQ abap_true.
      demo_function4modify(  ).
    ENDIF.

  ENDMETHOD.

  METHOD demo_modify_if_need.

    IF msr_screen_in->modify_demo EQ abap_false.
      EXIT.
    ENDIF.

    demo_simple_modify( ).
    demo_few_tabs_modify( ).

  ENDMETHOD.

  METHOD demo_simple_modify.
    DATA lc_db_tab_sample TYPE tabname VALUE 'ZTC8A005_SAMPLE'.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'ANY_SIMPL_GUID_MOD' entity_param1 = 'CHAR10' entity_param2 = '0504030201' )
        ( entity_guid = 'ANY_SIMPL_GUID2_MOD' entity_param1 = '2CHAR10' entity_param2 = '0102030405'  )
        ( entity_guid = 'ANY_SIMPL_GUID2_DEL' entity_param1 = '2CHAR10' entity_param2 = '777909034' )
        ( entity_guid = 'ANY_SIMPL_GUID2_UPD2' entity_param1 = '2CHAR10' entity_param2 = '777909034' )
        ).

    NEW zcl_c8a005_save2db(
      )->save2db( iv_tabname = lc_db_tab_sample
                  it_tab_content = lt_sample_tab )->do_commit_if_any( ).

  ENDMETHOD.

  METHOD demo_few_tabs_modify.
    DATA lc_db_tab_sample TYPE tabname VALUE 'ZTC8A005_SAMPLE'.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.
    DATA lt_sample_empty_tab TYPE STANDARD TABLE OF ztc8a005_sample.
    DATA lt_head_tab TYPE STANDARD TABLE OF ztc8a005_head.
    DATA lt_item_tab TYPE STANDARD TABLE OF ztc8a005_item.
    DATA lv_ts TYPE timestamp.
    DATA lo_saver_anytab TYPE REF TO zcl_c8a005_save2db.

    GET TIME STAMP FIELD lv_ts.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'ANY_GUID_MOD' entity_param1 = 'CHAR10' entity_param2 = '0504030201'
            entity_param3 = sy-uzeit entity_param4 = sy-datum entity_param5 = lv_ts )
        ( entity_guid = 'ANY_GUID2_MOD' entity_param1 = '2CHAR10' entity_param2 = '0102030405'
          entity_param3 = sy-uzeit entity_param4 = sy-datum entity_param5 = lv_ts )
        ( entity_guid = 'ANY_GUID2_DEL' entity_param1 = '2CHAR10' entity_param2 = '777909034'
          entity_param3 = sy-uzeit entity_param4 = sy-datum entity_param5 = lv_ts )
        ).

    lt_head_tab = VALUE #(
        ( head_guid = 'ANY_GUID_UPD' head_param1 = 'ANY_GUID_ADD' head_param2 = '9988776655'
            head_param3 = sy-uzeit head_param4 = sy-datum head_param5 = lv_ts )
        ( head_guid = 'ANY_GUID2_UPD' head_param1 = 'ANY_GUID2_ADD' head_param2 = '9988776655'
            head_param3 = sy-uzeit head_param4 = sy-datum head_param5 = lv_ts )
        ( head_guid = 'ANY_GUID_DEL' head_param1 = 'ANY_GUID_ADD' head_param2 = '9988774444'
            head_param3 = sy-uzeit head_param4 = sy-datum head_param5 = lv_ts )
        ( head_guid = 'ANY_GUID2_DEL' head_param1 = 'ANY_GUID2_ADD' head_param2 = '9988774444'
            head_param3 = sy-uzeit head_param4 = sy-datum head_param5 = lv_ts )
     ).

    lt_item_tab = VALUE #(
        ( head_guid = 'ANY_GUID_UPD' item_guid = 'ANY_ITEM_GUID_ADD'
            item_param1 = '2CHAR10' item_param2 = '9988776655'
            item_param3 = sy-uzeit item_param4 = sy-datum item_param5 = lv_ts )
        ( head_guid = 'ANY_GUID2_UPD' item_guid = 'ANY_ITEM_GUID2_ADD' item_param1 = '2CHAR10'
            item_param3 = sy-uzeit item_param4 = sy-datum item_param5 = lv_ts )
        ( head_guid = 'ANY_GUID_DEL' item_guid = 'ANY_ITEM_GUID_ADD' item_param2 = '9988776655'
            item_param3 = sy-uzeit item_param4 = sy-datum item_param5 = lv_ts )
        ( head_guid = 'ANY_GUID2_DEL' item_guid = 'ANY_ITEM_GUID2_ADD' item_param1 = '2CHAR10'
            item_param3 = sy-uzeit item_param4 = sy-datum item_param5 = lv_ts )
    ).


    CREATE OBJECT lo_saver_anytab.
    lo_saver_anytab->save2db( EXPORTING iv_tabname     = lc_db_tab_sample
                                        it_tab_content = lt_sample_tab ).

    lo_saver_anytab->save2db( EXPORTING iv_tabname     = 'ZTC8A005_HEAD'
                                        it_tab_content = lt_head_tab ).

    lo_saver_anytab->save2db( EXPORTING iv_tabname     = 'ZTC8A005_ITEM'
                                        it_tab_content = lt_item_tab ).

    CLEAR lt_sample_empty_tab.
    lo_saver_anytab->save2db( EXPORTING iv_tabname     = lc_db_tab_sample
                                        it_tab_content = lt_sample_empty_tab ).


    " обновление всех таблиц будет одномоментно после commit
    " а по пустой таблицы ничего происходить не будет (не будет поставлен Update Task)
    lo_saver_anytab->do_commit_if_any( ).
  ENDMETHOD.

  METHOD demo_upd_v1_non_emp_if_need.

    IF msr_screen_in->update_by_non_empty EQ abap_false.
      EXIT.
    ENDIF.

    demo_upd_v1_full_key( ).
    demo_upd_v1_non_full_key( ).

  ENDMETHOD.

  METHOD demo_upd_v2_empty.
    DATA lc_db_tab_sample TYPE tabname VALUE 'ZTC8A005_SAMPLE'.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.

    " поля ENTITY_PARAM2 ENTITY_PARAM5 ENTITY_PARAM6
    " будут начальное (initial) значение
    " для их обновления явно указываем поля в параметре iv_empty_fields
    lt_sample_tab = VALUE #(
    ( entity_guid = 'ANY_SIMPL_GUID2_UPD2' entity_param1 = '2CHAR10' ) "
    ).

    NEW zcl_c8a005_save2db(  )->save2db(
      EXPORTING
        iv_tabname     = lc_db_tab_sample
        it_tab_content = lt_sample_tab
        iv_kz          = 'U'
        iv_empty_fields = `ENTITY_PARAM2;ENTITY_PARAM5;ENTITY_PARAM6` " указываем поля через ;
        )->do_commit_if_any( ).



  ENDMETHOD.

  METHOD demo_upd_v1_full_key.

    DATA lt_tab_with_key_2fields TYPE STANDARD TABLE OF ztc8a005_item. "в таблице в ключе 2 поля
    DATA lc_tab_trg TYPE tabname VALUE 'ZTC8A005_ITEM'.

    lt_tab_with_key_2fields = VALUE #(
        ( head_guid = 'ANY_GUID_UPD' item_guid = 'ANY_ITEM_GUID_ADD' item_param2 = '1234563214'  )
        ( head_guid = 'ANY_GUID2_UPD' item_guid = 'ANY_ITEM_GUID2_ADD' item_param1 = '2UPDCHAR' )
        ).


    " обновление по ключу, но в обновляемых параметрах непустые поля
    NEW zcl_c8a005_save2db(  )->save2db(
      EXPORTING
        iv_tabname     = lc_tab_trg
        it_tab_content = lt_tab_with_key_2fields
            iv_do_commit   = ABAP_true " можно включать COMMIT сразу
            iv_kz          = 'U'
      ).


  ENDMETHOD.

  METHOD demo_upd_v1_non_full_key.

    TYPES: BEGIN OF ts_field_tab
               , f TYPE fieldname
               , u TYPE abap_bool
               , w TYPE abap_bool
               , w_dyn TYPE string
          , END OF ts_field_tab
          , tt_field_tab TYPE STANDARD TABLE OF ts_field_tab WITH NON-UNIQUE KEY primary_key COMPONENTS f
          .

    DATA lt_tab_with_key_2fields TYPE STANDARD TABLE OF ztc8a005_item.
    DATA lc_tab_trg TYPE tabname VALUE 'ZTC8A005_ITEM'.

    DATA lv_ts TYPE timestamp.
    GET TIME STAMP FIELD lv_ts.

    DATA lt_field_tab TYPE tt_field_tab.


    lt_tab_with_key_2fields = VALUE #(
        ( head_guid = 'ANY_GUID_UPD' item_param1 = 'UPD10' item_param2 = '0504030201'
            item_param3 = sy-uzeit item_param4 = sy-datum item_param5 = lv_ts )
        ( head_guid = 'ANY_GUID2_UPD' item_param1 = '2UPD10' item_param2 = '0102030405'
            item_param3 = sy-uzeit item_param4 = sy-datum item_param5 = lv_ts )
        ).

    " обновление по не-ключевому параметру
    NEW zcl_c8a005_save2db(  )->save2db(
      EXPORTING
        iv_tabname     = lc_tab_trg
        it_tab_content = lt_tab_with_key_2fields
            iv_kz          = 'U'
    )->do_commit_if_any( ).


  ENDMETHOD.

  METHOD demo_delete_by_key.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.

    IF msr_screen_in->delete_by_tab_key EQ abap_false.
      EXIT.
    ENDIF.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'ANY_GUID2_DEL' )
        ).

    NEW zcl_c8a005_save2db(  )->save2db(
      EXPORTING
        iv_tabname     = 'ZTC8A005_SAMPLE'
        it_tab_content = lt_sample_tab
            iv_kz          = 'D'
    )->do_commit_if_any( ).

  ENDMETHOD.

  METHOD demo_function4modify.
    DATA if_do_commit TYPE xfeld VALUE abap_true.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.
    DATA lt_head_tab TYPE STANDARD TABLE OF ztc8a005_head.
    DATA lt_item_tab TYPE STANDARD TABLE OF ztc8a005_item.

    lt_sample_tab = VALUE #(
    ( entity_guid = 'FUNC_GUID_MOD' entity_param1 = 'CHAR10' entity_param2 = '0504030201' )
    ( entity_guid = 'FUNC_GUID2_MOD' entity_param1 = '2CHAR10' entity_param2 = '0102030405' )
    ( entity_guid = 'FUNC_GUID2_DEL' entity_param1 = '2CHAR10' entity_param2 = '777909034' ) ).

    lt_head_tab = VALUE #(
        ( head_guid = 'FUNC_GUID_UPD' head_param1 = 'ANY_GUID_ADD' head_param2 = '9988776655' )
        ( head_guid = 'FUNC_GUID2_UPD' head_param1 = 'ANY_GUID2_ADD' head_param2 = '9988776655' )
        ( head_guid = 'FUNC_GUID_DEL' head_param1 = 'ANY_GUID_ADD' head_param2 = '9988774444' )
        ( head_guid = 'FUNC_GUID2_DEL' head_param1 = 'ANY_GUID2_ADD' head_param2 = '9988774444' ) ).

    lt_item_tab = VALUE #(
        ( head_guid = 'FUNC_GUID_UPD' item_guid = 'FUNC_ITEM_GUID_ADD' item_param1 = '2CHAR10' item_param2 = '9988776655' )
        ( head_guid = 'FUNC_GUID2_UPD' item_guid = 'FUNC_ITEM_GUID2_ADD' item_param1 = '2CHAR10'  )
        ( head_guid = 'FUNC_GUID_DEL' item_guid = 'FUNC_ITEM_GUID_ADD' item_param2 = '9988776655' )
        ( head_guid = 'FUNC_GUID2_DEL' item_guid = 'FUNC_ITEM_GUID2_ADD' item_param1 = '2CHAR10' ) ).

    CALL FUNCTION 'Z_C8A_005_DEMO_UPD_SAMPLE'
      IN UPDATE TASK
      EXPORTING
        it_sample = lt_sample_tab.

    CALL FUNCTION 'Z_C8A_005_DEMO_UPD_HEAD_ITEM'
      IN UPDATE TASK
      EXPORTING
        it_head = lt_head_tab
        it_item = lt_item_tab.

    IF if_do_commit EQ abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
