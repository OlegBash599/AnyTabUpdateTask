FUNCTION z_c8a005_upd_byjson.
*"----------------------------------------------------------------------
*"*"Функциональный модуль обновления:
*"
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(IV_TABNAME) TYPE  TABNAME
*"     VALUE(IV_JSON_STR) TYPE  STRING
*"     VALUE(IV_KZ) TYPE  UPDKZ_D OPTIONAL
*"     VALUE(IV_EMPTY_FIELDS) TYPE  STRING OPTIONAL
*"----------------------------------------------------------------------

  DATA lo_tab_json TYPE REF TO zcl_c8a005_tab_json.
  DATA lv_json_str TYPE string.

  CREATE OBJECT lo_tab_json.

  lo_tab_json->get_from_json2tab( EXPORTING iv_tabname = iv_tabname
                                            iv_json_str = iv_json_str
                                            iv_kz = iv_kz
                                            iv_empty_fields = iv_empty_fields ).






ENDFUNCTION.
