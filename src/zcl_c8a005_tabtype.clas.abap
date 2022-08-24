CLASS zcl_c8a005_tabtype DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_by_data
      IMPORTING it_tabcontent TYPE any
      RETURNING VALUE(rv_val) TYPE tabname
      RAISING   zcx_c8a005_error.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF ts_dd03l_join_in
           , fieldname  TYPE dd03l-fieldname
           , inttype    TYPE dd03l-inttype
           , position   TYPE dd03l-position
           , intlen     TYPE dd03l-intlen
           , decimals   TYPE dd03l-decimals
      , END OF ts_dd03l_join_in
      , tt_dd03l_join_in TYPE STANDARD TABLE OF ts_dd03l_join_in WITH DEFAULT KEY
      .

    TYPES: BEGIN OF ts_dd03l_loc
          , tabname TYPE dd03l-tabname
          , fieldname TYPE dd03l-fieldname
          , as4local TYPE dd03l-as4local
          , as4vers TYPE dd03l-as4vers
          , position TYPE dd03l-position
          , keyflag TYPE dd03l-keyflag
          , mandatory TYPE dd03l-mandatory
          , rollname TYPE dd03l-rollname
          , comptype TYPE dd03l-comptype
     , END OF ts_dd03l_loc
     , tt_dd03l_loc TYPE STANDARD TABLE OF ts_dd03l_loc WITH DEFAULT KEY
     .

    TYPES: BEGIN OF ts_sel_strings
            , from_join_dyn TYPE STANDARD TABLE OF string WITH DEFAULT KEY
            , where_dyn TYPE STANDARD TABLE OF string WITH DEFAULT KEY
            , tab_result TYPE tt_dd03l_loc
         , END OF ts_sel_strings
         , tt_sel_strings TYPE STANDARD TABLE OF ts_sel_strings WITH DEFAULT KEY
         .
    CONSTANTS mc_max_joins TYPE syindex VALUE 42.

    METHODS get_by_components
      IMPORTING io_strcutdescr TYPE REF TO cl_abap_structdescr
      RETURNING VALUE(rv_val)  TYPE tabname
      RAISING   zcx_c8a005_error.

    METHODS prepare_sql_params
      IMPORTING io_strcutdescr   TYPE REF TO cl_abap_structdescr
      EXPORTING et_dd03l_join_in TYPE tt_dd03l_join_in
      RAISING   zcx_c8a005_error.

    METHODS prepare_sql_string
      IMPORTING it_dd03l_join_in TYPE tt_dd03l_join_in
      EXPORTING et_sel_strings   TYPE tt_sel_strings
      RAISING   zcx_c8a005_error.

    METHODS do_select
      CHANGING ct_sel_strings TYPE tt_sel_strings
      RAISING  zcx_c8a005_error.

    METHODS get_tab_from_by_res
      EXPORTING ev_tabname     TYPE tabname
      CHANGING  ct_sel_strings TYPE tt_sel_strings
      RAISING   zcx_c8a005_error.

    METHODS compare_components
      IMPORTING io_strcutdescr TYPE REF TO cl_abap_structdescr
                iv_tabname     TYPE tabname
      RAISING   zcx_c8a005_error.

ENDCLASS.



CLASS zcl_c8a005_tabtype IMPLEMENTATION.
  METHOD get_by_data.
*      IMPORTING it_tabcontent TYPE any
*      RETURNING VALUE(rv_val) TYPE tabname
*      RAISING   zcx_c8a005_error.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lo_structdescr TYPE REF TO cl_abap_structdescr.
    DATA ls_X030L TYPE x030l.
    FIELD-SYMBOLS <fs_tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <fs> TYPE any.

    ASSIGN it_tabcontent TO <fs_tab>.
    IF sy-subrc EQ 0.
      LOOP AT <fs_tab> ASSIGNING <fs>.
        lo_structdescr ?= cl_abap_typedescr=>describe_by_data( <fs> ).

        IF lo_structdescr->is_ddic_type( ) EQ abap_true.
          lo_structdescr->get_ddic_header(
                RECEIVING p_header = ls_X030L
                EXCEPTIONS
                  not_found    = 1
                  no_ddic_type = 2
                  OTHERS       = 3
              ).
          IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ELSE.
            IF ls_X030L-tabtype EQ 'T'.
              rv_val = ls_X030L-tabname.
            ENDIF.
          ENDIF.
        ELSE.

          rv_val = get_by_components( lo_structdescr ).

        ENDIF.

        EXIT.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD get_by_components.
*      IMPORTING io_strcutdescr TYPE REF TO cl_abap_structdescr
*      RETURNING VALUE(rv_val)  TYPE tabname
*      RAISING   zcx_c8a005_error.

    DATA lt_all_join_params_in TYPE tt_dd03l_join_in.
    DATA lt_sel_strings TYPE tt_sel_strings.
    DATA lv_target_tabname TYPE tabname.



    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    prepare_sql_params( EXPORTING io_strcutdescr   = io_strcutdescr
                        IMPORTING et_dd03l_join_in = lt_all_join_params_in ).
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    prepare_sql_string( EXPORTING it_dd03l_join_in = lt_all_join_params_in
                        IMPORTING et_sel_strings = lt_sel_strings ).


    do_select( CHANGING ct_sel_strings = lt_sel_strings ).

    get_tab_from_by_res(  IMPORTING ev_tabname = lv_target_tabname
                          CHANGING ct_sel_strings = lt_sel_strings ).

    compare_components( EXPORTING io_strcutdescr   = io_strcutdescr
                                  iv_tabname = lv_target_tabname ).

    rv_val = lv_target_tabname.
  ENDMETHOD.

  METHOD prepare_sql_params.
*      IMPORTING io_strcutdescr TYPE REF TO cl_abap_structdescr
*      EXPORTING et_dd03l_join_in TYPE tt_dd03l_join_in
*      RAISING   zcx_c8a005_error.

    DATA lv_position_num TYPE tabfdpos.

    FIELD-SYMBOLS <fs_component> TYPE abap_compdescr.
    FIELD-SYMBOLS <fs_join_in> TYPE ts_dd03l_join_in.

    CLEAR et_dd03l_join_in.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    LOOP AT io_strcutdescr->components ASSIGNING <fs_component>.
      " lv_position_num += 1.
      lv_position_num = lv_position_num + 1.

      IF <fs_component>-name EQ 'MANDT' OR <fs_component>-name EQ 'CLIENT'.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_dd03l_join_in ASSIGNING <fs_join_in>.
      <fs_join_in>-fieldname = <fs_component>-name.
      <fs_join_in>-inttype = <fs_component>-type_kind.
      <fs_join_in>-position = lv_position_num.
      <fs_join_in>-intlen = <fs_component>-length.
      <fs_join_in>-decimals = <fs_component>-decimals.


    ENDLOOP.

  ENDMETHOD.

  METHOD prepare_sql_string.
*      IMPORTING it_dd03l_join_in TYPE tt_dd03l_join_in
*      EXPORTING et_sel_strings TYPE tt_sel_strings
*      RAISING   zcx_c8a005_error.

    DATA lv_select_times TYPE syindex.
    DATA lv_loop_from TYPE syindex.
    DATA lv_loop_to TYPE syindex.
    DATA lv_sql_trg_line TYPE string.
    DATA lv_join_index TYPE syindex.
    FIELD-SYMBOLS <fs_join_in> TYPE ts_dd03l_join_in.
    FIELD-SYMBOLS <fs_sel_string> TYPE ts_sel_strings.

*    IF lines( it_dd03l_join_in ) LE mc_max_joins.
*      lv_select_times = 1.
*    ELSE.
    IF lines( it_dd03l_join_in ) MOD mc_max_joins EQ 0.
      lv_select_times = lines( it_dd03l_join_in ) / mc_max_joins.
    ELSE.
      lv_select_times = ( lines( it_dd03l_join_in ) DIV mc_max_joins ) + 1.
    ENDIF.
    "    ENDIF.


    CLEAR et_sel_strings.

    DO lv_select_times TIMES.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      lv_loop_from = ( ( sy-index - 1 ) * mc_max_joins ) + 1.
      lv_loop_to = sy-index * mc_max_joins.
      CLEAR lv_sql_trg_line.

      APPEND INITIAL LINE TO et_sel_strings ASSIGNING <fs_sel_string>.

      lv_join_index = 0.
      LOOP AT it_dd03l_join_in ASSIGNING <fs_join_in> FROM lv_loop_from TO lv_loop_to.
        lv_join_index = lv_join_index + 1.
        lv_sql_trg_line =
        |t{ lv_join_index }~fieldname EQ '{ <fs_join_in>-fieldname }'| &&
    "    | AND t{ lv_join_index }~inttype = '{ <fs_join_in>-inttype }' | &&
        | AND t{ lv_join_index }~position >= '{ <fs_join_in>-position }' | &&
        | AND t{ lv_join_index }~intlen = '{ <fs_join_in>-intlen }' | &&
        | AND t{ lv_join_index }~decimals = '{ <fs_join_in>-decimals }'|.

        IF lv_join_index EQ 1.
        ELSE.
          lv_sql_trg_line =  ` AND ` && lv_sql_trg_line.
        ENDIF.
        APPEND lv_sql_trg_line TO <fs_sel_string>-where_dyn.

      ENDLOOP.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      DO lv_join_index TIMES.
        IF sy-index = 1.
          lv_sql_trg_line = |DD03L AS t1 join DD02L as DD02L on t1~tabname EQ DD02L~tabname and DD02L~TABCLASS = 'TRANSP'|.
        ELSE.
          lv_sql_trg_line = |INNER JOIN dd03l AS t{ sy-index } ON t1~tabname EQ t{ sy-index }~tabname|.
        ENDIF.
        APPEND lv_sql_trg_line TO <fs_sel_string>-from_join_dyn.
      ENDDO.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ENDDO.

  ENDMETHOD.

  METHOD do_select.
*      changing ct_sel_strings   TYPE tt_sel_strings
*      RAISING  zcx_c8a005_error.
    FIELD-SYMBOLS <fs_sel_string> TYPE ts_sel_strings.

    LOOP AT ct_sel_strings ASSIGNING <fs_sel_string>.
      SELECT t1~tabname t1~fieldname t1~as4local t1~as4vers t1~position t1~keyflag
      FROM (<fs_sel_string>-from_join_dyn)
      INTO TABLE <fs_sel_string>-tab_result
      WHERE (<fs_sel_string>-where_dyn).

      IF <fs_sel_string>-tab_result IS INITIAL.
        RAISE EXCEPTION TYPE zcx_c8a005_error.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_tab_from_by_res.
*      EXPORTING ev_tabname     TYPE tabname
*      CHANGING  ct_sel_strings TYPE tt_sel_strings
*      RAISING   zcx_c8a005_error.
    DATA lt_potential_tab_list TYPE STANDARD TABLE OF tabname.
    DATA lv_found_in_result TYPE syindex.

    FIELD-SYMBOLS <fs_sel_string> TYPE ts_sel_strings.
    FIELD-SYMBOLS <fs_sel_string_search> TYPE ts_sel_strings.
    FIELD-SYMBOLS <fs_dd03l_loc> TYPE ts_dd03l_loc.
    FIELD-SYMBOLS <fs_dd03l_loc_search> TYPE ts_dd03l_loc.

    CLEAR lt_potential_tab_list.
    LOOP AT ct_sel_strings ASSIGNING <fs_sel_string>.


      IF <fs_sel_string>-tab_result IS INITIAL.
        RAISE EXCEPTION TYPE zcx_c8a005_error.
      ENDIF.


      LOOP AT <fs_sel_string>-tab_result ASSIGNING <fs_dd03l_loc>
        WHERE tabname IS NOT INITIAL.

        lv_found_in_result = 0.
        LOOP AT ct_sel_strings ASSIGNING <fs_sel_string_search>.
          LOOP AT <fs_sel_string_search>-tab_result ASSIGNING <fs_dd03l_loc_search>
              WHERE tabname = <fs_dd03l_loc>-tabname.
            lv_found_in_result = lv_found_in_result + 1.
          ENDLOOP.
        ENDLOOP.
        IF lv_found_in_result EQ lines( ct_sel_strings ).
          READ TABLE lt_potential_tab_list TRANSPORTING NO FIELDS
            WITH KEY table_line = <fs_dd03l_loc>-tabname.
          IF sy-subrc EQ 0.
          ELSE.
            APPEND <fs_dd03l_loc>-tabname TO lt_potential_tab_list.
          ENDIF.
        ENDIF.

        IF lines( lt_potential_tab_list ) GE 2.
          RAISE EXCEPTION TYPE zcx_c8a005_error.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    IF lt_potential_tab_list IS INITIAL.
      RAISE EXCEPTION TYPE zcx_c8a005_error.
    ENDIF.

    LOOP AT lt_potential_tab_list INTO ev_tabname.
      EXIT.
    ENDLOOP.

  ENDMETHOD.

  METHOD compare_components.
*      IMPORTING io_strcutdescr TYPE REF TO cl_abap_structdescr
*                iv_tabname     TYPE tabname
*      RAISING   zcx_c8a005_error.

    DATA lt_dd03l_loc TYPE tt_dd03l_loc.

    DATA lv_comp_index TYPE syindex.

    FIELD-SYMBOLS <fs_component> TYPE abap_compdescr.
    FIELD-SYMBOLS <fs_dd03l_loc> TYPE ts_dd03l_loc.

    SELECT tabname fieldname as4local as4vers position keyflag mandatory rollname comptype
        FROM dd03l
    INTO TABLE lt_dd03l_loc
    WHERE tabname = iv_tabname
      AND as4local = 'A'
      AND comptype = 'E'
      ORDER BY position ASCENDING
      .

    IF lines( lt_dd03l_loc ) EQ lines( io_strcutdescr->components ).
      " ok
    ELSE.
      RAISE EXCEPTION TYPE zcx_c8a005_error.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lv_comp_index = 0.
    LOOP AT io_strcutdescr->components ASSIGNING <fs_component>.
      lv_comp_index = lv_comp_index + 1.

      READ TABLE lt_dd03l_loc ASSIGNING <fs_dd03l_loc> INDEX lv_comp_index.
      IF sy-subrc EQ 0.

        IF <fs_component>-name EQ <fs_dd03l_loc>-fieldname.
        ELSE.
          RAISE EXCEPTION TYPE zcx_c8a005_error.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
