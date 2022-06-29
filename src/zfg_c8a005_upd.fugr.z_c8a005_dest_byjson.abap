FUNCTION z_c8a005_dest_byjson.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(IV_TABNAME) TYPE  TABNAME
*"     VALUE(IV_JSON_STR) TYPE  STRING
*"     VALUE(IV_KZ) TYPE  UPDKZ_D OPTIONAL
*"----------------------------------------------------------------------


  DATA lo_tab_json TYPE REF TO zcl_c8a005_tab_json.

  CALL FUNCTION 'Z_C8A005_UPD_BYJSON'
    IN UPDATE TASK
    EXPORTING
      iv_tabname  = iv_tabname                 " Имя таблицы
      iv_json_str = iv_json_str
      iv_kz       = iv_kz.                  " Таблица для индикаторов обновления


  CREATE OBJECT lo_tab_json.

  lo_tab_json->do_commit( ).

ENDFUNCTION.
