# AnyTabUpdateTask
<h1>Utility for DataBase Changes in Update Task</h1>

<p>Utility is for avoiding creation additional function modules and table types for stable and fast code-writing.

Main functionality is in package <strong>ZC8A_005</strong>.</BR>
Demo-report is in addtional package <strong> [ZC8A_005_DEMO] </strong> which is attached in separate [ZIP-file](https://github.com/OlegBash599/AnyTabUpdateTask/tree/main/DEMO_package) to this repository.
</p>

 ____

Simple Example for MODIFY table using this utility:
```ABAP
    DATA lc_db_tab_sample TYPE tabname VALUE 'ZTC8A005_SAMPLE'.
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'ANY_SIMPL_GUID_MOD' entity_param1 = 'CHAR10' entity_param2 = '0504030201' )
        ( entity_guid = 'ANY_SIMPL_GUID2_MOD' entity_param1 = '2CHAR10' entity_param2 = '0102030405'  )
        ( entity_guid = 'ANY_SIMPL_GUID2_DEL' entity_param1 = '2CHAR10' entity_param2 = '777909034' )
        ).

    NEW zcl_c8a005_save2db(
      )->save2db( iv_tabname = lc_db_tab_sample
                  it_tab_content = lt_sample_tab )->do_commit_if_any( ).
```

Without this utlity it could be like that (with creation of additional objects)
<details>  
<base target="_blank">
<summary>Show update by function (old-fashined way)</summary>

```ABAP    
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'ANY_SIMPL_GUID_MOD' entity_param1 = 'CHAR10' entity_param2 = '0504030201' )
        ( entity_guid = 'ANY_SIMPL_GUID2_MOD' entity_param1 = '2CHAR10' entity_param2 = '0102030405'  )
        ( entity_guid = 'ANY_SIMPL_GUID2_DEL' entity_param1 = '2CHAR10' entity_param2 = '777909034' )
        ).

    CALL FUNCTION 'Z_C8A_005_DEMO_UPD_SAMPLE'
      IN UPDATE TASK
      EXPORTING
        it_sample = lt_sample_tab.
  
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
  
```
</details>
  
 
Example for several tables
<details>  
<base target="_blank">
<summary>Utility AnyTabUpdateTask for several Tables</summary>

```ABAP    
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
        ( head_guid = 'ANY_GUID_UPD' item_guid = 'ANY_ITEM_GUID_ADD' item_param1 = '2CHAR10' item_param2 = '9988776655'
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
  
```
</details>
 
 
 ____

