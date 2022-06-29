*&---------------------------------------------------------------------*
*&  Include           LZFG_C8A005_UPDP01
*&---------------------------------------------------------------------*

CLASS lcl_tab_json IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.                    "constructor

  METHOD get_json_string.
*      IMPORTING it_tab_data TYPE any
*      EXPORTING ev_json_str TYPE string.
    DATA lo_writer TYPE REF TO cl_sxml_string_writer.
    DATA lv_xstr_json TYPE xstring.
    "    DATA lv_str_json TYPE string.
    DATA lv_reponse2pend TYPE string.
    lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

    CALL TRANSFORMATION id SOURCE json = it_tab_data
                           RESULT XML lo_writer.

    lv_xstr_json = lo_writer->get_output( ).
    TRY.
        ev_json_str = cl_abap_codepage=>convert_from(
            source      = lv_xstr_json
*        codepage    = `UTF-8`
*        endian      =
*        replacement = '#'
*        ignore_cerr = ABAP_FALSE
        ).
      CATCH cx_parameter_invalid_range.  " Parameter with Invalid Range
      CATCH cx_sy_codepage_converter_init.  " System Exception for Code Page Converter Initialization
      CATCH cx_sy_conversion_codepage.  " System Exception Converting Character Set
      CATCH cx_parameter_invalid_type.  " Parameter with Invalid Type
    ENDTRY.




    "REPLACE FIRST OCCURRENCE OF '{"JSON":[' IN ev_json_str WITH '{"request":['.
    "  REPLACE ALL OCCURRENCES OF '{"JSON":' IN lv_str_json WITH ''.
    REPLACE ALL OCCURRENCES OF mc-json_open IN ev_json_str WITH ''.
    ev_json_str = shift_right( val = ev_json_str places = 1 ).

    " ev_json_str = lv_str_json.
  ENDMETHOD.                    "get_json_string

  METHOD put_json2update.
*      IMPORTING iv_tabname TYPE tabname
*                iv_json_str TYPE string.

    CALL FUNCTION 'Z_C8A005_UPD_BYJSON'
      IN UPDATE TASK
      EXPORTING
        iv_tabname  = iv_tabname                 " Имя таблицы
        iv_json_str = iv_json_str.


  ENDMETHOD.                    "put_json2update

  METHOD do_commit .
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true                 " Use of Command `COMMIT AND WAIT`
*      IMPORTING
*       return =                  " Return Messages
      .
  ENDMETHOD.                    "do_commit

  METHOD get_from_json2tab.
*      IMPORTING iv_tabname  TYPE tabname
*                iv_json_str TYPE string.

    DATA lv_json_str TYPE string.
    DATA lr_db_content     TYPE REF TO data.
    DATA lr_reader TYPE REF TO if_sxml_reader.

    FIELD-SYMBOLS <fs_dyn_tab> TYPE STANDARD TABLE.


    TRY .
        create_tab_n_line(
      EXPORTING
        iv_tabname = iv_tabname                 " Имя таблицы
      IMPORTING
        ert_ref     = lr_db_content ).

      CATCH cx_root.
        MESSAGE e000(cl).
        RETURN.
    ENDTRY.


    ASSIGN lr_db_content->* TO  <fs_dyn_tab> .
    lv_json_str = mc-json_open && iv_json_str && mc-json_close.


    TRY.

        CLEAR <fs_dyn_tab>.

        CALL TRANSFORMATION id
          SOURCE XML lv_json_str
          RESULT json = <fs_dyn_tab>.

      CATCH  cx_root.
        MESSAGE e000(cl).
    ENDTRY.


    TRY.
        MODIFY (iv_tabname) FROM TABLE <fs_dyn_tab>.
        " OK
      CATCH cx_sy_open_sql_db.
        MESSAGE e000(cl).
        RETURN.
    ENDTRY.


  ENDMETHOD.                    "get_from_json2tab

  METHOD create_tab_n_line.
*      IMPORTING
*        !iv_tabname TYPE tabname
*      EXPORTING
*        !ert_ref     TYPE REF TO data
*        !ers_ref     TYPE REF TO data
*      .

    DATA lv_tabname TYPE tabname.

    DATA lo_line_type	TYPE REF TO cl_abap_structdescr.
    DATA lo_tab_type  TYPE REF TO cl_abap_tabledescr.

    DATA lt_tab_ref TYPE REF TO data.
    DATA ls_line_ref TYPE REF TO data.

    lv_tabname = iv_tabname.

    TRY.
        me->get_tab_n_line_type(
          EXPORTING
            iv_tabname   =    lv_tabname              " Имя таблицы
          IMPORTING
            eo_line_type =     lo_line_type             " Runtime Type Services
            eo_tab_type  =     lo_tab_type             " Runtime Type Services
        ).
        "      CATCH zcx_nm0002_templ. " Exceptions while template

        CREATE DATA lt_tab_ref TYPE HANDLE lo_tab_type.
        CREATE DATA ls_line_ref TYPE HANDLE lo_line_type.

        ert_ref ?= lt_tab_ref.
        ers_ref ?= ls_line_ref.

      CATCH cx_root.
        " dump any way
        MESSAGE x000(cl).
    ENDTRY.

  ENDMETHOD.                    "create_tab_n_line

  METHOD get_tab_n_line_type.
*    METHODS get_tab_n_line_type
*      IMPORTING
*        !iv_tabname   TYPE tabname
*      EXPORTING
*        !eo_line_type TYPE REF TO cl_abap_structdescr
*        !eo_tab_type  TYPE REF TO cl_abap_tabledescr.
    DATA lo_struct   TYPE REF TO cl_abap_structdescr.
    DATA lt_comp     TYPE cl_abap_structdescr=>component_table.

    DATA lv_msg TYPE string.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.

    lo_struct ?= cl_abap_typedescr=>describe_by_name( iv_tabname ).

    lt_comp  = lo_struct->get_components( ).

    TRY .
        eo_line_type = cl_abap_structdescr=>create(
                             p_components = lt_comp
*                           p_strict     = true
                           ).
        eo_tab_type = cl_abap_tabledescr=>create(
                      p_line_type  = eo_line_type
*                    p_table_kind = tablekind_std
*                    p_unique     = abap_false
*                    p_key        =
*                    p_key_kind   = keydefkind_default
                    ).
      CATCH cx_sy_table_creation. " Exception when Creating a Table Type
        MESSAGE e001(cl) WITH iv_tabname INTO lv_msg.


    ENDTRY.
  ENDMETHOD.                    "get_tab_n_line_type

ENDCLASS.                    "lcl_tab_json IMPLEMENTATION
