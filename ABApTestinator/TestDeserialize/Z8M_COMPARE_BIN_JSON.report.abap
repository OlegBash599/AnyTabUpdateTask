REPORT z8m_compare_bin_json.
PARAMETERS: p_mode TYPE char2 DEFAULT '10'.
PARAMETERS: likebopf RADIOBUTTON GROUP rad1,
            imp_opt  RADIOBUTTON GROUP rad1,
            json     RADIOBUTTON GROUP rad1 DEFAULT 'X'.

CLASS lcl_app_main DEFINITION.
  PUBLIC SECTION.
    METHODS start_of_sel.
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA mt_tab_change TYPE STANDARD TABLE OF ztab_changable.

    METHODS check_xstring IMPORTING no_handling TYPE abap_bool DEFAULT abap_false.
    METHODS check_string_json.
    METHODS commit_to_start_update_task.
    METHODS fill_itab.
ENDCLASS.

CLASS lcl_app_main IMPLEMENTATION.
  METHOD start_of_sel.
    fill_itab( ).
    CASE abap_true.
      WHEN likebopf.
        check_xstring( no_handling = abap_true ).
      WHEN imp_opt.
        check_xstring( ).
      WHEN OTHERS.
        check_string_json( ).
    ENDCASE.
  ENDMETHOD.

  METHOD check_xstring.
    DATA lv_tabx TYPE xstring.
    DATA lv_mode TYPE char2.

    EXPORT data = mt_tab_change TO DATA BUFFER lv_tabx.

    IF no_handling EQ abap_true.
      lv_mode = '99'. " magical for likeBOPF
    ELSE.
      lv_mode = p_mode.
    ENDIF.

    CALL FUNCTION 'Z_CALLFUNC_UPD_BIN'
      IN UPDATE TASK
      EXPORTING
        iv_tabname          = 'ZTAB_CHANGABLE'                 " Имя таблицы
        iv_tabcontent       = lv_tabx
        iv_structure_change = lv_mode.

    commit_to_start_update_task( ).
  ENDMETHOD.

  METHOD check_string_json.
    DATA lv_tab_string TYPE string.
    NEW zcl_c8a005_tab_json( )->get_json_string( EXPORTING it_tab_data = mt_tab_change
                                                 IMPORTING ev_json_str = lv_tab_string ).
    CALL FUNCTION 'Z_CALLFUNC_UPD_JSON'
      IN UPDATE TASK
      EXPORTING
        iv_tabname    = 'ZTAB_CHANGABLE'                 " Имя таблицы
        iv_tabcontent = lv_tab_string.

    commit_to_start_update_task( ).
  ENDMETHOD.

  METHOD fill_itab.
    mt_tab_change = VALUE #(
  ( field_key1 = 'KEY_102030401' field2 = '1' field3 = 'ANY_CHAR30_12345VAL1' field4 = 'CHAR10_01' )
  ( field_key1 = 'KEY_102030402' field2 = '2' field3 = 'ANY_CHAR30_12345VAL2' field4 = 'CHAR10_02' )
  ( field_key1 = 'KEY_102030403' field2 = '3' field3 = 'ANY_CHAR30_12345VAL3' field4 = 'CHAR10_03' ) ).
  ENDMETHOD.

  METHOD commit_to_start_update_task.
    BREAK-POINT.
    " before commit - start SE11 and do the changes from testCase with ZTAB_CHANGABLE
    " then GO via path (in Debugger User Interface)
    " Settings -> Change Debugger Profile/Settins (or SHIFT+F1)
    " ->>>>>>> mark option Update Debugging
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  NEW lcl_app_main( )->start_of_sel( ).
