CLASS zcl_c8a005_tab_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor .
    METHODS get_json_string
      IMPORTING
        !it_tab_data TYPE any
      EXPORTING
        !ev_json_str TYPE string .
    METHODS put_json2update
      IMPORTING
        !iv_tabname      TYPE tabname
        !iv_json_str     TYPE string
        !iv_kz           TYPE updkz_d OPTIONAL
        !iv_empty_fields TYPE string OPTIONAL .
    METHODS do_commit .
    METHODS get_from_json2tab
      IMPORTING
        !iv_tabname      TYPE tabname
        !iv_json_str     TYPE string
        !iv_kz           TYPE updkz_d OPTIONAL
        !iv_empty_fields TYPE string OPTIONAL.
    METHODS put_json2dest_none
      IMPORTING
        !iv_tabname      TYPE tabname
        !iv_json_str     TYPE string
        !iv_kz           TYPE updkz_d OPTIONAL
        !iv_empty_fields TYPE string OPTIONAL .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS: BEGIN OF mc
                , json_open TYPE string VALUE '{"JSON":'
                , json_close TYPE string VALUE '}'
              , END OF mc.

    METHODS create_tab_n_line
      IMPORTING
        !iv_tabname TYPE tabname
      EXPORTING
        !ert_ref    TYPE REF TO data
        !ers_ref    TYPE REF TO data
      .

    METHODS get_tab_n_line_type
      IMPORTING
        !iv_tabname   TYPE tabname
      EXPORTING
        !eo_line_type TYPE REF TO cl_abap_structdescr
        !eo_tab_type  TYPE REF TO cl_abap_tabledescr.

    METHODS prepare_upd_lines
      IMPORTING !iv_tabname      TYPE tabname
                !it_dyn_tab      TYPE STANDARD TABLE
                !iv_empty_fields TYPE string OPTIONAL.

    METHODS prep_upd_lines_key_non_empty
      IMPORTING !iv_tabname      TYPE tabname
                !it_dyn_tab      TYPE STANDARD TABLE
                !iv_empty_fields TYPE string OPTIONAL.

ENDCLASS.



CLASS zcl_c8a005_tab_json IMPLEMENTATION.


  METHOD constructor.

  ENDMETHOD.                    "constructor


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
        MESSAGE x000(cl).

    ENDTRY.

  ENDMETHOD.                    "create_tab_n_line


  METHOD do_commit .
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true                 " Use of Command `COMMIT AND WAIT`
*      IMPORTING
*       return =                  " Return Messages
      .
  ENDMETHOD.                    "do_commit


  METHOD get_from_json2tab.
*      IMPORTING
*        !iv_tabname      TYPE tabname
*        !iv_json_str     TYPE string
*        !iv_kz           TYPE updkz_d OPTIONAL
*        !iv_empty_fields TYPE string OPTIONAL.

    DATA lv_json_str TYPE string.
    DATA lr_db_content     TYPE REF TO data.
    DATA lr_reader TYPE REF TO if_sxml_reader.

    DATA lo_tab_type  TYPE REF TO cl_abap_tabledescr.

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
        CASE iv_kz.
          WHEN 'D'.
            DELETE (iv_tabname) FROM TABLE <fs_dyn_tab>.

          WHEN 'U'.
            prepare_upd_lines( iv_tabname = iv_tabname
                               it_dyn_tab = <fs_dyn_tab>
                               iv_empty_fields = iv_empty_fields ).

          WHEN OTHERS.
            MODIFY (iv_tabname) FROM TABLE <fs_dyn_tab>.
        ENDCASE.
        " OK
      CATCH cx_sy_open_sql_db.
        MESSAGE e000(cl).
        RETURN.
    ENDTRY.


  ENDMETHOD.                    "get_from_json2tab

  METHOD prepare_upd_lines.
*      IMPORTING !iv_tabname      TYPE tabname
*                !it_dyn_tab      TYPE STANDARD TABLE
*                !iv_empty_fields TYPE string OPTIONAL.

    prep_upd_lines_key_non_empty(
      EXPORTING
        iv_tabname = iv_tabname
        it_dyn_tab = it_dyn_tab
        iv_empty_fields = iv_empty_fields
    ).

  ENDMETHOD.

  METHOD prep_upd_lines_key_non_empty.
    TYPES: BEGIN OF ts_dd03l_loc
               , tabname TYPE tabname
               , fieldname  TYPE   fieldname
               , as4local  TYPE    as4local
               , as4vers  TYPE  as4vers
               , position   TYPE   tabfdpos
               , keyflag  TYPE  keyflag
               , comptype  TYPE  dd03l-comptype
          , END OF ts_dd03l_loc
          , tt_dd03l_loc TYPE STANDARD TABLE OF ts_dd03l_loc
          .
    DATA lt_dd03l_loc TYPE tt_dd03l_loc.

    DATA lv_upd_where_line TYPE string.
    DATA lv_upd_set_line TYPE string.
    DATA lt_upd_set TYPE STANDARD TABLE OF string.
    DATA lt_upd_where TYPE STANDARD TABLE OF string.
    DATA lv_do_skip_line TYPE abap_bool.

    DATA lv_empty_fields2update TYPE string.
    DATA lt_list_of_empty_fields TYPE STANDARD TABLE OF string.


    FIELD-SYMBOLS <fs_target_tab_line> TYPE any.
    FIELD-SYMBOLS <fs_dd03l_loc> TYPE ts_dd03l_loc.
    FIELD-SYMBOLS <fs_f> TYPE any.

    lv_empty_fields2update = iv_empty_fields.
    TRANSLATE lv_empty_fields2update TO UPPER CASE.
    REPLACE ALL OCCURRENCES OF ` ` IN lv_empty_fields2update WITH `` .
    SPLIT lv_empty_fields2update AT ';' INTO TABLE lt_list_of_empty_fields.
    DELETE lt_list_of_empty_fields WHERE table_line IS INITIAL.
    SORT lt_list_of_empty_fields.
    DELETE ADJACENT DUPLICATES FROM lt_list_of_empty_fields.


    SELECT tabname fieldname as4local as4vers position keyflag
        comptype
        FROM dd03l
        INTO TABLE lt_dd03l_loc
        WHERE tabname = iv_tabname
            AND as4local = 'A'
        ORDER BY position ASCENDING
        .

    " каждая запись - update line
    LOOP AT it_dyn_tab ASSIGNING <fs_target_tab_line>.
      CLEAR lv_do_skip_line.


      """"""""""""""
      " ключ - для where
      CLEAR lt_upd_where.
      LOOP AT lt_dd03l_loc ASSIGNING <fs_dd03l_loc> WHERE keyflag = abap_true
        AND comptype EQ 'E'.
        IF <fs_dd03l_loc>-fieldname EQ 'MANDT'
            OR <fs_dd03l_loc>-fieldname EQ 'CLIENT'.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT <fs_dd03l_loc>-fieldname OF STRUCTURE <fs_target_tab_line> TO <fs_f>.
        IF sy-subrc EQ 0.

          IF <fs_f> IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR lv_upd_where_line.
          lv_upd_where_line = <fs_dd03l_loc>-fieldname && ` = ` && `'` && <fs_f> && `'`.
          IF lines( lt_upd_where ) GT 0.
            lv_upd_where_line = ` AND ` && lv_upd_where_line.
          ENDIF.
          APPEND lv_upd_where_line TO  lt_upd_where.

*          IF lv_upd_where_line IS INITIAL.
*            lv_upd_where =
*          ELSE.
*            lv_upd_where = lv_upd_where && ` AND ` && <fs_dd03l_loc>-fieldname && ` = ` && `'` && <fs_f> && `'`.
*          ENDIF.
        ELSE.
          lv_do_skip_line = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_do_skip_line EQ abap_true.
        CONTINUE.
      ENDIF.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""
      " Значения целевых полей - which is not initial (if not in array empty_fields)
      CLEAR lt_upd_set.
      LOOP AT lt_dd03l_loc ASSIGNING <fs_dd03l_loc> WHERE keyflag = abap_false
        AND comptype EQ 'E'.
        ASSIGN COMPONENT <fs_dd03l_loc>-fieldname OF STRUCTURE <fs_target_tab_line> TO <fs_f>.
        IF sy-subrc EQ 0.
          IF <fs_f> IS INITIAL.
            "CONTINUE.
            READ TABLE lt_list_of_empty_fields TRANSPORTING NO FIELDS WITH KEY
                table_line = <fs_dd03l_loc>-fieldname BINARY SEARCH.
            IF sy-subrc EQ 0.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.

          CLEAR lv_upd_set_line.
          lv_upd_set_line = <fs_dd03l_loc>-fieldname && ` = ` && `'` && <fs_f> && `'`.
          IF lines( lt_upd_set ) GT 0.
            lv_upd_set_line = ` , ` && lv_upd_set_line.
          ENDIF.
          APPEND lv_upd_set_line TO lt_upd_set.
*          IF lv_upd_set IS INITIAL.
*            lv_upd_set = <fs_dd03l_loc>-fieldname && ` = ` && `'` && <fs_f> && `'`.
*          ELSE.
*            lv_upd_set = lv_upd_where && ` AND ` && <fs_dd03l_loc>-fieldname && ` = ` && `'` && <fs_f> && `'`.
*          ENDIF.
        ELSE.
          lv_do_skip_line = abap_true.
        ENDIF.
      ENDLOOP.


      IF lv_do_skip_line EQ abap_true.
        CONTINUE.
      ENDIF.

      IF lt_upd_set IS INITIAL
        OR lt_upd_where IS INITIAL.
        CONTINUE.
      ENDIF.

      " update для LUW
      UPDATE (iv_tabname) SET (lt_upd_set) WHERE (lt_upd_where).

    ENDLOOP.
  ENDMETHOD.

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


  METHOD put_json2dest_none.
*      IMPORTING iv_tabname  TYPE tabname
*                iv_json_str TYPE string
*                iv_kz       TYPE updkz OPTIONAL.

    CALL FUNCTION 'Z_C8A005_DEST_BYJSON'
      DESTINATION 'NONE'
      EXPORTING
        iv_tabname      = iv_tabname                 " Имя таблицы
        iv_json_str     = iv_json_str
        iv_kz           = iv_kz
        iv_empty_fields = iv_empty_fields.


  ENDMETHOD.                    "put_json2update


  METHOD put_json2update.
*      IMPORTING iv_tabname  TYPE tabname
*                iv_json_str TYPE string
*                iv_kz       TYPE updkz OPTIONAL.

    CALL FUNCTION 'Z_C8A005_UPD_BYJSON'
      IN UPDATE TASK
      EXPORTING
        iv_tabname      = iv_tabname                 " Имя таблицы
        iv_json_str     = iv_json_str
        iv_kz           = iv_kz
        iv_empty_fields = iv_empty_fields.


  ENDMETHOD.                    "put_json2update
ENDCLASS.
