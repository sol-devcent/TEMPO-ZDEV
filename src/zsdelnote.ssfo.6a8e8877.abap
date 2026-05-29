  TYPES : BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
            profl TYPE mara-profl,
          END OF ty_mara.

  DATA:ls_new LIKE zsdelnote.

  DATA : lt_mara    TYPE STANDARD TABLE OF ty_mara.

  IF gv_sisa IS INITIAL.
    gv_sisa = gs_header-total_lines.
  ENDIF.

  READ TABLE gt_new INTO ls_new WITH KEY mtart = 'ZPHA'.
  IF sy-subrc = 0.
    gv_flag_mtart = 'X'.
  ENDIF.

  IF gs_header-mvgr1 = '04'.
    gv_flag_mtart = 'X'.
  ENDIF.

  SELECT matnr profl
    FROM mara
    INTO TABLE lt_mara
    FOR ALL ENTRIES IN gt_new
    WHERE matnr = gt_new-matnr
      AND profl = 'RCC'.
  IF lt_mara[] IS NOT INITIAL.
    gv_cold = 'X'.
  ENDIF.

IF gs_header-mvgr1 = '00' OR
  gs_header-mvgr1 = '01'.
  gv_cap = 'X'.
ENDIF.








