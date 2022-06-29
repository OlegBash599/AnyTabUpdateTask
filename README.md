# AnyTabUpdateTask
<h1>Utility for DataBase Changes in Update Task</h1>

<p>Utility is for avoiding creation additional function modules and table types. 
<BR>
  for stable and fast code-writing.
</p>
Main functionality is in package <strong>ZC8A_005</strong>.<BR>
Demo-report is in addtional package <strong>ZC8A_005_DEMO</strong> which is attached in separate ZIP-file to this repository.
  
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
<summary>Show update by function...</summary>

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
  
 ____

