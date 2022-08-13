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
