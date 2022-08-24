FUNCTION z_c8a_005_demo_upd_head_item.
*"----------------------------------------------------------------------
*"*"Функциональный модуль обновления:
*"
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(IV_UPDKZ) TYPE  UPDKZ DEFAULT 'M'
*"     VALUE(IT_HEAD) TYPE  ZTC8A005_HEAD_TAB_TYPE
*"     VALUE(IT_ITEM) TYPE  ZTC8A005_ITEM_TAB_TYPE
*"----------------------------------------------------------------------
  DATA lc_modify_tab TYPE updkz VALUE 'M'.
  DATA lc_upd_tab TYPE updkz VALUE 'U'.
  DATA lc_del_tab TYPE updkz VALUE 'D'.

  IF it_head IS NOT INITIAL.
    CASE iv_updkz.
      WHEN lc_modify_tab.
        MODIFY ztc8a005_head FROM TABLE it_head.
      WHEN lc_upd_tab.
        UPDATE ztc8a005_head FROM TABLE it_head.
      WHEN lc_del_tab.
        DELETE ztc8a005_head FROM TABLE it_head.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  IF it_item IS NOT INITIAL.
    CASE iv_updkz.
      WHEN lc_modify_tab.
        MODIFY ztc8a005_item FROM TABLE it_item.
      WHEN lc_upd_tab.
        UPDATE ztc8a005_item FROM TABLE it_item.
      WHEN lc_del_tab.
        DELETE ztc8a005_item FROM TABLE it_item.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
