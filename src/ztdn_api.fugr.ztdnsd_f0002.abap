FUNCTION ztdnsd_f0002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(KUNNR) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(KUNNR) TYPE  KUNNR
*"     VALUE(VKBUR) TYPE  VKBUR
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TABLES: knvv.
  DATA: ld_kunnr LIKE knvv-kunnr,
        ld_vkbur LIKE knvv-vkbur,
        ld_message(150).
  ld_kunnr = kunnr.
  SELECT SINGLE vkbur INTO ld_vkbur FROM knvv
    WHERE kunnr = ld_kunnr
      AND vkorg = '8020'
      AND vtweg = '10'
      AND spart = '00'.
  IF sy-subrc EQ 0.
    IF ld_vkbur IS INITIAL.
      CONCATENATE 'Route list ' ld_kunnr '(Sales Office not found )' INTO message SEPARATED BY space.
    ELSE.
      CLEAR message.
      vkbur = ld_vkbur.
    ENDIF.
  ELSE.
    CONCATENATE 'Route list ' ld_kunnr ' not found' INTO message SEPARATED BY space.
  ENDIF.

ENDFUNCTION.
