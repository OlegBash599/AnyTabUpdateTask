class zcl_c8a005_group_tab definition
  public
  final
  create public .

public section.

  methods SET_IN
    importing
      !IV_WH type STRING optional
      !IT type TABLE optional
    changing
      !CT type TABLE optional
    returning
      value(RO) type ref to zcl_c8a005_group_tab .
  methods GROUP_BY
    importing
      !IV_F1 type FIELDNAME optional
      !IV_F2 type FIELDNAME optional
      !IV_F3 type FIELDNAME optional
      !IV_F4 type FIELDNAME optional
      !IV_F5 type FIELDNAME optional
    returning
      value(RO) type ref to zcl_c8a005_group_tab .
  methods GET_INDEX_GRP
    returning
      value(RV) type SYINDEX .
  methods HAS_NEXT_GRP
    returning
      value(RV) type ABAP_BOOL .
  methods GET_NEXT_GRP
    returning
      value(RO) type ref to zcl_c8a005_group_tab .
  methods GET_INDEX_ROW
    returning
      value(RV) type SYINDEX .
  methods HAS_NEXT_ROW
    returning
      value(RV) type ABAP_BOOL .
      " returning value(rs) type ref to data
      "   changing cr type any
  methods GET_NEXT_LINE_AS_DATA_REF
    exporting
      !ER type ref to DATA .
  methods READ_GROUP_KEY
    exporting
      !ER type ref to DATA .
  protected section.
  private section.
    types: begin of ts_grp_each
               , indx_in_grp type syindex
               , vec_r type ref to data
         , end of ts_grp_each
         , tt_grp_each_tab type standard table of ts_grp_each with default key
         .

    types: begin of ts_group_key
                , key1_val type string
                , key2_val type string
                , key3_val type string
                , grp_tab type tt_grp_each_tab
           , end of ts_group_key
           , tt_group_key type sorted table of ts_group_key with unique key
            key1_val key2_val key3_val
           .

    types: begin of ts_keys_in
                , f1 type fieldname
                , fv1 type ref to data
                , f2 type fieldname
                , fv2 type ref to data
                , f3 type fieldname
                , fv3 type ref to data
          , end of ts_keys_in
          .

    types: tt_indx type standard table of syindex with default key.

    data mtr_tab type ref to data.
    data mt_tab_grp type tt_group_key.
    data mv_add_where type string.


    data mv_current_grp type syindex.
    data mv_cur_row_in_grp type syindex.
    data msr_cur_grp type ref to ts_group_key.
    data msr_cur_row type ref to ts_grp_each.

    methods _proc_line_init
      importing is_line_init  type any
                iv_tabix_init type sytabix
      changing  ct_indx       type tt_indx
                cs_keys_in    type ts_keys_in.


ENDCLASS.



CLASS ZCL_C8A005_GROUP_TAB IMPLEMENTATION.


  method GET_INDEX_GRP.
    "returning value(rv) type syindex.
    rv = mv_current_grp.
  endmethod.


  method GET_INDEX_ROW.
    "returning value(rv) type syindex.
    rv = mv_cur_row_in_grp.
  endmethod.


  method GET_NEXT_GRP.
    "returning value(ro) type ref to zcl_fi0034_group_tab.
    mv_current_grp = mv_current_grp + 1.

    read table mt_tab_grp reference into msr_cur_grp index mv_current_grp.
    mv_cur_row_in_grp = 0.

    ro = me.
  endmethod.


  method GET_NEXT_LINE_AS_DATA_REF.
    "exporting es type any

    field-symbols <fs_row> type any.

    mv_cur_row_in_grp = mv_cur_row_in_grp + 1.
    read table msr_cur_grp->grp_tab reference into msr_cur_row index mv_cur_row_in_grp.

    " cr = msr_cur_row->vec_r .
    er = msr_cur_row->vec_r .

    "   assign msr_cur_row->vec_r->* to <fs_row>.
    "   if sy-subrc eq 0.
    "     es = <fs_row>.
    "   endif.

  endmethod.


  method GROUP_BY.

    data lt_sytabix_done type tt_indx.

    field-symbols <fs_tab> type table.

    data ls_keys_in type ts_keys_in.

    ls_keys_in-f1 = iv_f1.
    ls_keys_in-f2 = iv_f2.
    ls_keys_in-f3 = iv_f3.

    assign mtr_tab->* to <fs_tab>.

    if mv_add_where is initial.
      loop at <fs_tab> assigning field-symbol(<fs_line_init>).

        _proc_line_init( exporting is_line_init = <fs_line_init>
                                   iv_tabix_init = sy-tabix
                         changing ct_indx = lt_sytabix_done
                                  cs_keys_in = ls_keys_in ).
      endloop.
    else.
      loop at <fs_tab> assigning field-symbol(<fs_line_init_where>) where (mv_add_where).

        _proc_line_init( exporting is_line_init = <fs_line_init_where>
                                   iv_tabix_init = sy-tabix
                         changing ct_indx = lt_sytabix_done
                                  cs_keys_in = ls_keys_in  ).
      endloop.
    endif.

    ro = me.
  endmethod.


  method HAS_NEXT_GRP.
    "returning value(rv) type abap_bool.
    rv = abap_true.

    if mv_current_grp >= lines( mt_tab_grp ).
      rv = abap_false.
    endif.

  endmethod.


  method HAS_NEXT_ROW.
    "returning value(rv) type abap_bool.
    rv = abap_true.

    if mv_cur_row_in_grp >= lines( msr_cur_grp->grp_tab ).
      rv = abap_false.
    endif.
  endmethod.


  method READ_GROUP_KEY.
    "exporting er type ref to data.

    field-symbols <fs_row> type any.

    read table msr_cur_grp->grp_tab reference into msr_cur_row index 1.

    " cr = msr_cur_row->vec_r .
    er = msr_cur_row->vec_r .
  endmethod.


  method SET_IN.
    "importing it_tab type table.
    if ct is not initial.
      mtr_tab = ref #( ct ).
    else.
      if it is not initial.
        mtr_tab = ref #( it ).
      else.
        message x000(cl) with 'Один из параметров должен быть заполнен'.
      endif.
    endif.

    mv_add_where = iv_wh.

    ro = me.
  endmethod.


  method _PROC_LINE_INIT.
    "importing is_line_init type any
    "changing  ct_indx      type tt_indx.

    data lv_where4group type string.

    data ls_group_key type ts_group_key.
    data ls_grp_each_tab type ts_grp_each.

    field-symbols <fs_tab> type table.

    field-symbols <fs_val> type any.

    read table ct_indx transporting no fields
      with key table_line = sy-tabix binary search.
    if sy-subrc eq 0.
      exit.
    endif.

    clear lv_where4group.
    assign component cs_keys_in-f1 of structure is_line_init to <fs_val>.
    if sy-subrc eq 0.
      ls_group_key-key1_val =  <fs_val>.
      lv_where4group = |{ cs_keys_in-f1 } = '{ <fs_val> }' |.
    endif.

    assign component cs_keys_in-f2 of structure is_line_init to <fs_val>.
    if sy-subrc eq 0.
      ls_group_key-key2_val = <fs_val>.
      lv_where4group = lv_where4group && | AND { cs_keys_in-f2 } = '{ <fs_val> }' |.
    endif.


    if mv_add_where is not initial.
      lv_where4group =  |{ lv_where4group } AND { mv_add_where } |.
    endif.

    clear ls_grp_each_tab.
    assign mtr_tab->* to <fs_tab>.

    loop at <fs_tab> reference into  ls_grp_each_tab-vec_r
        where (lv_where4group)
    .
      append sy-tabix to ct_indx.

      ls_grp_each_tab-indx_in_grp = ls_grp_each_tab-indx_in_grp + 1.
      append ls_grp_each_tab to ls_group_key-grp_tab.
    endloop.

    insert ls_group_key into table mt_tab_grp.

    clear ls_group_key.

  endmethod.
ENDCLASS.
