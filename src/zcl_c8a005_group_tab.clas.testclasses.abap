*"* use this source file for your ABAP unit test classes
CLASS ltc_terun DEFINITION DEFERRED.
CLASS zcl_c8a005_group_tab DEFINITION LOCAL FRIENDS ltc_terun.

CLASS ltc_terun DEFINITION FOR TESTING
    RISK LEVEL HARMLESS
    DURATION SHORT INHERITING FROM cl_aunit_assert
.

  PUBLIC SECTION.
    METHODS ut_run_01 FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: BEGIN OF ts_fi_doc
          , bukrs TYPE bukrs
          , belnr TYPE belnr_d
          , gjahr TYPE gjahr
          , koart TYPE koart
          , kunnr TYPE kunnr
          , waers TYPE waers
          , dmbtr TYPE dmbtr
          , matnr TYPE matnr18
          , qty TYPE mengv13
      , END OF ts_fi_doc
      , tt_fi_doc TYPE STANDARD TABLE OF ts_fi_doc WITH DEFAULT KEY
      .

    DATA mo_cut TYPE REF TO zcl_c8a005_group_tab.

    METHODS setup.
    METHODS teardown.


    METHODS _fill_mock
      EXPORTING et_fi_doc TYPE tt_fi_doc.

    METHODS _calc_sum_in_group
      IMPORTING io_tab_group  TYPE REF TO zcl_c8a005_group_tab
      CHANGING  ct_fi_doc_sum TYPE tt_fi_doc.

ENDCLASS.


CLASS ltc_terun IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #(  ).

  ENDMETHOD.

  METHOD teardown.
    CLEAR mo_cut .
  ENDMETHOD.

  METHOD ut_run_01.

    DATA lt_fi_doc TYPE tt_fi_doc.

    DATA lt_fi_doc_sum_by_kunnr TYPE tt_fi_doc.

    _fill_mock( IMPORTING et_fi_doc = lt_fi_doc ).

    mo_cut->set_in( it = lt_fi_doc )->group_by(
         EXPORTING iv_f1 = 'KUNNR' ).

    CLEAR lt_fi_doc_sum_by_kunnr.
    WHILE mo_cut->has_next_grp( ) EQ abap_true.
      mo_cut->get_next_grp( ).
      _calc_sum_in_group( EXPORTING io_tab_group = mo_cut
                          CHANGING ct_fi_doc_sum = lt_fi_doc_sum_by_kunnr ).
    ENDWHILE.

  ENDMETHOD.

  METHOD _calc_sum_in_group.
*      IMPORTING io_tab_group  TYPE REF TO zcl_c8a005_group_tab
*      CHANGING  ct_fi_doc_sum TYPE tt_fi_doc.
    DATA ls_fi_doc_kunnr TYPE ts_fi_doc.
    FIELD-SYMBOLS <fs_fi_doc_group_key> TYPE ts_fi_doc.
    FIELD-SYMBOLS <fs_fi_doc_gr_line> TYPE ts_fi_doc.

    io_tab_group->read_group_key( IMPORTING er = DATA(lrs_group_key)  ).
    ASSIGN lrs_group_key->* TO <fs_fi_doc_group_key>.

    MOVE-CORRESPONDING <fs_fi_doc_group_key> to ls_fi_doc_kunnr.
    CLEAR ls_fi_doc_kunnr-dmbtr.
    WHILE mo_cut->has_next_row( ) EQ abap_true.
      mo_cut->get_next_line_as_data_ref(
         IMPORTING er = DATA(lrs_line_in_group) ).
      ASSIGN lrs_line_in_group->* TO <fs_fi_doc_gr_line>.
      ls_fi_doc_kunnr-dmbtr += <fs_fi_doc_gr_line>-dmbtr.
    ENDWHILE.

    APPEND ls_fi_doc_kunnr TO ct_fi_doc_sum.

  ENDMETHOD.

  METHOD _fill_mock.
    "EXPORTING et_fi_doc TYPE tt_fi_doc.
    et_fi_doc = VALUE #(
    ( bukrs = '1010' belnr = '1010201' gjahr = sy-datum koart = 'D' kunnr = '31010' waers = 'RUB' dmbtr = '5050.20' matnr = '2399' qty = '10'  )
    ( bukrs = '1010' belnr = '1010202' gjahr = sy-datum koart = 'D' kunnr = '31010' waers = 'RUB' dmbtr = '5050.20' matnr = '2377' qty = '10'  )
    ( bukrs = '1010' belnr = '1010203' gjahr = sy-datum koart = 'D' kunnr = '31012' waers = 'RUB' dmbtr = '5050.20' matnr = '2399' qty = '10'  )
    ( bukrs = '1010' belnr = '1010204' gjahr = sy-datum koart = 'D' kunnr = '31012' waers = 'RUB' dmbtr = '5050.20' matnr = '2388' qty = '10'  )
    ( bukrs = '1010' belnr = '1010205' gjahr = sy-datum koart = 'D' kunnr = '31015' waers = 'RUB' dmbtr = '5050.20' matnr = '2301' qty = '10'  )
    ).
  ENDMETHOD.

ENDCLASS.
