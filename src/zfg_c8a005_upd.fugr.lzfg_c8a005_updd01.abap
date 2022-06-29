*&---------------------------------------------------------------------*
*&  Include           LZFG_C8A005_UPDD01
*&---------------------------------------------------------------------*

CLASS lcl_tab_json DEFINITION.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS get_json_string
      IMPORTING it_tab_data TYPE any
      EXPORTING ev_json_str TYPE string.

    METHODS put_json2update
      IMPORTING iv_tabname  TYPE tabname
                iv_json_str TYPE string.

    METHODS do_commit .
    METHODS get_from_json2tab
      IMPORTING iv_tabname  TYPE tabname
                iv_json_str TYPE string.


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

ENDCLASS.
