FUNCTION z_callfunc_upd_json.
*"----------------------------------------------------------------------
*"  IMPORTING
*"     VALUE(IV_TABNAME) TYPE  TABNAME OPTIONAL
*"     VALUE(IV_TABCONTENT) TYPE  STRING OPTIONAL
*"----------------------------------------------------------------------
  DATA lv_json_str TYPE string.

  DATA lt_tab_in TYPE REF TO data.
  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  CREATE DATA lt_tab_in TYPE STANDARD TABLE OF (iv_tabname).

  ASSIGN lt_tab_in->* TO <fs_tab>.
  IF sy-subrc EQ 0.
    TRY.
        lv_json_str = '{"JSON":' && iv_tabcontent && '}'.

        CALL TRANSFORMATION id
          SOURCE XML lv_json_str
          RESULT json = <fs_tab>
          OPTIONS value_handling = 'accept_data_loss'.

      CATCH  cx_root.
        MESSAGE e000(cl).
    ENDTRY.

  ENDIF.
ENDFUNCTION.
