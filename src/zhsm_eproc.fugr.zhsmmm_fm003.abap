FUNCTION zhsmmm_fm003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_EKORG) TYPE  EKKO-EKORG
*"     VALUE(PI_MERNO) TYPE  ZGDMMT004Z-MERNO
*"  EXPORTING
*"     REFERENCE(PE_EBELN) TYPE  EKKO-EBELN
*"  TABLES
*"      PT_04P STRUCTURE  ZGDMMT004P
*"      PT_04X STRUCTURE  ZGDMMT004X
*"      PT_04Y STRUCTURE  ZGDMMT004Y
*"      PT_04Z STRUCTURE  ZGDMMT004Z
*"      PT_LFM1 STRUCTURE  LFM1
*"      PT_EKPO STRUCTURE  EKPO
*"      PT_QINF STRUCTURE  QINF
*"      PT_POEMAIL STRUCTURE  ZGDMMT004Z
*"----------------------------------------------------------------------
  DATA : poheader         TYPE bapimepoheader,
         poheaderx        TYPE bapimepoheaderx,
         poitem           TYPE STANDARD TABLE OF bapimepoitem,
         ls_item          LIKE LINE OF poitem,
         poitemx          TYPE STANDARD TABLE OF bapimepoitemx,
         ls_itemx         LIKE LINE OF poitemx,
         poschedule       TYPE STANDARD TABLE OF bapimeposchedule,
         ls_schedule      LIKE LINE OF poschedule,
         poschedulex      TYPE STANDARD TABLE OF bapimeposchedulx,
         ls_schedulex     LIKE LINE OF poschedulex,
         return           TYPE STANDARD TABLE OF bapiret2,
         ls_return        LIKE LINE OF return.

  DATA : lt_x04z          TYPE STANDARD TABLE OF zgdmmt004z,
         lt_x04p          TYPE STANDARD TABLE OF zgdmmt004p,
         lt_x04x          TYPE STANDARD TABLE OF zgdmmt004x,
         lt_x04y          TYPE STANDARD TABLE OF zgdmmt004y,
         ls_04z           TYPE zgdmmt004z,
         ls_x04x          TYPE zgdmmt004x,
         ls_x04p          TYPE zgdmmt004p,
         ls_x04y          TYPE zgdmmt004y,
         ls_x04z          TYPE zgdmmt004z.

  DATA : lt_y04x          TYPE STANDARD TABLE OF zgdmmt004x,
         ls_y04x          TYPE zgdmmt004x,
         lt_y04p          TYPE STANDARD TABLE OF zgdmmt004p,
         ls_y04p          TYPE zgdmmt004p.

  DATA : lt_z04p          TYPE STANDARD TABLE OF zgdmmt004p,
         ls_z04p          TYPE zgdmmt004p.

  DATA : ls_lfm1          TYPE lfm1,
         ls_poemail       TYPE zgdmmt004z.

  DATA : lv_werks         TYPE ekpo-werks,
         lv_ebelp         TYPE ekpo-ebelp,
         lv_etenr         TYPE eket-etenr,
         lv_lgort         TYPE ekpo-lgort.

  lt_x04z[] = pt_04z[].
  SORT lt_x04z BY merno.
  DELETE lt_x04z WHERE merno <> pi_merno.

  lt_x04p[] = pt_04p[].
  lt_x04x[] = pt_04x[].
  lt_x04y[] = pt_04y[].

  LOOP AT pt_04z INTO ls_04z.
    CLEAR ls_x04z.
    READ TABLE lt_x04z INTO ls_x04z
                       WITH KEY zalno = ls_04z-zalno.
    IF sy-subrc <> 0.
      DELETE lt_x04p WHERE zalno = ls_04z-zalno.
      DELETE lt_x04x WHERE zalno = ls_04z-zalno.
      DELETE lt_x04y WHERE zalno = ls_04z-zalno.
    ENDIF.
  ENDLOOP.

  lt_y04x[] = lt_x04x[].
  SORT lt_y04x BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_y04x COMPARING lifnr.
  lt_y04p[] = lt_x04p[].
  SORT lt_y04p BY lifnr zeile.
  DELETE ADJACENT DUPLICATES FROM lt_y04p COMPARING lifnr zeile.

  LOOP AT lt_y04x INTO ls_y04x.
    CLEAR : ls_lfm1.
    READ TABLE pt_lfm1 INTO ls_lfm1
                       WITH KEY lifnr = ls_y04x-lifnr.
    IF sy-subrc = 0.
      CASE ls_lfm1-kalsk.
        WHEN '01'.
          poheader-doc_type  = 'ZLOC'.
        WHEN '02'.
          poheader-doc_type  = 'ZIMP'.
      ENDCASE.
    ENDIF.

    poheader-purch_org = pi_ekorg.
    poheader-doc_date  = sy-datum.
    poheader-vendor    = ls_y04x-lifnr.
    poheader-currency  = ls_y04x-waers.
    CLEAR ls_x04z.
    READ TABLE lt_x04z INTO ls_x04z
                       WITH KEY zalno = pi_merno.
    IF sy-subrc = 0.
      poheader-pur_group  = ls_x04z-ekgrp.
      poheader-created_by = ls_x04z-ernam.
      lv_werks            = ls_x04z-werks.
    ENDIF.
    poheaderx-doc_type    = 'X'.
    poheaderx-purch_org   = 'X'.
    poheaderx-pur_group   = 'X'.
    poheaderx-doc_date    = 'X'.
    poheaderx-vendor      = 'X'.
    poheaderx-created_by  = 'X'.
    poheaderx-currency    = 'X'.

    CLEAR lv_ebelp.
    LOOP AT lt_y04p INTO ls_y04p WHERE lifnr = ls_y04x-lifnr.
      CLEAR : lt_z04p[].
      LOOP AT lt_x04x INTO ls_x04x WHERE lifnr = ls_y04x-lifnr.
        ADD 10 TO lv_ebelp.
        CLEAR : lv_etenr, lv_lgort.
        LOOP AT lt_x04p INTO ls_x04p WHERE zalno = ls_x04x-zalno
                                       AND lifnr = ls_y04p-lifnr
                                       AND zeile = ls_y04p-zeile.
          IF ls_x04p-menge = 0.
            CONTINUE.
          ENDIF.
          CLEAR ls_x04y.
          READ TABLE lt_x04y INTO ls_x04y WITH KEY zalno = ls_x04p-zalno
                                                   lifnr = ls_x04p-lifnr
                                                   banfn = ls_x04p-banfn
                                                   bnfpo = ls_x04p-bnfpo.
          ADD 1 TO lv_etenr.

          ls_schedule-po_item        = lv_ebelp.
          ls_schedule-sched_line     = lv_etenr.
          ls_schedule-del_datcat_ext = 'D'.
          ls_schedule-delivery_date  = ls_x04y-lfdat.
          ls_schedule-quantity       = ls_x04p-menge.
          ls_schedule-preq_no        = ls_x04y-banfn.
          ls_schedule-preq_item      = ls_x04y-bnfpo.
          APPEND ls_schedule TO poschedule.

          ls_schedulex-po_item        = lv_ebelp.
          ls_schedulex-po_itemx       = 'X'.
          ls_schedulex-sched_line     = lv_etenr.
          ls_schedulex-sched_linex    = 'X'.
          ls_schedulex-del_datcat_ext = 'X'.
          ls_schedulex-delivery_date  = 'X'.
          ls_schedulex-quantity       = 'X'.
          ls_schedulex-preq_no        = 'X'.
          ls_schedulex-preq_item      = 'X'.
          APPEND ls_schedulex TO poschedulex.

          ls_item-quantity = ls_item-quantity + ls_x04p-menge.

          ls_z04p-zalno   = ls_x04p-zalno.
          ls_z04p-lifnr   = ls_x04p-lifnr.
          ls_z04p-zeile   = ls_x04p-zeile.
          ls_z04p-banfn   = ls_x04p-banfn.
          ls_z04p-bnfpo   = ls_x04p-bnfpo.
          APPEND ls_z04p TO lt_z04p.
          CLEAR ls_z04p.
        ENDLOOP.

        ls_item-po_item    = lv_ebelp.
        ls_item-plant      = lv_werks.

        PERFORM f_get_material_mpn TABLES pt_ekpo pt_qinf
                                   USING ls_x04x-lifnr lv_werks ls_y04x-ebeln ls_x04x-matnr
                                   CHANGING ls_item-material.

        ls_item-po_unit    = ls_x04y-meins.
        ls_item-pricedate  = 1.
        ls_item-trackingno = ls_x04y-zalno.
        ls_item-stge_loc   = ls_x04y-lgort.
        APPEND ls_item TO poitem.

        ls_itemx-po_item    = lv_ebelp.
        ls_itemx-po_itemx   = 'X'.
        ls_itemx-plant      = 'X'.
        ls_itemx-material   = 'X'.
        ls_itemx-quantity   = 'X'.
        ls_itemx-po_unit    = 'X'.
        ls_itemx-pricedate  = 'X'.
        ls_itemx-trackingno = 'X'.
        ls_itemx-stge_loc   = 'X'.
        APPEND ls_itemx TO poitemx.
      ENDLOOP.
*****    ENDLOOP.

      IF poschedule[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_PO_CREATE1'
          EXPORTING
            poheader          = poheader
            poheaderx         = poheaderx
            memory_uncomplete = 'X'
            memory_complete   = 'X'
          IMPORTING
            exppurchaseorder  = pe_ebeln
          TABLES
            return            = return
            poitem            = poitem
            poitemx           = poitemx
            poschedule        = poschedule
            poschedulex       = poschedulex.

        IF pe_ebeln IS NOT INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          LOOP AT lt_z04p INTO ls_z04p.
            TRY .
                UPDATE zgdmmt004p SET ebeln  = pe_ebeln
                                  WHERE zalno = ls_z04p-zalno
                                    AND lifnr = ls_z04p-lifnr
                                    AND zeile = ls_z04p-zeile
                                    AND banfn = ls_z04p-banfn
                                    AND	bnfpo = ls_z04p-bnfpo.
              CATCH cx_sy_open_sql_db.
            ENDTRY.

            ls_poemail-ebeln  = pe_ebeln.
            ls_poemail-zalno  = ls_z04p-zalno.
            READ TABLE pt_04z INTO ls_04z
                              WITH KEY zalno = ls_z04p-zalno.
            IF sy-subrc = 0.
              ls_poemail-ernam    = ls_04z-ernam.
              ls_poemail-ekgrp    = ls_04z-ekgrp.
            ENDIF.
            APPEND ls_poemail TO pt_poemail.
          ENDLOOP.
          CLEAR : lt_z04p[].
        ENDIF.
      ENDIF.
      CLEAR : poitem[], poitem, poitemx[], poitemx,
              poschedule[], poschedule, poschedulex[], poschedulex,
              return[], return, lv_ebelp, lv_etenr.
    ENDLOOP.

    CLEAR : poheader, poheaderx, poitem[], poitem, poitemx[], poitemx,
            poschedule[], poschedule, poschedulex[], poschedulex,
            return[], return, lv_ebelp, lv_etenr.
  ENDLOOP.
ENDFUNCTION.
