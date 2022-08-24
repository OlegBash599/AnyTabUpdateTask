*&---------------------------------------------------------------------*
*& Include          ZC8A_005_DEMO_REP_CLS99
*&---------------------------------------------------------------------*

CLASS lcl_app DEFINITION.

  PUBLIC SECTION.
    METHODS start_of_sel.
    METHODS end_of_sel.

  PRIVATE SECTION.
    DATA ms_screen_in TYPE ts_screen_in.

    METHODS fill_from_screen.
    METHODS demo_base_options.
    METHODS demo_add_options.


ENDCLASS.


CLASS lcl_app IMPLEMENTATION.
  METHOD start_of_sel.
    fill_from_screen( ).

    demo_base_options( ).

    demo_add_options( ).

  ENDMETHOD.

  METHOD end_of_sel.

    MESSAGE s000(cl) WITH 'Показательный прогон завершен.'(m01).

  ENDMETHOD.

  METHOD fill_from_screen.
    ms_screen_in-do_break             = do_break.
    ms_screen_in-use_function_module  = funcway.
    ms_screen_in-use_anytab_upd_class = anytab.
    ms_screen_in-modify_demo          = modify.
    ms_screen_in-update_by_non_empty  = upd_v1.
    ms_screen_in-update_empty_fields  = upd_v2.
    ms_screen_in-delete_by_tab_key    = del_key.
    ms_screen_in-background_mode      = bckg.
  ENDMETHOD.

  METHOD demo_base_options.

    NEW lcl_base_demo_anytab( ms_screen_in )->sh( ).

  ENDMETHOD.

  METHOD demo_add_options.

    NEW lcl_add01_demo_anytab( ms_screen_in )->sh( ).

  ENDMETHOD.

ENDCLASS.
