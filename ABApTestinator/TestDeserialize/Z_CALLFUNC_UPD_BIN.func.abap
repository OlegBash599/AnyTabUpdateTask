FUNCTION z_callfunc_upd_bin.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TABNAME) TYPE  TABNAME OPTIONAL
*"     VALUE(IV_TABCONTENT) TYPE  XSTRING OPTIONAL
*"     VALUE(IV_STRUCTURE_CHANGE) TYPE  CHAR2 DEFAULT '10'
*"----------------------------------------------------------------------

  DATA lc_tab_change_increase_f3 TYPE char2 VALUE '10'.
  DATA lc_tab_change_decrease_f3 TYPE char2 VALUE '20'.
  DATA lc_tab_change_add_new_f5 TYPE char2 VALUE '30'.
  DATA lc_tab_change_delete_f4 TYPE char2 VALUE '40'.
  DATA lc_tab_change_f2_to_char3 TYPE char2 VALUE '50'.
  DATA lc_deserialize_like_a_bopf TYPE char2 VALUE '99'.

  DATA lt_tab_in TYPE REF TO data.
  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  CREATE DATA lt_tab_in TYPE STANDARD TABLE OF (iv_tabname).

  ASSIGN lt_tab_in->* TO <fs_tab>.
  IF sy-subrc EQ 0.
    CASE iv_structure_change.
      WHEN lc_tab_change_f2_to_char3.
        TRY .
            IMPORT data = <fs_tab> FROM DATA BUFFER
            iv_tabcontent IGNORING STRUCTURE BOUNDARIES
            .
          CATCH cx_sy_import_mismatch_error.
            " write log ?=> just no runtime error
        ENDTRY.

      WHEN lc_deserialize_like_a_bopf.
        " no option - no exception handling
        IMPORT data TO <fs_tab> FROM DATA BUFFER iv_tabcontent .

      WHEN OTHERS.
        TRY .
            IMPORT data = <fs_tab> FROM DATA BUFFER
          iv_tabcontent ACCEPTING PADDING " if structure was changed
                        ACCEPTING TRUNCATION
          .
          CATCH cx_sy_import_mismatch_error.
            " write log ?=> just no runtime error
        ENDTRY.
    ENDCASE.
  ENDIF.
ENDFUNCTION.
