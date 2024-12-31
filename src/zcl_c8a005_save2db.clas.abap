CLASS zcl_c8a005_save2db DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor .
    METHODS save2db
      IMPORTING
        !iv_tabname      TYPE tabname OPTIONAL
        !it_tab_content  TYPE any
        !iv_do_commit    TYPE char1 DEFAULT abap_false
        !iv_kz           TYPE updkz_d OPTIONAL
        !iv_dest_none    TYPE abap_bool DEFAULT abap_false
        !iv_empty_fields TYPE string OPTIONAL
        !iv_strict       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_obj)    TYPE REF TO zcl_c8a005_save2db .
    METHODS save2db_line
      IMPORTING
        !iv_tabname     TYPE tabname
        !is_tab_content TYPE any
        !iv_do_commit   TYPE char1 DEFAULT abap_false
        !iv_dest_none   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_obj)   TYPE REF TO zcl_c8a005_save2db .
    METHODS do_commit_if_any
      IMPORTING
        !iv_do_commit TYPE abap_bool DEFAULT abap_false .
    METHODS do_rollback
      IMPORTING
        !iv_do_rollback TYPE abap_bool DEFAULT abap_false .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_data_was_sent2db TYPE abap_bool.

    METHODS get_absolute_tab_name_by_data
      IMPORTING it_tab_content TYPE any
      RETURNING VALUE(rv_val)  TYPE tabname
      RAISING   zcx_c8a005_error.

    METHODS validate_tabcontent
      IMPORTING iv_tabname     TYPE tabname
                it_tab_content TYPE any
      RAISING   zcx_c8a005_error.

ENDCLASS.



CLASS zcl_c8a005_save2db IMPLEMENTATION.


  METHOD constructor.

  ENDMETHOD.                    "CONSTRUCTOR


  METHOD do_commit_if_any.
    IF mv_data_was_sent2db EQ abap_false
    AND iv_do_commit EQ abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true
*      IMPORTING
*       return =
      .

    CLEAR mv_data_was_sent2db.
  ENDMETHOD.


  METHOD do_rollback.
    IF mv_data_was_sent2db EQ abap_false
    AND iv_do_rollback EQ abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      EXPORTING
        wait = abap_true
*      IMPORTING
*       return =
      .

    CLEAR mv_data_was_sent2db.

  ENDMETHOD.


  METHOD save2db.

    DATA lv_tabname TYPE tabname.

    ro_obj = me.

    IF it_tab_content IS INITIAL.
      RETURN.
    ENDIF.


    IF iv_tabname IS INITIAL.
      TRY.
          lv_tabname = get_absolute_tab_name_by_data( it_tab_content ).
        CATCH zcx_c8a005_error.
          RETURN.
      ENDTRY.
    ELSE.
      lv_tabname = iv_tabname.
    ENDIF.


    IF lv_tabname IS INITIAL.
      RETURN.
    ELSE.
      BREAK-POINT ID zc8a005_control.
    ENDIF.

    IF iv_strict EQ abap_true.
      TRY.
          validate_tabcontent( EXPORTING iv_tabname = lv_tabname
                                         it_tab_content = it_tab_content ).
        CATCH zcx_c8a005_error.
          RETURN.
      ENDTRY.
    ENDIF.

    CALL FUNCTION 'Z_C8A005_UPD_ANYTAB'
      EXPORTING
        iv_tabname      = lv_tabname
        it_tab_data     = it_tab_content
        iv_do_commit    = iv_do_commit
        iv_kz           = iv_kz
        iv_dest_none    = iv_dest_none
        iv_empty_fields = iv_empty_fields.

    IF iv_dest_none EQ abap_false.
      mv_data_was_sent2db = abap_true.
    ENDIF.

  ENDMETHOD.                    "SAVE2DB


  METHOD save2db_line.
*        IMPORTING
*        !iv_tabname TYPE tabname
*        !is_tab_content TYPE any
*        !iv_do_commit TYPE char1 DEFAULT abap_false .
    DATA lr_tab TYPE REF TO data.
    FIELD-SYMBOLS <fs_tab> TYPE STANDARD  TABLE.

    ro_obj = me.

    IF is_tab_content IS INITIAL.
      RETURN.
    ENDIF.

    CREATE DATA lr_tab TYPE STANDARD TABLE OF (iv_tabname).

    ASSIGN lr_tab->* TO <fs_tab>.
    IF sy-subrc EQ 0.
      APPEND is_tab_content TO <fs_tab>.
      CALL FUNCTION 'Z_C8A005_UPD_ANYTAB'
        EXPORTING
          iv_tabname   = iv_tabname
          it_tab_data  = <fs_tab>
          iv_do_commit = iv_do_commit
          iv_dest_none = iv_dest_none.
      IF iv_dest_none EQ abap_false.
        mv_data_was_sent2db = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "save2db_line

  METHOD get_absolute_tab_name_by_data.
*      IMPORTING it_tab_content TYPE any
*      RETURNING VALUE(rv_val)  TYPE tabname.
    DATA lo_tabtype TYPE REF TO zcl_c8a005_tabtype.
    CREATE OBJECT lo_tabtype.
    rv_val =
    lo_tabtype->get_by_data( it_tab_content ).

    IF rv_val IS INITIAL.
      RAISE EXCEPTION TYPE zcx_c8a005_error.
    ENDIF.


  ENDMETHOD.

  METHOD validate_tabcontent.
*      IMPORTING iv_tabname     TYPE tabname
*                it_tab_content TYPE any
*      RAISING   zcx_c8a005_error.

  ENDMETHOD.
ENDCLASS.
