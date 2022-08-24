*&---------------------------------------------------------------------*
*& Include          ZC8A_005_DEMO_REP_DATA
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ts_screen_in
        , do_break TYPE char1
        , use_function_module TYPE char1
        , use_anytab_upd_class TYPE char1
        , modify_demo TYPE char1
        , update_by_non_empty TYPE char1
        , update_empty_fields TYPE char1
        , delete_by_tab_key TYPE char1
        , background_mode TYPE char1
     , END OF ts_screen_in
     .

CLASS lcl_app DEFINITION DEFERRED.
DATA go_app TYPE REF TO lcl_app.
