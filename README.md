# AnyTabUpdateTask
<h1>Utility for DataBase Changes in Update Task and OOP&Functional working with internal tables</h1>

<img src="https://github.com/OlegBash599/AnyTabUpdateTask/blob/main/version_label.svg"/>


<p>Utility is for avoiding creation additional function modules and table types for stable and fast code-writing.
Utility is  for object-oriented and functional approach of internal-table processing.

Main functionality is in package <strong>ZC8A_005</strong>.</BR>
Demo-report is in addtional sub-package <strong> [ZC8A_005_DEMO](https://github.com/OlegBash599/AnyTabUpdateTask/tree/main/src/zc8a_005_demo) </strong> which is in separate folder(https://github.com/OlegBash599/AnyTabUpdateTask/tree/main/src/zc8a_005_demo) in this repository.
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
<summary>Show update by function (without the utility AnyTabUpdateTask)</summary>

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


    " #RU:обновление всех таблиц будет одномоментно после commit
    " #EN:database changes are to be after commit-command
    " #RU:а по пустой таблицы ничего происходить не будет (не будет поставлен Update Task)
    " #EN: empty table does not take into account while commit command
    lo_saver_anytab->do_commit_if_any( ).
  
```
</details>
 
 ____
 
 <details>  
<base target="_blank">
<summary>Option not to pass table name</summary>

```ABAP    
    DATA lt_sample_tab TYPE STANDARD TABLE OF ztc8a005_sample.

    lt_sample_tab = VALUE #(
        ( entity_guid = 'ANY_SIMPL_GUID_MOD' entity_param1 = 'CHAR10' entity_param2 = '0504030201' )
        ( entity_guid = 'ANY_SIMPL_GUID2_MOD' entity_param1 = '2CHAR10' entity_param2 = '0102030405'  )
        ( entity_guid = 'ANY_SIMPL_GUID2_DEL' entity_param1 = '2CHAR10' entity_param2 = '777909034' )
        ).

    CREATE OBJECT lo_saver_anytab.
    lo_saver_anytab->save2db( EXPORTING it_tab_content = lt_sample_tab )->do_commit_if_any( ).
```
</details>

 ____
for the sake of fast debugging and tracing ControlGorup is added <strong>ZC8A005_CONTROL</strong>.
So it is possible to switch on and off ControlGroup via tcode <strong><em>SAAB</em></strong>.

 ____
Additional examples and descriptions are on https://olegbash.ru/anytabupdatetask
 ____


The blog about the utility with commens is on https://blogs.sap.com/2022/08/21/database-update-with-utility-anytab-updatetask/

 ____
The well-structured educational and library source <a href="https://www.sapland.ru/" target="_blank">SAPLAND.ru</a>:
https://sappro.sapland.ru/kb/articles/stats/konsistentnoe-obnovlenie-bazi-dannih-pri-pomoschi-phunktsionala-any-tab-update-t.html

 ____

In Russian you can add your comments here:
The Old-Merry **SAPFORUM**: https://sapboard.ru/forum/viewtopic.php?f=13&t=100324

 ____
HABR-blog
https://habr.com/ru/articles/787282/


## Object-Oriented grouping is added
details are in unit test and in demo-report
```ABAP    
    DATA lt_fi_doc TYPE tt_fi_doc.

    DATA lt_fi_doc_sum_by_kunnr TYPE tt_fi_doc.

    _fill_mock( IMPORTING et_fi_doc = lt_fi_doc ).

    mo_cut->set_in( it = lt_fi_doc )->group_by(
         EXPORTING iv_f1 = 'KUNNR' ).

    CLEAR lt_fi_doc_sum_by_kunnr.
    WHILE mo_cut->has_next_grp( ) EQ abap_true.
      mo_cut->get_next_grp( ).
      _calc_sum_in_group( EXPORTING io_tab_group = mo_cut
                          CHANGING ct_fi_doc_sum = lt_fi_doc_sum_by_kunnr ).
    ENDWHILE.
```

### TODO list
- [ ] CheckValues
- [ ] GTT-sampless like here(https://github.com/OlegBash599/ZC8A016/tree/main)
- [ ] External Call to Save in External HTTP-service
- [ ] Add Data Driven Testing Functions

