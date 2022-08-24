FUNCTION z_c8a_005_demo_upd_sample.
*"----------------------------------------------------------------------
*"*"Функциональный модуль обновления:
*"
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(IV_UPDKZ) TYPE  UPDKZ DEFAULT 'M'
*"     VALUE(IT_SAMPLE) TYPE  ZTC8A005_SAMPLE_TAB_TYPE
*"----------------------------------------------------------------------
  DATA lc_modify_tab TYPE updkz VALUE 'M'.
  DATA lc_upd_tab TYPE updkz VALUE 'U'.
  DATA lc_del_tab TYPE updkz VALUE 'D'.

  IF it_sample IS INITIAL.
    EXIT.
  ENDIF.

  CASE iv_updkz.
    WHEN lc_modify_tab.
      MODIFY ztc8a005_sample FROM TABLE it_sample.
    WHEN lc_upd_tab.
      UPDATE ztc8a005_sample FROM TABLE it_sample.
    WHEN lc_del_tab.
      DELETE ztc8a005_sample FROM TABLE it_sample.
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.
