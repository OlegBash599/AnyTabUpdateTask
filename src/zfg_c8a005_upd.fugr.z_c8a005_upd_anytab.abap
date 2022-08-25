FUNCTION z_c8a005_upd_anytab.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(IV_TABNAME) TYPE  TABNAME
*"     REFERENCE(IT_TAB_DATA) TYPE  ANY
*"     REFERENCE(IV_DO_COMMIT) TYPE  CHAR1 DEFAULT ABAP_FALSE
*"     REFERENCE(IV_KZ) TYPE  UPDKZ_D OPTIONAL
*"     REFERENCE(IV_DEST_NONE) TYPE  CHAR1 DEFAULT ABAP_FALSE
*"     REFERENCE(IV_EMPTY_FIELDS) TYPE  STRING OPTIONAL
*"----------------------------------------------------------------------

  "  DATA lo_tab_json TYPE REF TO lcl_tab_json.
  DATA lo_tab_json TYPE REF TO zcl_c8a005_tab_json.
  DATA lv_json_str TYPE string.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA lv_subkey_saab_log TYPE string.
  DATA lv_ts TYPE timestampl.
  DATA sycprog TYPE sycprog.
  DATA syuname TYPE syuname.
  DATA lv_bcs_mod TYPE bcs_blmodule.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  GET TIME STAMP FIELD lv_ts.

  lv_subkey_saab_log = iv_tabname && `_` && lv_ts.
  sycprog = sy-cprog.
  syuname = sy-uname.

  LOG-POINT ID zc8a005_control SUBKEY lv_subkey_saab_log
    FIELDS it_tab_data
           iv_do_commit
           iv_kz
           iv_dest_none
           iv_empty_fields
           sycprog
           syuname.
  lv_bcs_mod = iv_tabname.
  cl_bcs_breakloop=>execute_loop( iv_module = lv_bcs_mod ).
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  CREATE OBJECT lo_tab_json.

  lo_tab_json->get_json_string( EXPORTING it_tab_data = it_tab_data
                                IMPORTING ev_json_str = lv_json_str ).


  CASE abap_true.
    WHEN iv_dest_none.
      lo_tab_json->put_json2dest_none( EXPORTING  iv_tabname  = iv_tabname
                                                  iv_json_str = lv_json_str
                                                  iv_kz = iv_kz
                                                  iv_empty_fields = iv_empty_fields ).

    WHEN OTHERS.
      lo_tab_json->put_json2update( EXPORTING iv_tabname  = iv_tabname
                                              iv_json_str = lv_json_str
                                              iv_kz = iv_kz
                                              iv_empty_fields = iv_empty_fields ).

      IF iv_do_commit EQ abap_true.
        lo_tab_json->do_commit( ).
      ENDIF.
  ENDCASE.



ENDFUNCTION.
