*"* use this source file for your ABAP unit test classes

  INTERFACE ltc_interface4type.
    TYPES ts_data TYPE ztc8a005_sample.
    TYPES tt_data TYPE STANDARD TABLE OF ts_data WITH DEFAULT KEY.

    TYPES ts_wide_tab TYPE bseg.
    TYPES tt_wide_tab TYPE STANDARD TABLE OF ts_wide_tab WITH DEFAULT KEY.

    TYPES: BEGIN OF ts_part_of_sample
            ,   entity_param1 TYPE ztc8a005_sample-entity_param1
            ,   entity_param2 TYPE ztc8a005_sample-entity_param2
            ,   entity_param3 TYPE ztc8a005_sample-entity_param3
            ,   entity_param4 TYPE ztc8a005_sample-entity_param4
          , END OF ts_part_of_sample
          , tt_part_of_sample TYPE STANDARD TABLE OF ts_part_of_sample WITH DEFAULT KEY
          .

  ENDINTERFACE.

  CLASS ltc_find_tab DEFINITION FOR TESTING
              DURATION SHORT
              RISK LEVEL HARMLESS
              INHERITING FROM cl_aunit_assert.

    PUBLIC SECTION.
      METHODS run_test_on_db_tab FOR TESTING.
      METHODS run_test_on_tab_type FOR TESTING.
      METHODS run_test_on_intf_type FOR TESTING.
      METHODS run_test_on_intf_widetype FOR TESTING.
      METHODS run_test_on_no_in_ddic FOR TESTING.
    PROTECTED SECTION.

    PRIVATE SECTION.


  ENDCLASS.


  CLASS ltc_find_tab IMPLEMENTATION.

    METHOD run_test_on_db_tab.

      DATA lo_tabtype TYPE REF TO zcl_c8a005_tabtype.
      CREATE OBJECT lo_tabtype.

      "DATA lt_sample TYPE STANDARD TABLE OF ztc8a005_sample.
      DATA lt_sample TYPE ztc8a005_sample_tab_type.
      DATA lv_tab_name TYPE tabname.

      lt_sample = VALUE #(
          ( entity_guid = 'XXXXXXGUID01' entity_param1 = 'CHAR11' entity_param2 = '1002003001' entity_param3 = sy-uzeit )
          ( entity_guid = 'XXXXXXGUID02' entity_param1 = 'CHAR12' entity_param2 = '1002003002' entity_param3 = ( sy-uzeit + 20 ) )
          ( entity_guid = 'XXXXXXGUID03' entity_param1 = 'CHAR13' entity_param2 = '1002003003' entity_param3 = ( sy-uzeit + 30 ) )
      ).


      BREAK-POINT.

      TRY.
          lv_tab_name =
          lo_tabtype->get_by_data( lt_sample ).
        CATCH zcx_c8a005_error.
          fail(
*            EXPORTING
*              msg    =
*              level  = if_aunit_constants=>severity-medium
*              quit   = if_aunit_constants=>quit-test
*              detail =
          ).
      ENDTRY.
    ENDMETHOD.

    METHOD run_test_on_tab_type.

      DATA lo_tabtype TYPE REF TO zcl_c8a005_tabtype.
      CREATE OBJECT lo_tabtype.

      DATA lt_sample TYPE STANDARD TABLE OF ztc8a005_sample.
      DATA lv_tab_name TYPE tabname.

      lt_sample = VALUE #(
          ( entity_guid = 'XXXXXXGUID01' entity_param1 = 'CHAR11' entity_param2 = '1002003001' entity_param3 = sy-uzeit )
          ( entity_guid = 'XXXXXXGUID02' entity_param1 = 'CHAR12' entity_param2 = '1002003002' entity_param3 = ( sy-uzeit + 20 ) )
          ( entity_guid = 'XXXXXXGUID03' entity_param1 = 'CHAR13' entity_param2 = '1002003003' entity_param3 = ( sy-uzeit + 30 ) )
      ).


      BREAK-POINT.

      TRY.
          lv_tab_name =
          lo_tabtype->get_by_data( lt_sample ).
        CATCH zcx_c8a005_error.
          fail(
*            EXPORTING
*              msg    =
*              level  = if_aunit_constants=>severity-medium
*              quit   = if_aunit_constants=>quit-test
*              detail =
          ).
      ENDTRY.

    ENDMETHOD.

    METHOD run_test_on_intf_type.

      DATA lo_tabtype TYPE REF TO zcl_c8a005_tabtype.
      CREATE OBJECT lo_tabtype.

      DATA lt_sample TYPE STANDARD TABLE OF ltc_interface4type=>ts_data.
      DATA lv_tab_name TYPE tabname.

      lt_sample = VALUE #(
          ( entity_guid = 'XXXXXXGUID01' entity_param1 = 'CHAR11' entity_param2 = '1002003001' entity_param3 = sy-uzeit )
          ( entity_guid = 'XXXXXXGUID02' entity_param1 = 'CHAR12' entity_param2 = '1002003002' entity_param3 = ( sy-uzeit + 20 ) )
          ( entity_guid = 'XXXXXXGUID03' entity_param1 = 'CHAR13' entity_param2 = '1002003003' entity_param3 = ( sy-uzeit + 30 ) )
      ).


      BREAK-POINT.

      TRY.
          lv_tab_name =
          lo_tabtype->get_by_data( lt_sample ).
        CATCH zcx_c8a005_error.
          fail(
*            EXPORTING
*              msg    =
*              level  = if_aunit_constants=>severity-medium
*              quit   = if_aunit_constants=>quit-test
*              detail =
          ).
      ENDTRY.

    ENDMETHOD.

    METHOD run_test_on_intf_widetype.

      DATA lo_tabtype TYPE REF TO zcl_c8a005_tabtype.
      CREATE OBJECT lo_tabtype.

      DATA lt_sample TYPE STANDARD TABLE OF ltc_interface4type=>ts_wide_tab.
      DATA lv_tab_name TYPE tabname.

      lt_sample = VALUE #(
          ( bukrs = '2001' belnr = 'CHAR11' gjahr = sy-datum(4) buzei = '003' buzid = 'Z' augdt = ( sy-datum - 2 ) augcp = sy-datum )
          ( bukrs = '2001' belnr = 'CHAR12' gjahr = sy-datum(4) buzei = '003' buzid = 'Z' augdt = ( sy-datum - 2 ) augcp = sy-datum )
          ( bukrs = '2001' belnr = 'CHAR13' gjahr = sy-datum(4) buzei = '003' buzid = 'Z' augdt = ( sy-datum - 2 ) augcp = sy-datum )
      ).


      BREAK-POINT.

      TRY.
          lv_tab_name =
          lo_tabtype->get_by_data( lt_sample ).
        CATCH zcx_c8a005_error.
          fail(
*            EXPORTING
*              msg    =
*              level  = if_aunit_constants=>severity-medium
*              quit   = if_aunit_constants=>quit-test
*              detail =
          ).
      ENDTRY.

    ENDMETHOD.

    METHOD run_test_on_no_in_ddic.

      DATA lo_tabtype TYPE REF TO zcl_c8a005_tabtype.
      CREATE OBJECT lo_tabtype.

      DATA lt_sample TYPE ltc_interface4type=>tt_part_of_sample.
      DATA lv_tab_name TYPE tabname.

      lt_sample = VALUE #( ( entity_param1 = 'CHAR11' entity_param2 = '1002003001' entity_param3 = sy-uzeit )
          ( entity_param1 = 'CHAR12' entity_param2 = '1002003002' entity_param3 = ( sy-uzeit + 20 ) )
          ( entity_param1 = 'CHAR13' entity_param2 = '1002003003' entity_param3 = ( sy-uzeit + 30 ) )
      ).


      BREAK-POINT.

      TRY.
          lv_tab_name =
          lo_tabtype->get_by_data( lt_sample ).
          fail(
*            EXPORTING
*              msg    =
*              level  = if_aunit_constants=>severity-medium
*              quit   = if_aunit_constants=>quit-test
*              detail =
          ).
        CATCH zcx_c8a005_error.
          " test is ok
      ENDTRY.


    ENDMETHOD.

  ENDCLASS.
