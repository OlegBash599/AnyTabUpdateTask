*"* use this source file for your ABAP unit test classes
CLASS ltc_event_run DEFINITION DEFERRED.
CLASS zcl_c8a005_save2db DEFINITION LOCAL FRIENDS ltc_event_run.

CLASS ltc_event_run DEFINITION FOR TESTING
            RISK LEVEL HARMLESS
            DURATION SHORT
            INHERITING FROM cl_aunit_assert.

  PUBLIC SECTION.

    METHODS run_insert_simple FOR TESTING.
    METHODS upd_by_key_non_initial FOR TESTING.
    METHODS run_update_no_key FOR TESTING.
    METHODS run_update_empty FOR TESTING.
  PROTECTED SECTION.


  PRIVATE SECTION.


ENDCLASS.


CLASS ltc_event_run IMPLEMENTATION.
  METHOD run_insert_simple.
    " moved to separate package ZC8A_005_DEMO
    " include ZC8A_005_DEMO_REP_CLS10
  ENDMETHOD.

  METHOD upd_by_key_non_initial.
    " moved to separate package ZC8A_005_DEMO
    " include ZC8A_005_DEMO_REP_CLS10
  ENDMETHOD.

  METHOD run_update_no_key.
    " moved to separate package ZC8A_005_DEMO
    " include ZC8A_005_DEMO_REP_CLS10
  ENDMETHOD.

  METHOD run_update_empty.
    " moved to separate package ZC8A_005_DEMO
    " include ZC8A_005_DEMO_REP_CLS10
  ENDMETHOD.

ENDCLASS.
