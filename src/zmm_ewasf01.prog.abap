*&---------------------------------------------------------------------*
*&  Include           ZMM_EWASF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_QUARTER
*&---------------------------------------------------------------------*
FORM f_init_quarter .
  DATA : ex_quarter   TYPE p99sg_quarter,
         ex_begda     TYPE sy-datum,
         ex_endda     TYPE sy-datum,
         lv_begda(10),
         lv_endda(10),
         im_quarter   TYPE p99sg_quarter-q,
         im_year      TYPE p99sg_quarter-year.

  IF pa_quart IS INITIAL.
    CALL FUNCTION 'HR_99S_GET_QUARTER'
      EXPORTING
        im_date    = sy-datum
      IMPORTING
        ex_quarter = ex_quarter.

    pa_quart  = ex_quarter-q.
    ex_begda  = ex_quarter-begda.
    ex_endda  = ex_quarter-endda.
  ELSE.
    im_quarter  = pa_quart.
    im_year     = pa_gjahr.
    CALL FUNCTION 'HR_99S_GET_DATES_QUARTER'
      EXPORTING
        im_quarter = im_quarter
        im_year    = im_year
      IMPORTING
        ex_begda   = ex_begda
        ex_endda   = ex_endda.
  ENDIF.

  WRITE ex_begda TO lv_begda.
  WRITE ex_endda TO lv_endda.

  CLEAR : so_budat[].
  CONCATENATE lv_begda+3(7) lv_endda+3(7) INTO pa_month SEPARATED BY ' to '.
  so_budat-low  = ex_begda.
  so_budat-high = ex_endda.
  so_budat-sign = 'I'.
  so_budat-option = 'BT'.
  APPEND so_budat.
ENDFORM.                    " F_INIT_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'XXX' '0' '' '' '',
                                      'GRY' '0' '' '' ''.
    WHEN OTHERS.
      PERFORM f_modify_screen USING : 'GRY' '' '0' '' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_INIT_LGORT
*&---------------------------------------------------------------------*
FORM f_init_lgort .
  DATA : ls_zmmewas   LIKE LINE OF gt_zmmewas.

  CLEAR : so_lgort[], gr_lgort01[], gr_lgort02[].

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '00'
                                            OR seqno = '01'
                                            OR seqno = '02'.
        PERFORM f_selopt  USING ls_zmmewas-lgort ''.
        CASE ls_zmmewas-seqno.
          WHEN '00'.
            APPEND so_lgort TO gr_lgort01.
          WHEN OTHERS.
            APPEND so_lgort TO gr_lgort02.
        ENDCASE.
        CLEAR so_lgort.
      ENDLOOP.

    WHEN radio2.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '01'
                                            OR seqno = '03'
                                            OR seqno = '04'.
        PERFORM f_selopt  USING ls_zmmewas-lgort ''.
        CASE ls_zmmewas-seqno.
          WHEN '01'.
            APPEND so_lgort TO gr_lgort01.
          WHEN OTHERS.
            APPEND so_lgort TO gr_lgort02.
        ENDCASE.
        CLEAR so_lgort.
      ENDLOOP.

    WHEN radio3.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '05'
                                            OR seqno = '06'
                                            OR seqno = '07'
                                            OR seqno = '08'.
        PERFORM f_selopt  USING ls_zmmewas-lgort ''.

        CASE ls_zmmewas-seqno.
          WHEN '05'.
            APPEND so_lgort TO gr_lgort01.
          WHEN '06' OR '07'.
            APPEND so_lgort TO gr_lgort02.
          WHEN OTHERS.
            APPEND so_lgort TO gr_lgort03.
        ENDCASE.
        CLEAR so_lgort.
      ENDLOOP.

    WHEN radio4.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '09'
                                            OR seqno = '10'.
        PERFORM f_selopt  USING ls_zmmewas-lgort ''.
      ENDLOOP.
  ENDCASE.

  SORT so_lgort BY low.
  DELETE ADJACENT DUPLICATES FROM so_lgort COMPARING low.
ENDFORM.                    " F_INIT_LGORT

*&---------------------------------------------------------------------*
*&      Form  F_INIT_BWART
*&---------------------------------------------------------------------*
FORM f_init_bwart .
  DATA : lt_001   TYPE TABLE OF ztspmmdt001,
         ls_001   LIKE LINE OF lt_001,
         lt_003   TYPE TABLE OF ztspmmdt003,
         ls_003   LIKE LINE OF lt_003,
         lv_str01 TYPE string,
         lv_str02 TYPE string.

  DATA : ls_zmmewas   LIKE LINE OF gt_zmmewas.

  CLEAR : so_bwart[], gr_bwart01[], gr_bwart02[], gr_bwart03[].

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '01'
                                            OR seqno = '02'.
        PERFORM f_selopt  USING '' ls_zmmewas-bwart.

        CASE ls_zmmewas-seqno.
          WHEN '01'.
            APPEND so_bwart TO gr_bwart01.
          WHEN '02'.
            APPEND so_bwart TO gr_bwart02.
        ENDCASE.
        CLEAR so_bwart.
      ENDLOOP.

    WHEN radio2.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '01'
                                            OR seqno = '03'
                                            OR seqno = '04'.
        PERFORM f_selopt  USING '' ls_zmmewas-bwart.

        CASE ls_zmmewas-seqno.
          WHEN '01'.
            APPEND so_bwart TO gr_bwart03.
          WHEN '03'.
            APPEND so_bwart TO gr_bwart01.
          WHEN '04'.
            APPEND so_bwart TO gr_bwart02.
        ENDCASE.
        CLEAR so_bwart.
      ENDLOOP.

    WHEN radio3.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '06'
                                            OR seqno = '07'
                                            OR seqno = '08'.
        PERFORM f_selopt  USING '' ls_zmmewas-bwart.

        CASE ls_zmmewas-seqno.
          WHEN '06'.
            APPEND so_bwart TO gr_bwart01.
          WHEN '07'.
            APPEND so_bwart TO gr_bwart02.
          WHEN '08'.
            APPEND so_bwart TO gr_bwart03.
        ENDCASE.
        CLEAR so_bwart.
      ENDLOOP.

    WHEN radio4.
      LOOP AT gt_zmmewas INTO ls_zmmewas WHERE seqno = '09'
                                            OR seqno = '10'.
        PERFORM f_selopt  USING '' ls_zmmewas-bwart.

        CASE ls_zmmewas-seqno.
          WHEN '09'.
            APPEND so_bwart TO gr_bwart01.
          WHEN '10'.
            APPEND so_bwart TO gr_bwart02.
        ENDCASE.
        CLEAR so_bwart.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_INIT_BWART

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : sellist      TYPE STANDARD TABLE OF vimsellist INITIAL SIZE 0.
  DATA : selection    TYPE vimsellist.
  DATA : ls_lgort     LIKE LINE OF gr_lgort00.

  DEFINE addpar.
    if &2 is not initial.
      clear selection.
      selection-viewfield = &1.
      selection-value = &2.
*      selection-and_or = 'AND'.
      selection-operator = 'EQ'.
      append selection to sellist.
    endif.
  END-OF-DEFINITION.

  PERFORM f_ztspmmdt002.
  PERFORM f_material.
  PERFORM f_s933.

  ls_lgort-low    = '1000'.
  ls_lgort-high   = '9999'.
  ls_lgort-sign   = 'I'.
  ls_lgort-option = 'BT'.
  APPEND ls_lgort TO gr_lgort00.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_negara.

      PERFORM f_opening_stock.
      PERFORM f_pemasukan_bb.
      PERFORM f_summary_mseg.
      PERFORM f_gabungan_mchb_mch1.
      PERFORM f_split_data.

    WHEN radio2.
      PERFORM f_pemasukan_bb.
      PERFORM f_penggunaan_bb.
      PERFORM f_summary_mseg.
      PERFORM f_split_data.
      PERFORM f_nilai.

    WHEN radio3.
      PERFORM f_opening_stock.
      PERFORM f_produksi_oj.
      PERFORM f_gabungan_mchb_mch1.
      PERFORM f_split_data.
      PERFORM f_nilai_rupiah.

    WHEN radio4.
      PERFORM f_negara.

      PERFORM f_distribusi_oj.
      PERFORM f_split_data.
      PERFORM f_nilai_ekspor.

    WHEN radio5.
      addpar 'WERKS' pa_werks.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          action                       = 'U'
          view_name                    = 'ZTSPMMDT002'
        TABLES
          dba_sellist                  = sellist
        EXCEPTIONS
          client_reference             = 1
          foreign_lock                 = 2
          invalid_action               = 3
          no_clientindependent_auth    = 4
          no_database_function         = 5
          no_editor_function           = 6
          no_show_auth                 = 7
          no_tvdir_entry               = 8
          no_upd_auth                  = 9
          only_show_allowed            = 10
          system_failure               = 11
          unknown_field_in_dba_sellist = 12
          view_not_found               = 13
          maintenance_prohibited       = 14
          OTHERS                       = 15.

  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : ls_zmmst01     LIKE LINE OF gt_zmmst01,
         ls_zmmst01a    LIKE LINE OF gt_zmmst01a,
         ls_zmmst01b    LIKE LINE OF gt_zmmst01b,
         ls_opnstk      LIKE LINE OF gt_opnstk,
         ls_mch1        LIKE LINE OF gt_mch1,
         ls_mara        LIKE LINE OF gt_mara,
         ls_makt        LIKE LINE OF gt_makt,
         ls_marm        LIKE LINE OF gt_marm,
         ls_002         LIKE LINE OF gt_002,
         ls_mseg        LIKE LINE OF gt_msegopn,
         ls_sum         LIKE LINE OF gt_msegsum,
         ls_mkpf        LIKE LINE OF gt_mkpf,
         ls_t023t       LIKE LINE OF gt_t023t,
         ls_t157e       LIKE LINE OF gt_t157e,
         ls_kna1        LIKE LINE OF gt_kna1,
         ls_t005t       LIKE LINE OF gt_t005t,
         ls_vbap        LIKE LINE OF gt_vbap,
         ls_lfa1        LIKE LINE OF gt_lfa1,
         lv_zmf         TYPE cabn-atinn,
         lv_zcountry    TYPE cabn-atinn,
         lv_nou         TYPE zmmst01-nou,
         lv_menge       TYPE mseg-menge,
         lv_meins       TYPE mseg-meins,
         lv_meins1      TYPE mseg-meins,
         lv_shkzg       TYPE mseg-shkzg,
         lv_tabix       TYPE sy-tabix,
         lv_werks       TYPE mseg-werks.

  DATA : ls_zmmst02     LIKE LINE OF gt_zmmst02,
         ls_zmmst02a    LIKE LINE OF gt_zmmst02a,
         ls_mbewh       LIKE LINE OF gt_mbewh,
         ls_mbew        LIKE LINE OF gt_mbew,
         lv_verpr       TYPE mbew-salk3,
         ls_nilai       LIKE LINE OF gt_nilai.

  DATA : ls_zmmst03     LIKE LINE OF gt_zmmst03,
         ls_zmmst03a    LIKE LINE OF gt_zmmst03a,
         ls_price       LIKE LINE OF gt_price,
         ls_konp        LIKE LINE OF gt_konp,
         lv_kbetr       TYPE wertv9.

  DATA : ls_zmmst04     LIKE LINE OF gt_zmmst04,
         ls_zmmst04a    LIKE LINE OF gt_zmmst04a,
         ls_zmmst04b    LIKE LINE OF gt_zmmst04b,
         ls_vbfa        LIKE LINE OF gt_vbfa,
         lv_vbeln       TYPE vbfa-vbeln,
         lv_posnn       TYPE vbfa-posnn,
         lv_nilai       TYPE vbap-netpr,
         lv_total       TYPE vbap-netpr.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = 'ZMF'
    IMPORTING
      output = lv_zmf.

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = 'ZMF_COUNTRY'
    IMPORTING
      output = lv_zcountry.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_mara INTO ls_mara.
        CLEAR ls_makt.
        READ TABLE gt_makt INTO ls_makt
                            WITH KEY matnr = ls_mara-matnr.

        CLEAR ls_t023t.
        READ TABLE gt_t023t INTO ls_t023t
                            WITH KEY matkl = ls_mara-matkl.

        ls_zmmst01-kode_bahan_baku    = ls_mara-matnr.
        ls_zmmst01-jenis_bahan_baku   = ls_t023t-wgbez.
        ls_zmmst01-nama_bahan_baku    = ls_makt-maktg.

        PERFORM f_conversion_measurement USING ls_mara-meins
                                         CHANGING ls_zmmst01-satuan.

        SORT gt_opnstk BY charg.
        LOOP AT gt_opnstk INTO ls_opnstk WHERE matnr = ls_mara-matnr.
          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                             WITH KEY matnr = ls_opnstk-matnr
                                      charg = ls_opnstk-charg.
          IF sy-subrc = 0.
            ls_zmmst01-vendor_batch       = ls_mch1-licha.
          ELSE.
            CLEAR ls_zmmst01-vendor_batch.
          ENDIF.

          ls_zmmst01-jenis_pemasukan    = 'Stok Awal'.

          IF ls_opnstk-labst IS INITIAL.
            CONTINUE.
          ENDIF.

          PERFORM f_field_modify USING 'U' ls_mara-matnr ls_opnstk-labst
                                       ls_mara-meins '' '' ''
                                 CHANGING ls_zmmst01-jumlah.

          ls_zmmst01-batch              = ls_opnstk-charg.
          PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mch1-vfdat
                                       '' '' '' ''
                                 CHANGING ls_zmmst01-tanggal_expired.

          PERFORM f_pembuat USING ls_opnstk-matnr ls_opnstk-charg lv_zmf lv_zcountry
                                  ls_mch1-cuobj_bm
                            CHANGING ls_zmmst01-nama_pabrik_pembuat
                                     ls_zmmst01-kode_negara_pembuat
                                     ls_zmmst01-nama_negara_pembuat.

          CLEAR : ls_lfa1, lv_werks.
          READ TABLE gt_lfa1 INTO ls_lfa1
                             WITH KEY matnr = ls_opnstk-matnr
                                      werks = ls_opnstk-werks
                                      charg = ls_opnstk-charg.
          IF sy-subrc = 0.
            IF ls_lfa1-werkslfa1 IS INITIAL.
            ELSEIF ls_lfa1-werkslfa1 <> ls_opnstk-werks.
              lv_werks  = ls_lfa1-werkslfa1.
              READ TABLE gt_lfa1 INTO ls_lfa1
                                 WITH KEY matnr = ls_opnstk-matnr
                                          werks = lv_werks
                                          charg = ls_opnstk-charg.
            ENDIF.
            PERFORM f_field_modify USING 'D' ls_opnstk-matnr ls_lfa1-budat
                                         '' '' '' ''
                                   CHANGING ls_zmmst01-tanggal_pemasukan.

            ls_zmmst01-kode_distributor  = ls_lfa1-lifnr.
            ls_zmmst01-nama_distributor  = ls_lfa1-name1.
          ELSE.
            CLEAR : ls_zmmst01-kode_distributor,
                    ls_zmmst01-nama_distributor,
                    ls_zmmst01-tanggal_pemasukan.
          ENDIF.

          ls_zmmst01-nou  = 1.

          APPEND ls_zmmst01 TO gt_zmmst01.
        ENDLOOP.

        SORT gt_msegsum BY matnr charg.
        SORT gt_msegtrn BY matnr charg.

        LOOP AT gt_msegsum INTO ls_sum WHERE matnr = ls_mara-matnr.
          CLEAR ls_mkpf.
          READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_sum-mblnr
                                                   mjahr = ls_sum-mjahr.
          IF sy-subrc = 0.
            PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mkpf-budat
                                         '' '' '' ''
                                   CHANGING ls_zmmst01-tanggal_pemasukan.
          ELSE.
            CLEAR ls_zmmst01-tanggal_pemasukan.
          ENDIF.

          ls_zmmst01-kode_bahan_baku    = ls_sum-matnr.
          ls_zmmst01-batch              = ls_sum-charg.

          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                             WITH KEY matnr = ls_sum-matnr
                                      charg = ls_sum-charg.
          IF sy-subrc = 0.
            ls_zmmst01-vendor_batch       = ls_mch1-licha.
          ELSE.
            CLEAR ls_zmmst01-vendor_batch.
          ENDIF.

          PERFORM f_field_modify USING 'D' ls_sum-matnr ls_mch1-vfdat
                                                 '' '' '' ''
                                           CHANGING ls_zmmst01-tanggal_expired.

          PERFORM f_pembuat USING ls_sum-matnr ls_sum-charg lv_zmf lv_zcountry
                                  ls_mch1-cuobj_bm
                            CHANGING ls_zmmst01-nama_pabrik_pembuat
                                     ls_zmmst01-kode_negara_pembuat
                                     ls_zmmst01-nama_negara_pembuat.

          CLEAR : ls_lfa1, lv_werks.
          READ TABLE gt_lfa1 INTO ls_lfa1
                             WITH KEY matnr = ls_sum-matnr
                                      werks = ls_sum-werks
                                      charg = ls_sum-charg.
          IF sy-subrc = 0.
            IF ls_lfa1-werkslfa1 IS INITIAL.
            ELSEIF ls_lfa1-werkslfa1 <> ls_sum-werks.
              lv_werks  = ls_lfa1-werkslfa1.
              READ TABLE gt_lfa1 INTO ls_lfa1
                                 WITH KEY matnr = ls_sum-matnr
                                          werks = lv_werks
                                          charg = ls_sum-charg.
            ENDIF.
            ls_zmmst01-kode_distributor  = ls_lfa1-lifnr.
            ls_zmmst01-nama_distributor  = ls_lfa1-name1.
          ELSE.
            CLEAR : ls_zmmst01-kode_distributor,
                    ls_zmmst01-nama_distributor.
          ENDIF.

* Penerimaan
          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m01 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.
            ls_zmmst01-jenis_pemasukan    = 'Penerimaan'.
            ls_zmmst01-nou  = 2.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.
          ENDLOOP.

          IF lv_menge >= 0.
            lv_shkzg  = 'S'.
          ELSE.
            lv_shkzg  = 'H'.
          ENDIF.

          IF lv_menge > 0.
            PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                                         ls_zmmst01-satuan
                                         '' '' lv_shkzg
                                   CHANGING ls_zmmst01-jumlah.

            APPEND ls_zmmst01 TO gt_zmmst01.
          ENDIF.

* Koreksi Stock
          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m02 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.
*                                        AND lgort = '1000'.
            ls_zmmst01-jenis_pemasukan    = 'Koreksi Stock'.
            ls_zmmst01-nou  = 3.

            CLEAR ls_t157e.
            READ TABLE gt_t157e INTO ls_t157e WITH KEY bwart = ls_mseg-bwart
                                                       grund = ls_mseg-grund.
            IF sy-subrc = 0.
              ls_zmmst01-keterangan   = ls_t157e-grtxt.
            ENDIF.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.
          ENDLOOP.

          IF lv_menge >= 0.
            lv_shkzg  = 'S'.
          ELSE.
            lv_shkzg  = 'H'.
          ENDIF.

          IF lv_menge IS NOT INITIAL.
            PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                               ls_zmmst01-satuan
                               '' '' lv_shkzg
                         CHANGING ls_zmmst01-jumlah.

            APPEND ls_zmmst01 TO gt_zmmst01.
            CLEAR ls_zmmst01-keterangan.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      SORT gt_zmmst01 BY nou kode_bahan_baku batch.
      LOOP AT gt_zmmst01 INTO ls_zmmst01.
        ADD 1 TO lv_nou.
        ls_zmmst01-nou = lv_nou.
        MODIFY gt_zmmst01 FROM ls_zmmst01 TRANSPORTING nou.
      ENDLOOP.

      SORT gt_zmmst01b BY kode_negara_pembuat.
      DELETE ADJACENT DUPLICATES FROM gt_zmmst01b COMPARING kode_negara_pembuat.
      SORT gt_zmmst01a BY kode_bahan_baku.

    WHEN radio2.
      LOOP AT gt_mara INTO ls_mara.
        CLEAR ls_makt.
        READ TABLE gt_makt INTO ls_makt
                            WITH KEY matnr = ls_mara-matnr.

        CLEAR ls_t023t.
        READ TABLE gt_t023t INTO ls_t023t
                            WITH KEY matkl = ls_mara-matkl.

        ls_zmmst02-kode_bahan_baku    = ls_mara-matnr.
        ls_zmmst02-jenis_bahan_baku   = ls_t023t-wgbez.
        ls_zmmst02-nama_bahan_baku    = ls_makt-maktg.

        PERFORM f_conversion_measurement USING ls_mara-meins
                                         CHANGING ls_zmmst02-satuan.

        SORT gt_msegsum BY matnr charg.
        SORT gt_msegtrn BY matnr charg.

        LOOP AT gt_msegsum INTO ls_sum WHERE matnr = ls_mara-matnr.
          ls_zmmst02-kode_bahan_baku    = ls_sum-matnr.
          ls_zmmst02-batch              = ls_sum-charg.

          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                             WITH KEY matnr = ls_sum-matnr
                                      charg = ls_sum-charg.
          IF sy-subrc = 0.
            ls_zmmst02-vendor_batch       = ls_mch1-licha.
          ELSE.
            CLEAR ls_zmmst02-vendor_batch.
          ENDIF.

          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m03 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.

            CLEAR ls_mkpf.
            READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_mseg-mblnr
                                                     mjahr = ls_mseg-mjahr.
            IF sy-subrc = 0.
              PERFORM f_field_modify USING 'D' ls_mseg-matnr ls_mkpf-budat
                                           '' '' '' ''
                                     CHANGING ls_zmmst02-tanggal_penggunaan.

              CLEAR : lv_verpr, ls_nilai.
              READ TABLE gt_nilai INTO ls_nilai WITH KEY matnr = ls_mseg-matnr
                                                         bwkey = ls_mseg-werks
                                                         lfgja = ls_mkpf-budat(4)
                                                         lfmon = ls_mkpf-budat+4(2).
              IF sy-subrc = 0.
                lv_verpr  = ls_nilai-verpr.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF lv_menge < 0.
            ls_zmmst02-jenis_penggunaan    = 'Koreksi Stock'.
            ls_zmmst02-nou  = 3.
            ls_zmmst01-keterangan = 'Reject'.

            lv_shkzg  = 'S'.
            lv_menge  = ABS( lv_menge ).

            PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                                         ls_zmmst02-satuan
                                         '' '' lv_shkzg
                                   CHANGING ls_zmmst02-jumlah.

            lv_verpr  = lv_verpr * lv_menge.
            PERFORM f_field_modify USING 'C' ls_sum-matnr lv_verpr
                                         '' 'IDR' '' ''
                                   CHANGING ls_zmmst02-nilai_rupiah.

            APPEND ls_zmmst02 TO gt_zmmst02.
            CLEAR : ls_zmmst02-keterangan.
          ENDIF.

* Penggunaan Komersial
          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m01 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.
            ls_zmmst02-jenis_penggunaan    = 'Penggunaan Komersial'.
            ls_zmmst02-nou  = 2.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.

            CLEAR ls_mkpf.
            READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_mseg-mblnr
                                                     mjahr = ls_mseg-mjahr.
            IF sy-subrc = 0.
              PERFORM f_field_modify USING 'D' ls_mseg-matnr ls_mkpf-budat
                                           '' '' '' ''
                                     CHANGING ls_zmmst02-tanggal_penggunaan.

              CLEAR : lv_verpr, ls_nilai.
              READ TABLE gt_nilai INTO ls_nilai WITH KEY matnr = ls_mseg-matnr
                                                         bwkey = ls_mseg-werks
                                                         lfgja = ls_mkpf-budat(4)
                                                         lfmon = ls_mkpf-budat+4(2).
              IF sy-subrc = 0.
                lv_verpr  = ls_nilai-verpr.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF lv_menge >= 0.
            lv_shkzg  = 'S'.
          ELSE.
            lv_shkzg  = 'H'.
          ENDIF.

          IF lv_menge IS NOT INITIAL.
            PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                                         ls_zmmst02-satuan
                                         '' '' lv_shkzg
                                   CHANGING ls_zmmst02-jumlah.

*          lv_menge  = ABS( lv_menge ).
            lv_verpr  = ABS( lv_verpr * lv_menge ).
            PERFORM f_field_modify USING 'C' ls_sum-matnr lv_verpr
                                         '' 'IDR' '' ''
                                   CHANGING ls_zmmst02-nilai_rupiah.

            APPEND ls_zmmst02 TO gt_zmmst02.
          ENDIF.
* Koreksi Stock
          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m02 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.
            ls_zmmst02-jenis_penggunaan    = 'Koreksi Stock'.
            ls_zmmst02-nou  = 3.

            CLEAR ls_t157e.
            READ TABLE gt_t157e INTO ls_t157e WITH KEY bwart = ls_mseg-bwart
                                                       grund = ls_mseg-grund.
            IF sy-subrc = 0.
              ls_zmmst01-keterangan   = ls_t157e-grtxt.
            ELSE.
              CLEAR ls_zmmst01-keterangan.
            ENDIF.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.

            CLEAR ls_mkpf.
            READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_mseg-mblnr
                                                     mjahr = ls_mseg-mjahr.
            IF sy-subrc = 0.
              PERFORM f_field_modify USING 'D' ls_mseg-matnr ls_mkpf-budat
                                           '' '' '' ''
                                     CHANGING ls_zmmst02-tanggal_penggunaan.

              CLEAR : lv_verpr, ls_nilai.
              READ TABLE gt_nilai INTO ls_nilai WITH KEY matnr = ls_mseg-matnr
                                                         bwkey = ls_mseg-werks
                                                         lfgja = ls_mkpf-budat(4)
                                                         lfmon = ls_mkpf-budat+4(2).
              IF sy-subrc = 0.
                lv_verpr  = ls_nilai-verpr.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF lv_menge >= 0.
            lv_shkzg  = 'S'.
          ELSE.
            lv_shkzg  = 'H'.
          ENDIF.

          IF lv_menge IS NOT INITIAL.
            PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                                         ls_zmmst02-satuan
                                         '' '' lv_shkzg
                                   CHANGING ls_zmmst02-jumlah.

*          lv_menge  = ABS( lv_menge ).
            lv_verpr  = ABS( lv_verpr * lv_menge ).
            PERFORM f_field_modify USING 'C' ls_sum-matnr lv_verpr
                                         '' 'IDR' '' ''
                                   CHANGING ls_zmmst02-nilai_rupiah.

            APPEND ls_zmmst02 TO gt_zmmst02.
            CLEAR : ls_zmmst02-keterangan.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      SORT gt_zmmst02 BY nou kode_bahan_baku batch.
      LOOP AT gt_zmmst02 INTO ls_zmmst02.
        ADD 1 TO lv_nou.
        ls_zmmst02-nou = lv_nou.
        MODIFY gt_zmmst02 FROM ls_zmmst02 TRANSPORTING nou.
      ENDLOOP.

      SORT gt_zmmst02a BY kode_bahan_baku.

    WHEN radio3.
      LOOP AT gt_mara INTO ls_mara.
        CLEAR ls_makt.
        READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_mara-matnr.
        CLEAR ls_marm.
        READ TABLE gt_marm INTO ls_marm WITH KEY matnr = ls_mara-matnr.
        CLEAR ls_002.
        READ TABLE gt_002 INTO ls_002 WITH KEY matnr = ls_mara-matnr.

        ls_zmmst03-kode_obat_jadi    = ls_mara-matnr.
        ls_zmmst03-nama_obat_jadi    = ls_makt-maktg.
        ls_zmmst03-nie               = ls_002-nie.
*        ls_zmmst03-satuan            = ls_marm-msehl.
        IF ls_marm-umren = 1.
          PERFORM f_conversion_measurement USING ls_mara-meins
                                           CHANGING ls_zmmst03-satuan.
        ELSE.
          PERFORM f_conversion_measurement USING ls_marm-meinh
                                           CHANGING ls_zmmst03-satuan.
        ENDIF.

        SORT gt_opnstk BY charg.
        LOOP AT gt_opnstk INTO ls_opnstk WHERE matnr = ls_mara-matnr.
          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                             WITH KEY matnr = ls_opnstk-matnr
                                      charg = ls_opnstk-charg.

          ls_zmmst03-jenis_produksi    = 'Stok Awal'.
          PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mch1-hsdat
                                       '' '' '' ''
                                 CHANGING ls_zmmst03-tanggal_produksi.

          PERFORM f_price_calculate USING ls_mara-matnr ls_mch1-hsdat ls_opnstk-labst
                                    CHANGING ls_zmmst03-nilai_rupiah.

*          PERFORM f_field_modify USING 'C' ls_mara-matnr ls_zmmst03-nilai_rupiah
*                                       '' 'IDR' '' ''
*                                 CHANGING ls_zmmst03-nilai_rupiah.

          ls_opnstk-labst = ls_opnstk-labst * ls_marm-umren.

          IF ls_opnstk-labst IS NOT INITIAL.

            PERFORM f_field_modify USING 'U' ls_mara-matnr ls_opnstk-labst
                                         ls_marm-meinh '' '' ''
                                   CHANGING ls_zmmst03-jumlah.

            ls_zmmst03-batch              = ls_opnstk-charg.
            PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mch1-vfdat
                                         '' '' '' ''
                                   CHANGING ls_zmmst03-tanggal_expired.

*          CLEAR : ls_price, ls_konp, lv_kbetr.
*          LOOP AT gt_price INTO ls_price WHERE matnr = ls_mara-matnr.
*            LOOP AT gt_konp INTO ls_konp WHERE knumh = ls_price-knumh.
*              ADD ls_konp-kbetr TO lv_kbetr.
*            ENDLOOP.
*          ENDLOOP.
*
*          lv_kbetr  = lv_kbetr * ls_opnstk-labst.
*          PERFORM f_field_modify USING 'C' ls_mara-matnr lv_kbetr
*                                       '' 'IDR' '' ''
*                                 CHANGING ls_zmmst03-nilai_rupiah.

            CLEAR ls_lfa1.
            READ TABLE gt_lfa1 INTO ls_lfa1
                               WITH KEY matnr = ls_opnstk-matnr
                                        charg = ls_opnstk-charg
                                        werks = ls_opnstk-werks.
            IF sy-subrc = 0.
              ls_zmmst03-penerima_toll   = ls_lfa1-name1.
            ELSE.
              CLEAR ls_zmmst03-penerima_toll.
            ENDIF.

            ls_zmmst03-nou  = 1.

            APPEND ls_zmmst03 TO gt_zmmst03.
          ENDIF.
        ENDLOOP.

        SORT gt_msegsum BY matnr charg.
        SORT gt_msegtrn BY matnr charg.

        LOOP AT gt_msegsum INTO ls_sum WHERE matnr = ls_mara-matnr.
          CLEAR ls_mch1.
          READ TABLE gt_mch1 INTO ls_mch1
                             WITH KEY matnr = ls_sum-matnr
                                      charg = ls_sum-charg.

          CLEAR ls_mkpf.
          READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_sum-mblnr
                                                   mjahr = ls_sum-mjahr.
          IF sy-subrc = 0.
            PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mkpf-budat
                                         '' '' '' ''
                                   CHANGING ls_zmmst03-tanggal_produksi.
          ENDIF.

          ls_zmmst03-batch              = ls_sum-charg.

          PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mch1-vfdat
                                                 '' '' '' ''
                                           CHANGING ls_zmmst03-tanggal_expired.

          IF ls_mara-labor = 'IM'.
            ls_zmmst03-jenis_produksi    = 'Impor'.
            ls_zmmst03-nou  = 2.

            CLEAR lv_menge.
            LOOP AT gt_msegtrn INTO ls_mseg WHERE matnr = ls_sum-matnr
                                              AND charg = ls_sum-charg
                                              AND lgort = '3000'.
              IF ls_mseg-shkzg = 'H'.
                lv_menge = lv_menge - ls_mseg-menge.
              ELSE.
                ADD ls_mseg-menge TO lv_menge.
              ENDIF.
              lv_meins  = ls_mseg-meins.
            ENDLOOP.

            IF lv_menge >= 0.
              lv_shkzg  = 'S'.
            ELSE.
              lv_shkzg  = 'H'.
            ENDIF.

            PERFORM f_price_calculate USING ls_sum-matnr ls_mkpf-budat lv_menge
                                      CHANGING ls_zmmst03-nilai_rupiah.

*            PERFORM f_field_modify USING 'C' ls_mara-matnr ls_zmmst03-nilai_rupiah
*                                         '' 'IDR' '' ''
*                                   CHANGING ls_zmmst03-nilai_rupiah.

            lv_menge  = lv_menge * ls_marm-umren.

            IF lv_menge IS NOT INITIAL.
              CLEAR ls_lfa1.
              READ TABLE gt_lfa1 INTO ls_lfa1
                                 WITH KEY matnr = ls_sum-matnr
                                          charg = ls_sum-charg
                                          werks = ls_sum-werks
                                          lifnr = ls_sum-lifnr.
              IF sy-subrc = 0.
                ls_zmmst03-penerima_toll   = ls_lfa1-name1.
              ELSE.
                CLEAR ls_zmmst03-penerima_toll.
              ENDIF.

              PERFORM f_field_modify USING 'U' ls_mara-matnr lv_menge ls_marm-meinh
                                           '' '' lv_shkzg
                                     CHANGING ls_zmmst03-jumlah.

              APPEND ls_zmmst03 TO gt_zmmst03.
            ENDIF.
          ELSE.
* Produksi Komersial
            CLEAR : lv_menge, ls_mseg.
            LOOP AT gt_m02 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                          AND charg = ls_sum-charg
                                          AND ( lgort = '3000'
                                           OR lgort = '3099' ).
              ls_zmmst03-jenis_produksi    = 'Produksi Komersial'.
              ls_zmmst03-nou  = 3.
              IF ( ls_mseg-lgort = '3000' AND ls_mseg-umlgo = '3099' ) OR ( ls_mseg-lgort = '3099' AND ls_mseg-umlgo = '3000' ).
                CONTINUE.
              ELSE.
                IF ls_mseg-shkzg = 'H'.
                  lv_menge = lv_menge - ls_mseg-menge.
                ELSE.
                  ADD ls_mseg-menge TO lv_menge.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF lv_menge >= 0.
              lv_shkzg  = 'S'.
            ELSE.
              lv_shkzg  = 'H'.
            ENDIF.

            PERFORM f_price_calculate USING ls_sum-matnr ls_mkpf-budat lv_menge
                                      CHANGING ls_zmmst03-nilai_rupiah.

*            PERFORM f_field_modify USING 'C' ls_mara-matnr ls_zmmst03-nilai_rupiah
*                                         '' 'IDR' '' ''
*                                   CHANGING ls_zmmst03-nilai_rupiah.

            lv_menge  = lv_menge * ls_marm-umren.

            IF lv_menge IS NOT INITIAL.
              CLEAR ls_lfa1.
              READ TABLE gt_lfa1 INTO ls_lfa1
                                 WITH KEY matnr = ls_sum-matnr
                                          charg = ls_sum-charg
                                          werks = ls_sum-werks
                                          lifnr = ls_sum-lifnr.
              IF sy-subrc = 0.
                ls_zmmst03-penerima_toll   = ls_lfa1-name1.
              ELSE.
                CLEAR ls_zmmst03-penerima_toll.
              ENDIF.

              PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                                           ls_marm-meinh
                                           '' '' lv_shkzg
                                     CHANGING ls_zmmst03-jumlah.

              APPEND ls_zmmst03 TO gt_zmmst03.
            ENDIF.
* Reject
            CLEAR : lv_menge, ls_mseg.
            LOOP AT gt_m03 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                          AND charg = ls_sum-charg.
              ls_zmmst03-jenis_produksi    = 'Reject'.
              ls_zmmst03-nou  = 4.

              CLEAR ls_t157e.
              READ TABLE gt_t157e INTO ls_t157e WITH KEY bwart = ls_mseg-bwart
                                                         grund = ls_mseg-grund.
              IF sy-subrc = 0.
                ls_zmmst03-keterangan   = ls_t157e-grtxt.
              ENDIF.

              IF ls_mseg-shkzg = 'H'.
                lv_menge = lv_menge - ls_mseg-menge.
              ELSE.
                ADD ls_mseg-menge TO lv_menge.
              ENDIF.
            ENDLOOP.

            IF lv_menge >= 0.
              lv_shkzg  = 'S'.
            ELSE.
              lv_shkzg  = 'H'.
            ENDIF.

            PERFORM f_price_calculate USING ls_sum-matnr ls_mkpf-budat ls_opnstk-labst
                                      CHANGING ls_zmmst03-nilai_rupiah.

*            PERFORM f_field_modify USING 'C' ls_mara-matnr ls_zmmst03-nilai_rupiah
*                                         '' 'IDR' '' ''
*                                   CHANGING ls_zmmst03-nilai_rupiah.

            lv_menge  = lv_menge * ls_marm-umren.

            IF lv_menge IS NOT INITIAL.
              CLEAR ls_lfa1.
              READ TABLE gt_lfa1 INTO ls_lfa1
                                 WITH KEY matnr = ls_sum-matnr
                                          charg = ls_sum-charg
                                          werks = ls_sum-werks
                                          lifnr = ls_sum-lifnr.
              IF sy-subrc = 0.
                ls_zmmst03-penerima_toll   = ls_lfa1-name1.
              ELSE.
                CLEAR ls_zmmst03-penerima_toll.
              ENDIF.

              PERFORM f_field_modify USING 'U' ls_sum-matnr lv_menge
                                           ls_marm-meinh
                                           '' '' lv_shkzg
                                     CHANGING ls_zmmst03-jumlah.

              APPEND ls_zmmst03 TO gt_zmmst03.
              CLEAR : ls_zmmst03-keterangan.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      SORT gt_zmmst03 BY nou kode_obat_jadi batch.
      LOOP AT gt_zmmst03 INTO ls_zmmst03.
        ADD 1 TO lv_nou.
        ls_zmmst03-nou = lv_nou.
        MODIFY gt_zmmst03 FROM ls_zmmst03 TRANSPORTING nou.
      ENDLOOP.

      SORT gt_zmmst03a BY kode_obat_jadi.

    WHEN radio4.
      LOOP AT gt_mara INTO ls_mara.
        CLEAR ls_makt.
        READ TABLE gt_makt INTO ls_makt
                            WITH KEY matnr = ls_mara-matnr.

        ls_zmmst04-kode_obat_jadi    = ls_mara-matnr.
        ls_zmmst04-nama_obat_jadi    = ls_makt-maktg.

        CLEAR ls_002.
        READ TABLE gt_002 INTO ls_002 WITH KEY matnr  = ls_mara-matnr.
        IF sy-subrc = 0.
          ls_zmmst04-nie    = ls_002-nie.
        ENDIF.

        CLEAR ls_marm.
        READ TABLE gt_marm INTO ls_marm WITH KEY matnr = ls_mara-matnr.
        IF ls_marm-umren = 1.
          PERFORM f_conversion_measurement USING ls_mara-meins
                                           CHANGING ls_zmmst04-satuan.
        ELSE.
          PERFORM f_conversion_measurement USING ls_marm-meinh
                                           CHANGING ls_zmmst04-satuan.
        ENDIF.

        SORT gt_msegsum BY matnr charg.
        SORT gt_msegtrn BY matnr charg.

        LOOP AT gt_msegsum INTO ls_sum WHERE matnr = ls_mara-matnr.
          CLEAR ls_mkpf.
          READ TABLE gt_mkpf INTO ls_mkpf WITH KEY mblnr = ls_sum-mblnr
                                                   mjahr = ls_sum-mjahr.
          IF sy-subrc = 0.
            PERFORM f_field_modify USING 'D' ls_mara-matnr ls_mkpf-budat
                                         '' '' '' ''
                                   CHANGING ls_zmmst04-tanggal_distribusi.
          ENDIF.

          ls_zmmst04-kode_obat_jadi     = ls_sum-matnr.
          ls_zmmst04-batch              = ls_sum-charg.
          CLEAR ls_kna1.
          READ TABLE gt_kna1 INTO ls_kna1 WITH KEY kunnr = ls_sum-kunnr.
          IF sy-subrc = 0.
            ls_zmmst04-nama_pbf_importir      = ls_kna1-name1.
            ls_zmmst04-kode_negara_importir   = ls_kna1-land1.
            CLEAR ls_t005t.
            READ TABLE gt_t005t INTO ls_t005t WITH KEY land1 = ls_kna1-land1.
            IF sy-subrc = 0.
              ls_zmmst04-nama_importir   = ls_t005t-landx.
            ENDIF.
          ELSE.
            CLEAR : ls_zmmst04-nama_pbf_importir,
                    ls_zmmst04-kode_negara_importir,
                    ls_zmmst04-nama_importir.
          ENDIF.

* Dalam Negeri
          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m01 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.

            ls_zmmst04-jenis_distribusi    = 'Dalam Negeri'.
            ls_zmmst04-nou  = 1.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.
            lv_meins  = ls_mseg-meins.

            lv_vbeln  = ls_mseg-mblnr.
            lv_posnn  = ls_mseg-zeile.
            CLEAR : lv_nilai, lv_total.
            LOOP AT gt_vbfa INTO ls_vbfa WHERE vbeln = lv_vbeln
                                           AND posnn = lv_posnn.
              LOOP AT gt_vbap INTO ls_vbap WHERE vbeln = ls_vbfa-vbelv
                                             AND posnr = ls_vbfa-posnv.
                lv_nilai  = ls_vbap-netpr / ls_vbap-kpein.
                ADD lv_nilai TO lv_total.
                lv_meins1 = ls_vbap-meins.
              ENDLOOP.
            ENDLOOP.
          ENDLOOP.

          lv_menge  = lv_menge * ls_marm-umren.
          lv_total = lv_total * lv_menge.

          IF lv_menge >= 0.
            lv_shkzg  = 'S'.
          ELSE.
            lv_shkzg  = 'H'.
          ENDIF.

          PERFORM f_field_modify USING 'U' ls_mara-matnr lv_menge lv_meins
                                       '' '' lv_shkzg
                                 CHANGING ls_zmmst04-jumlah.

*          lv_menge  = ABS( lv_menge ).
          lv_verpr  = lv_verpr * lv_menge.
          PERFORM f_field_modify USING 'C' ls_mara-matnr lv_verpr
                                       '' 'IDR' '' ''
                                 CHANGING ls_zmmst04-nilai_ekspor.

          IF lv_menge IS NOT INITIAL.
            APPEND ls_zmmst04 TO gt_zmmst04.
          ENDIF.

* Ekspor
          CLEAR : lv_menge, ls_mseg.
          LOOP AT gt_m02 INTO ls_mseg WHERE matnr = ls_sum-matnr
                                        AND charg = ls_sum-charg.

            PERFORM f_field_modify USING 'U' ls_mara-matnr lv_total lv_meins ''
                                         lv_meins1 lv_shkzg
                                   CHANGING ls_zmmst04-nilai_ekspor.

            ls_zmmst04-jenis_distribusi    = 'Ekspor'.
            ls_zmmst04-nou  = 2.

            IF ls_mseg-shkzg = 'H'.
              lv_menge = lv_menge - ls_mseg-menge.
            ELSE.
              ADD ls_mseg-menge TO lv_menge.
            ENDIF.
            lv_meins  = ls_mseg-meins.

            lv_vbeln  = ls_mseg-mblnr.
            lv_posnn  = ls_mseg-zeile.
            CLEAR : lv_nilai, lv_total.
            LOOP AT gt_vbfa INTO ls_vbfa WHERE vbeln = lv_vbeln
                                           AND posnn = lv_posnn.
              LOOP AT gt_vbap INTO ls_vbap WHERE vbeln = ls_vbfa-vbelv
                                             AND posnr = ls_vbfa-posnv.
                lv_nilai  = ls_vbap-netpr / ls_vbap-kpein.
                ADD lv_nilai TO lv_total.
                lv_meins1 = ls_vbap-meins.
              ENDLOOP.
            ENDLOOP.
          ENDLOOP.

          lv_menge  = lv_menge * ls_marm-umren.
          lv_total = lv_total * lv_menge.

          IF lv_menge >= 0.
            lv_shkzg  = 'S'.
          ELSE.
            lv_shkzg  = 'H'.
          ENDIF.

          PERFORM f_field_modify USING 'U' ls_mara-matnr lv_menge lv_meins
                                       '' '' lv_shkzg
                                 CHANGING ls_zmmst04-jumlah.

*          lv_menge  = ABS( lv_menge ).
          lv_verpr  = lv_verpr * lv_menge.
          PERFORM f_field_modify USING 'C' ls_mara-matnr lv_verpr
                                       '' 'IDR' '' ''
                                 CHANGING ls_zmmst04-nilai_ekspor.

          ls_zmmst04-nama_eksportir   = 'PT TEMPO SCAN PACIFIC'.

          IF lv_menge IS NOT INITIAL.
            APPEND ls_zmmst04 TO gt_zmmst04.
          ENDIF.
          CLEAR : ls_zmmst04-keterangan.
        ENDLOOP.
      ENDLOOP.

      SORT gt_zmmst04 BY nou kode_obat_jadi batch.
      LOOP AT gt_zmmst04 INTO ls_zmmst04.
        ADD 1 TO lv_nou.
        ls_zmmst04-nou = lv_nou.
        MODIFY gt_zmmst04 FROM ls_zmmst04 TRANSPORTING nou.
      ENDLOOP.

      SORT gt_zmmst04a BY kode_obat_jadi.
      SORT gt_zmmst04b BY kode_negara_pembuat.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_print_radio1.
    WHEN radio2.
      PERFORM f_print_radio2.
    WHEN radio3.
      PERFORM f_print_radio3.
    WHEN radio4.
      PERFORM f_print_radio4.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_OPENING_STOCK
*&---------------------------------------------------------------------*
FORM f_opening_stock .
  DATA : lt_mseg      TYPE TABLE OF mseg,
         lt_mch1      TYPE TABLE OF mch1,
         lt_mchb      TYPE TABLE OF mchb,
         ls_mchb      LIKE LINE OF lt_mchb,
         ls_mseg      LIKE LINE OF gt_msegopn,
         lt_s933      TYPE TABLE OF s933,
         ls_mchbmch1  LIKE LINE OF gt_mchbmch1.

  DATA : lt_opnstk  TYPE zmmtt_opnstk,
         ls_opnstk  LIKE LINE OF gt_opnstk.

  IF gt_mara[] IS NOT INITIAL.
    SELECT *
      FROM mchb
      INTO TABLE lt_mchb
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr
        AND werks = pa_werks
        AND lgort IN gr_lgort01.

    IF gt_s933[] IS NOT INITIAL.
      lt_s933[] = gt_s933[].
      SORT lt_s933 BY mblnr spmon.
      DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING mblnr spmon.

      IF lt_s933[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
               kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt
               shkzg aufnr
          INTO CORRESPONDING FIELDS OF TABLE gt_msegopn
          FROM mseg
          FOR ALL ENTRIES IN lt_s933
          WHERE mblnr  = lt_s933-mblnr
            AND mjahr  = lt_s933-spmon(4)
            AND werks  = pa_werks
            AND lgort  IN gr_lgort01.
      ENDIF.
    ENDIF.

    SORT lt_mchb BY matnr werks lgort charg.
    SORT gt_msegopn BY matnr werks lgort charg shkzg.

    LOOP AT lt_mchb INTO ls_mchb.
      ls_opnstk-matnr = ls_mchb-matnr.
      ls_opnstk-werks = ls_mchb-werks.
      ls_opnstk-charg = ls_mchb-charg.
      ls_opnstk-labst = ls_mchb-clabs + ls_mchb-cinsm +
                        ls_mchb-ceinm + ls_mchb-cspem +
                        ls_mchb-cretm.
      LOOP AT gt_msegopn INTO ls_mseg
                         WHERE matnr = ls_mchb-matnr
                           AND werks = ls_mchb-werks
                           AND lgort = ls_mchb-lgort
                           AND charg = ls_mchb-charg.
        CASE ls_mseg-shkzg.
          WHEN 'H'.
            ls_mseg-menge = ls_mseg-menge.
          WHEN 'S'.
            ls_mseg-menge = ls_mseg-menge * -1.
        ENDCASE.
        ls_opnstk-labst = ls_opnstk-labst + ls_mseg-menge.
      ENDLOOP.

      IF ls_opnstk-labst IS NOT INITIAL.
        ls_mchbmch1-matnr = ls_opnstk-matnr.
        ls_mchbmch1-charg = ls_opnstk-charg.
        APPEND ls_mchbmch1 TO gt_mchbmch1.
        CLEAR ls_mchbmch1.

        COLLECT ls_opnstk INTO gt_opnstk.
      ENDIF.
      CLEAR ls_opnstk.
    ENDLOOP.
*    DELETE gt_opnstk WHERE labst IS INITIAL.

    lt_opnstk[] = gt_opnstk[].
    SORT lt_opnstk BY matnr charg.
    DELETE ADJACENT DUPLICATES FROM lt_opnstk COMPARING matnr charg.
    IF lt_opnstk[] IS NOT INITIAL.
      SELECT matnr charg lwedt vfdat cuobj_bm lifnr licha hsdat
        FROM mch1
        INTO CORRESPONDING FIELDS OF TABLE gt_mch1
        FOR ALL ENTRIES IN lt_opnstk
        WHERE matnr = lt_opnstk-matnr
          AND charg = lt_opnstk-charg.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_OPENING_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_MODIFY
*&---------------------------------------------------------------------*
FORM f_field_modify  USING    fu_flag fu_matnr fu_value fu_meins fu_waers
                              fu_meins1 fu_shkzg
                     CHANGING fc_value.

  DATA : lv_menge   TYPE mseg-menge,
         lv_verpr   TYPE mbew-salk3.

  CASE fu_flag.
    WHEN 'D'.
      CONCATENATE fu_value(4) fu_value+4(2) fu_value+6(2)
      INTO fc_value
      SEPARATED BY '-'.

    WHEN 'U'.
      IF fu_meins1 IS NOT INITIAL.
        IF fu_meins <> fu_meins1.
          CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
            EXPORTING
              matnr                = fu_matnr
              meinh                = fu_meins1
              meins                = fu_meins
            IMPORTING
              output               = lv_menge
            EXCEPTIONS
              conversion_not_found = 1
              input_invalid        = 2
              material_not_found   = 3
              meinh_not_found      = 4
              meins_missing        = 5
              no_meinh             = 6
              output_invalid       = 7
              overflow             = 8
              OTHERS               = 9.
        ELSE.
          lv_menge  = fu_value.
        ENDIF.
      ELSE.
        lv_menge  = fu_value.
      ENDIF.

      IF fu_shkzg = 'H'.
        lv_menge  = lv_menge * -1.
      ENDIF.

      WRITE lv_menge TO fc_value UNIT fu_meins.
      CONDENSE fc_value NO-GAPS.

    WHEN 'C'.
      lv_verpr  = fu_value / 100.
      WRITE lv_verpr TO fc_value CURRENCY fu_waers.
      CONDENSE fc_value NO-GAPS.
  ENDCASE.
ENDFORM.                    " F_FIELD_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RADIO1
*&---------------------------------------------------------------------*
FORM f_print_radio1 .
  DATA: highest_column  TYPE zexcel_cell_column,
        count           TYPE int4,
        col_alpha       TYPE zexcel_cell_column_alpha,
        row             TYPE zexcel_cell_row.

  DATA : ls_zmmst01     LIKE LINE OF gt_zmmst01.

  CREATE OBJECT lo_excel.

  lo_worksheet = lo_excel->get_active_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Pemasukan').

  lo_style_right = lo_excel->add_new_style( ).
  lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
  lv_style_right_guid = lo_style_right->get_guid( ).

  ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = gt_zmmst01
                            is_table_settings = ls_table_settings ).

  LOOP AT gt_zmmst01 INTO ls_zmmst01.
    row = sy-tabix + 3.
    lo_worksheet->set_cell_style( ip_column = 'H' ip_row = row ip_style = lv_style_right_guid ).

    column_dimension = lo_worksheet->get_column_dimension( ip_column = 'S' ).
    column_dimension->set_visible( ip_visible = abap_false ).
  ENDLOOP.

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).

  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_worksheet = lo_excel->add_new_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Bahan Baku' ).

  lo_worksheet->bind_table( ip_table          = gt_zmmst01a
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).
  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_worksheet = lo_excel->add_new_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Negara' ).

  lo_worksheet->bind_table( ip_table          = gt_zmmst01b
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).
  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_excel->set_active_sheet_index_by_name('Pemasukan').

*** Create output
  lcl_output=>output( lo_excel ).

ENDFORM.                    " F_PRINT_RADIO1

*&---------------------------------------------------------------------*
*&      Form  F_PEMASUKAN_BB
*&---------------------------------------------------------------------*
FORM f_pemasukan_bb .
  DATA : lt_s933     TYPE TABLE OF s933.

  IF gt_s933[] IS NOT INITIAL.
    lt_s933[] = gt_s933[].
    DELETE lt_s933 WHERE budat NOT IN so_budat.

    SORT lt_s933 BY mblnr spmon.
    DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING mblnr spmon.
    IF lt_s933[] IS NOT INITIAL.
      CASE 'X'.
        WHEN radio1.
          SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
                 kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt
                 shkzg aufnr grund umwrk umlgo
            INTO CORRESPONDING FIELDS OF TABLE gt_msegtrn
            FROM mseg
            FOR ALL ENTRIES IN lt_s933
            WHERE mblnr  = lt_s933-mblnr
              AND mjahr  = lt_s933-spmon(4)
              AND werks  =  pa_werks
              AND matnr  IN so_matnr
              AND lgort  IN so_lgort
              AND bwart  IN so_bwart.
        WHEN radio2.
          SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
                 kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt
                 shkzg aufnr grund umwrk umlgo
            INTO CORRESPONDING FIELDS OF TABLE gt_msegtrn
            FROM mseg
            FOR ALL ENTRIES IN lt_s933
            WHERE mblnr  = lt_s933-mblnr
              AND mjahr  = lt_s933-spmon(4)
              AND werks  =  pa_werks
              AND matnr  IN so_matnr
              AND lgort  IN gr_lgort01
              AND bwart  IN gr_bwart03.
      ENDCASE.

      SELECT mblnr mjahr budat
        FROM mkpf
        INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
        FOR ALL ENTRIES IN lt_s933
          WHERE mblnr  = lt_s933-mblnr
            AND mjahr  = lt_s933-spmon(4).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PEMASUKAN_BB

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL
*&---------------------------------------------------------------------*
FORM f_material .
  DATA : ls_mara      LIKE LINE OF gt_mara,
         ls_makt      LIKE LINE OF gt_makt,
         ls_t023t     LIKE LINE OF gt_t023t,
         ls_002       LIKE LINE OF gt_002,
         ls_zmmst01a  LIKE LINE OF gt_zmmst01a,
         ls_zmmst02a  LIKE LINE OF gt_zmmst02a,
         ls_zmmst03a  LIKE LINE OF gt_zmmst03a,
         ls_zmmst04a  LIKE LINE OF gt_zmmst04a.

  CASE 'X'.
    WHEN radio1 OR radio2.
      SELECT mara~matnr matkl meins labor
        FROM mara JOIN marc ON mara~matnr = marc~matnr
        INTO CORRESPONDING FIELDS OF TABLE gt_mara
        WHERE werks = pa_werks
          AND mtart = 'ZRM'.

    WHEN radio3 OR radio4.
      SELECT mara~matnr matkl meins labor
        FROM mara JOIN marc ON mara~matnr = marc~matnr
        INTO CORRESPONDING FIELDS OF TABLE gt_mara
        WHERE werks = pa_werks
          AND ( mtart = 'ZPHA' OR
              mtart = 'ZCGB' ).
  ENDCASE.

  SORT gt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_mara COMPARING matnr.

  IF gt_mara[] IS NOT INITIAL.
    SELECT a~matnr meinh umren msehl
      FROM marm AS a JOIN t006  AS b ON a~meinh = b~msehi
                     JOIN t006d AS c ON b~dimid = c~dimid
                     JOIN t006a AS d ON a~meinh = d~msehi
      INTO CORRESPONDING FIELDS OF TABLE gt_marm
      FOR ALL ENTRIES IN gt_mara
      WHERE a~matnr = gt_mara-matnr
        AND c~mssie = space
        AND d~spras = sy-langu.

    SORT gt_marm BY matnr umren DESCENDING meinh DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_marm COMPARING matnr.

    SELECT matkl wgbez
      FROM t023t
      INTO CORRESPONDING FIELDS OF TABLE gt_t023t
      FOR ALL ENTRIES IN gt_mara
      WHERE spras = sy-langu
        AND matkl = gt_mara-matkl.

    SELECT matnr maktg
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE gt_makt
      FOR ALL ENTRIES IN gt_mara
      WHERE spras = sy-langu
        AND matnr = gt_mara-matnr.
  ENDIF.

  LOOP AT gt_mara INTO ls_mara.
    CLEAR : ls_t023t, ls_makt.
    READ TABLE gt_t023t INTO ls_t023t WITH KEY matkl = ls_mara-matkl.
    READ TABLE gt_makt INTO ls_makt WITH KEY matnr = ls_mara-matnr.
    CASE 'X'.
      WHEN radio1.
        ls_zmmst01a-kode_bahan_baku    = ls_mara-matnr.
        ls_zmmst01a-jenis_bahan_baku   = ls_t023t-wgbez.
        ls_zmmst01a-nama_bahan_baku    = ls_makt-maktg.
        APPEND ls_zmmst01a TO gt_zmmst01a.

      WHEN radio2.
        ls_zmmst02a-kode_bahan_baku    = ls_mara-matnr.
        ls_zmmst02a-jenis_bahan_baku   = ls_t023t-wgbez.
        ls_zmmst02a-nama_bahan_baku    = ls_makt-maktg.
        APPEND ls_zmmst02a TO gt_zmmst02a.

      WHEN radio3.
        ls_zmmst03a-kode_obat_jadi     = ls_mara-matnr.
        ls_zmmst03a-nama_obat_jadi     = ls_makt-maktg.
        CLEAR ls_002.
        READ TABLE gt_002 INTO ls_002 WITH KEY matnr = ls_mara-matnr.
        ls_zmmst03a-nie                = ls_002-nie.
        ls_zmmst03a-kemasan            = ls_002-kemasan.
        ls_zmmst03a-sediaan            = ls_002-btk_sedia.
        ls_zmmst03a-kekuatan           = ls_002-kekuatan_sedia.
        APPEND ls_zmmst03a TO gt_zmmst03a.

      WHEN radio4.
        ls_zmmst04a-kode_obat_jadi     = ls_mara-matnr.
        ls_zmmst04a-nama_obat_jadi     = ls_makt-maktg.
        CLEAR ls_002.
        READ TABLE gt_002 INTO ls_002 WITH KEY matnr = ls_mara-matnr.
        ls_zmmst04a-nie                = ls_002-nie.
        ls_zmmst04a-kemasan            = ls_002-kemasan.
        ls_zmmst04a-sediaan            = ls_002-btk_sedia.
        ls_zmmst04a-kekuatan           = ls_002-kekuatan_sedia.
        APPEND ls_zmmst04a TO gt_zmmst04a.
    ENDCASE.

    IF ls_mara-matnr IN so_matnr.
      CONTINUE.
    ELSE.
      DELETE TABLE gt_mara FROM ls_mara.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_PEMBUAT
*&---------------------------------------------------------------------*
FORM f_pembuat  USING    fu_matnr fu_charg fu_zmf fu_zcountry fu_cuobj_bm
                CHANGING fc_nama fc_kode fc_negara.

  DATA : char_of_batch  TYPE TABLE OF clbatch,
         ls_char        LIKE LINE OF char_of_batch,
         ls_t005t       LIKE LINE OF gt_t005t,
         str01          TYPE string,
         str02          TYPE string.

  CLEAR : fc_nama, fc_kode, fc_negara.

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      get_classification = 'X'
    TABLES
      char_of_batch      = char_of_batch
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  LOOP AT char_of_batch INTO ls_char.
    CASE ls_char-atinn.
      WHEN fu_zmf.
        fc_nama = ls_char-atwtb.
        SPLIT fc_nama AT '@' INTO str01 str02.
        IF sy-subrc = 0.
          fc_nama = str01.
        ENDIF.
      WHEN fu_zcountry.
        SELECT SINGLE atwrt
          FROM ausp
          INTO fc_kode
          WHERE objek = fu_cuobj_bm
            AND atinn = ls_char-atinn.

        CLEAR ls_t005t.
        READ TABLE gt_t005t INTO ls_t005t WITH KEY land1 = fc_kode.
        IF sy-subrc = 0.
          fc_negara = ls_t005t-landx.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_PEMBUAT

*&---------------------------------------------------------------------*
*&      Form  F_PENGGUNAAN_BB
*&---------------------------------------------------------------------*
FORM f_penggunaan_bb .
  DATA : lt_s933    TYPE TABLE OF s933.

  IF gt_s933[] IS NOT INITIAL.
    lt_s933[] = gt_s933[].
    DELETE lt_s933 WHERE budat NOT IN so_budat.

    SORT lt_s933 BY mblnr spmon.
    DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING mblnr spmon.
    IF lt_s933[] IS NOT INITIAL.
      SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
               kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt
               shkzg aufnr grund umwrk umlgo
          APPENDING CORRESPONDING FIELDS OF TABLE gt_msegtrn
          FROM mseg
          FOR ALL ENTRIES IN lt_s933
          WHERE mblnr  = lt_s933-mblnr
            AND mjahr  = lt_s933-spmon(4)
            AND werks  =  pa_werks
            AND matnr  IN so_matnr
            AND lgort  IN gr_lgort02
            AND bwart  IN so_bwart.

      SELECT mblnr mjahr budat
        FROM mkpf
        APPENDING CORRESPONDING FIELDS OF TABLE gt_mkpf
        FOR ALL ENTRIES IN lt_s933
          WHERE mblnr  = lt_s933-mblnr
            AND mjahr  = lt_s933-spmon(4).
    ENDIF.
  ENDIF.
  SORT gt_msegtrn BY mblnr mjahr zeile bwart.
  DELETE ADJACENT DUPLICATES FROM gt_msegtrn COMPARING mblnr mjahr zeile bwart.
ENDFORM.                    " F_PENGGUNAAN_BB

*&---------------------------------------------------------------------*
*&      Form  F_NILAI
*&---------------------------------------------------------------------*
FORM f_nilai .
  DATA : ls_nilai   LIKE LINE OF gt_nilai,
         ls_mbew    LIKE LINE OF gt_mbew,
         ls_mbewh   LIKE LINE OF gt_mbewh.

  IF gt_mara[] IS NOT INITIAL.
    SELECT matnr lfgja lfmon bwkey bwtar verpr stprs peinh
      FROM mbew
      INTO CORRESPONDING FIELDS OF TABLE gt_mbew
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr
        AND bwkey = pa_werks.

    SELECT matnr lfgja lfmon bwkey bwtar verpr stprs peinh
      FROM mbewh
      INTO CORRESPONDING FIELDS OF TABLE gt_mbewh
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr
        AND bwkey = pa_werks.
  ENDIF.

  SORT gt_mbew BY matnr lfgja lfmon.
  SORT gt_mbewh BY matnr lfgja lfmon.
  LOOP AT gt_mbew INTO ls_mbew.
    ls_nilai = ls_mbew.
    COLLECT ls_nilai INTO gt_nilai.
    CLEAR ls_nilai.
  ENDLOOP.
  LOOP AT gt_mbewh INTO ls_mbewh.
    MOVE-CORRESPONDING ls_mbewh TO ls_nilai.
    COLLECT ls_nilai INTO gt_nilai.
    CLEAR ls_nilai.
  ENDLOOP.
ENDFORM.                    " F_NILAI

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RADIO2
*&---------------------------------------------------------------------*
FORM f_print_radio2 .
  DATA: highest_column  TYPE zexcel_cell_column,
        count           TYPE int4,
        col_alpha       TYPE zexcel_cell_column_alpha,
        row             TYPE zexcel_cell_row.

  DATA : ls_zmmst02     LIKE LINE OF gt_zmmst02.

  CREATE OBJECT lo_excel.

  lo_worksheet = lo_excel->get_active_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Penggunaan').

  lo_style_right = lo_excel->add_new_style( ).
  lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
  lv_style_right_guid = lo_style_right->get_guid( ).

  ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = gt_zmmst02
                            is_table_settings = ls_table_settings ).

  LOOP AT gt_zmmst02 INTO ls_zmmst02.
    row = sy-tabix + 3.
    lo_worksheet->set_cell_style( ip_column = 'H' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'L' ip_row = row ip_style = lv_style_right_guid ).

    column_dimension = lo_worksheet->get_column_dimension( ip_column = 'N' ).
    column_dimension->set_visible( ip_visible = abap_false ).
  ENDLOOP.

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).

  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_worksheet = lo_excel->add_new_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Bahan Baku' ).

  lo_worksheet->bind_table( ip_table          = gt_zmmst02a
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).
  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_excel->set_active_sheet_index_by_name('Penggunaan').

*** Create output
  lcl_output=>output( lo_excel ).
ENDFORM.                    " F_PRINT_RADIO2

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RADIO3
*&---------------------------------------------------------------------*
FORM f_print_radio3 .
  DATA: highest_column  TYPE zexcel_cell_column,
        count           TYPE int4,
        col_alpha       TYPE zexcel_cell_column_alpha,
        row             TYPE zexcel_cell_row.

  DATA : ls_zmmst03     LIKE LINE OF gt_zmmst03.

  CREATE OBJECT lo_excel.

  lo_worksheet = lo_excel->get_active_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Produksi').

  lo_style_right = lo_excel->add_new_style( ).
  lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
  lv_style_right_guid = lo_style_right->get_guid( ).

  ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = gt_zmmst03
                            is_table_settings = ls_table_settings ).

  LOOP AT gt_zmmst03 INTO ls_zmmst03.
    row = sy-tabix + 3.
    lo_worksheet->set_cell_style( ip_column = 'H' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'L' ip_row = row ip_style = lv_style_right_guid ).

    column_dimension = lo_worksheet->get_column_dimension( ip_column = 'O' ).
    column_dimension->set_visible( ip_visible = abap_false ).
  ENDLOOP.

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).

  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_worksheet = lo_excel->add_new_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Obat Jadi' ).

  lo_worksheet->bind_table( ip_table          = gt_zmmst03a
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).
  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_excel->set_active_sheet_index_by_name('Produksi').

*** Create output
  lcl_output=>output( lo_excel ).
ENDFORM.                    " F_PRINT_RADIO3

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RADIO4
*&---------------------------------------------------------------------*
FORM f_print_radio4 .
  DATA: highest_column  TYPE zexcel_cell_column,
        count           TYPE int4,
        col_alpha       TYPE zexcel_cell_column_alpha,
        row             TYPE zexcel_cell_row.

  DATA : ls_zmmst04     LIKE LINE OF gt_zmmst04.

  CREATE OBJECT lo_excel.

  lo_worksheet = lo_excel->get_active_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Distribusi').

  lo_style_right = lo_excel->add_new_style( ).
  lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
  lv_style_right_guid = lo_style_right->get_guid( ).

  ls_table_settings-table_style       = zcl_excel_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = gt_zmmst04
                            is_table_settings = ls_table_settings ).

  LOOP AT gt_zmmst04 INTO ls_zmmst04.
    row = sy-tabix + 3.
    lo_worksheet->set_cell_style( ip_column = 'H' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'I' ip_row = row ip_style = lv_style_right_guid ).
    lo_worksheet->set_cell_style( ip_column = 'O' ip_row = row ip_style = lv_style_right_guid ).

    column_dimension = lo_worksheet->get_column_dimension( ip_column = 'Q' ).
    column_dimension->set_visible( ip_visible = abap_false ).
  ENDLOOP.

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).

  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_worksheet = lo_excel->add_new_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Obat Jadi' ).

  lo_worksheet->bind_table( ip_table          = gt_zmmst04a
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).
  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_worksheet = lo_excel->add_new_worksheet( ).
  lo_worksheet->set_title( ip_title = 'Negara' ).

  lo_worksheet->bind_table( ip_table          = gt_zmmst04b
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ).
  highest_column = lo_worksheet->get_highest_column( ).
  count = 1.
  WHILE count <= highest_column.
    col_alpha = zcl_excel_common=>convert_column2alpha( ip_column = count ).
    column_dimension = lo_worksheet->get_column_dimension( ip_column = col_alpha ).
    column_dimension->set_auto_size( ip_auto_size = abap_true ).
    count = count + 1.
  ENDWHILE.

  lo_excel->set_active_sheet_index_by_name('Distribusi').

*** Create output
  lcl_output=>output( lo_excel ).

ENDFORM.                    " F_PRINT_RADIO4

*&---------------------------------------------------------------------*
*&      Form  F_NEGARA
*&---------------------------------------------------------------------*
FORM f_negara .
  DATA : ls_t005t     LIKE LINE OF gt_t005t,
         ls_zmmst01b  LIKE LINE OF gt_zmmst01b,
         ls_zmmst04b  LIKE LINE OF gt_zmmst04b.

  SELECT *
    FROM t005t
    INTO CORRESPONDING FIELDS OF TABLE gt_t005t
    WHERE spras = sy-langu.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_t005t INTO ls_t005t.
        ls_zmmst01b-kode_negara_pembuat = ls_t005t-land1.
        ls_zmmst01b-nama_negara_pembuat = ls_t005t-landx.
        APPEND ls_zmmst01b TO gt_zmmst01b.
      ENDLOOP.
    WHEN radio4.
      LOOP AT gt_t005t INTO ls_t005t.
        ls_zmmst04b-kode_negara_pembuat  = ls_t005t-land1.
        ls_zmmst04b-nama_negara_pembuat  = ls_t005t-landx.
        APPEND ls_zmmst04b TO gt_zmmst04b.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_NEGARA

*&---------------------------------------------------------------------*
*&      Form  F_SELLIST
*&---------------------------------------------------------------------*
FORM f_sellist  TABLES   sellist  STRUCTURE vimsellist
                USING    fu_flag fu_value fieldname append_conjunction.

  DATA : selopt       TYPE STANDARD TABLE OF selopt INITIAL SIZE 0,
         ls_selopt    LIKE LINE OF selopt.

  CASE fu_flag.
    WHEN 'P'.
      ls_selopt-low    = fu_value.
      ls_selopt-sign   = 'I'.
      ls_selopt-option = 'EQ'.
      APPEND ls_selopt TO selopt.
    WHEN 'S'.
      APPEND fu_value TO selopt.
  ENDCASE.

  CALL FUNCTION 'VIEW_RANGETAB_TO_SELLIST'
    EXPORTING
      fieldname          = fieldname
      append_conjunction = append_conjunction
    TABLES
      sellist            = sellist
      rangetab           = selopt.
ENDFORM.                    " F_SELLIST

*&---------------------------------------------------------------------*
*&      Form  F_S933
*&---------------------------------------------------------------------*
FORM f_s933 .
  IF gt_mara[] IS NOT INITIAL.
    SELECT *
      FROM s933
      INTO TABLE gt_s933
      FOR ALL ENTRIES IN gt_mara
      WHERE spmon GE so_budat-low(6)
        AND werks = pa_werks
        AND matnr = gt_mara-matnr
        AND lgort IN so_lgort
        AND vrsio EQ '000'.
  ENDIF.
ENDFORM.                                                    " F_S933

*&---------------------------------------------------------------------*
*&      Form  F_ZTSPMMDT002
*&---------------------------------------------------------------------*
FORM f_ztspmmdt002 .
  SELECT *
    FROM ztspmmdt002
    INTO CORRESPONDING FIELDS OF TABLE gt_002
    WHERE werks = pa_werks.
ENDFORM.                    " F_ZTSPMMDT002

*&---------------------------------------------------------------------*
*&      Form  F_PRODUKSI_OJ
*&---------------------------------------------------------------------*
FORM f_produksi_oj .
  DATA : lt_s933    TYPE TABLE OF s933,
         lt_mseg    TYPE TABLE OF mseg.

  IF gt_s933[] IS NOT INITIAL.
    lt_s933[] = gt_s933[].
    DELETE lt_s933 WHERE budat NOT IN so_budat.

    SORT lt_s933 BY mblnr spmon.
    DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING mblnr spmon.
    IF lt_s933[] IS NOT INITIAL.
      SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
             kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt
             shkzg aufnr grund umwrk umlgo
        INTO CORRESPONDING FIELDS OF TABLE gt_msegtrn
        FROM mseg
        FOR ALL ENTRIES IN lt_s933
        WHERE mblnr  = lt_s933-mblnr
          AND mjahr  = lt_s933-spmon(4)
          AND werks  = pa_werks
          AND matnr  IN so_matnr
          AND lgort  IN gr_lgort02
          AND bwart  IN so_bwart.

      SELECT mblnr mjahr budat
        FROM mkpf
        INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
        FOR ALL ENTRIES IN lt_s933
          WHERE mblnr  = lt_s933-mblnr
            AND mjahr  = lt_s933-spmon(4).
    ENDIF.

    gt_msegsum[]  = gt_msegtrn[].
    SORT gt_msegsum BY matnr charg mblnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_msegsum COMPARING matnr charg.
    IF gt_msegsum[] IS NOT INITIAL.
      SELECT matnr charg lwedt vfdat cuobj_bm lifnr licha hsdat
        FROM mch1
        APPENDING CORRESPONDING FIELDS OF TABLE gt_mch1
        FOR ALL ENTRIES IN gt_msegsum
        WHERE matnr = gt_msegsum-matnr
          AND charg = gt_msegsum-charg.
    ENDIF.

    lt_mseg[] = gt_msegtrn[].
    SORT lt_mseg BY bwart grund.
    DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING bwart grund.
    IF lt_mseg[] IS NOT INITIAL.
      SELECT bwart grund grtxt
        FROM t157e
        INTO CORRESPONDING FIELDS OF TABLE gt_t157e
        FOR ALL ENTRIES IN lt_mseg
        WHERE spras = sy-langu
          AND bwart = lt_mseg-bwart
          AND grund = lt_mseg-grund.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_PRODUKSI_OJ

*&---------------------------------------------------------------------*
*&      Form  F_DISTRIBUSI_OJ
*&---------------------------------------------------------------------*
FORM f_distribusi_oj .
  DATA : lt_s933    TYPE TABLE OF s933,
         lt_mseg    TYPE TABLE OF mseg.

  IF gt_s933[] IS NOT INITIAL.
    lt_s933[] = gt_s933[].
    DELETE lt_s933 WHERE budat NOT IN so_budat.

    SORT lt_s933 BY mblnr spmon.
    DELETE ADJACENT DUPLICATES FROM lt_s933 COMPARING mblnr spmon.
    IF lt_s933[] IS NOT INITIAL.
      SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg lifnr
             kunnr menge meins ebeln ebelp sjahr smbln smblp elikz sgtxt
             shkzg aufnr grund umwrk umlgo
        INTO CORRESPONDING FIELDS OF TABLE gt_msegtrn
        FROM mseg
        FOR ALL ENTRIES IN lt_s933
        WHERE mblnr  = lt_s933-mblnr
          AND mjahr  = lt_s933-spmon(4)
          AND werks  =  pa_werks
          AND matnr  IN so_matnr
          AND lgort  IN so_lgort
          AND bwart  IN so_bwart.

      SELECT mblnr mjahr budat
        FROM mkpf
        INTO CORRESPONDING FIELDS OF TABLE gt_mkpf
        FOR ALL ENTRIES IN lt_s933
          WHERE mblnr  = lt_s933-mblnr
            AND mjahr  = lt_s933-spmon(4).
    ENDIF.

    gt_msegsum[]  = gt_msegtrn[].
    SORT gt_msegsum BY matnr charg mblnr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_msegsum COMPARING matnr charg.
    IF gt_msegsum[] IS NOT INITIAL.
      SELECT matnr charg lwedt vfdat cuobj_bm lifnr licha hsdat
        FROM mch1
        INTO CORRESPONDING FIELDS OF TABLE gt_mch1
        FOR ALL ENTRIES IN gt_msegsum
        WHERE matnr = gt_msegsum-matnr
          AND charg = gt_msegsum-charg.
    ENDIF.

    lt_mseg[]   = gt_msegtrn[].
    SORT lt_mseg BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING kunnr.
    IF lt_mseg[] IS NOT INITIAL.
      SELECT kunnr name1 land1
        FROM kna1
        INTO CORRESPONDING FIELDS OF TABLE gt_kna1
        FOR ALL ENTRIES IN lt_mseg
        WHERE kunnr = lt_mseg-kunnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DISTRIBUSI_OJ

*&---------------------------------------------------------------------*
*&      Form  F_SELOPT
*&---------------------------------------------------------------------*
FORM f_selopt  USING    fu_lgort fu_bwart.
  DATA : lv_str01     TYPE string,
         lv_str02     TYPE string,
         lv_lgort     TYPE mseg-lgort,
         lv_bwart     TYPE mseg-bwart.

  IF fu_lgort IS NOT INITIAL.
    lv_lgort  = fu_lgort.
    SPLIT lv_lgort AT '*' INTO lv_str01 lv_str02.
    IF sy-subrc = 0.
      IF lv_lgort = lv_str01.
        so_lgort-option  = 'EQ'.
      ELSE.
        so_lgort-option  = 'CP'.
      ENDIF.
    ENDIF.
    so_lgort-sign    = 'I'.
    so_lgort-low     = lv_lgort.
    APPEND so_lgort.
  ENDIF.

  IF fu_bwart IS NOT INITIAL.
    lv_bwart  = fu_bwart.
    SPLIT lv_bwart AT '*' INTO lv_str01 lv_str02.
    IF sy-subrc = 0.
      IF lv_bwart = lv_str01.
        so_bwart-option  = 'EQ'.
      ELSE.
        so_bwart-option  = 'CP'.
      ENDIF.
    ENDIF.
    so_bwart-sign    = 'I'.
    so_bwart-low     = lv_bwart.
    APPEND so_bwart.
  ENDIF.
ENDFORM.                    " F_SELOPT

*&---------------------------------------------------------------------*
*&      Form  F_NILAI_EKSPOR
*&---------------------------------------------------------------------*
FORM f_nilai_ekspor .
  TYPES : BEGIN OF ty_vbfa,
            vbeln   TYPE vbfa-vbeln,
            posnn   TYPE vbfa-posnn,
          END OF ty_vbfa.

  DATA : lt_mseg  TYPE TABLE OF mseg,
         ls_mseg  LIKE LINE OF gt_msegtrn,
         lt_key   TYPE TABLE OF ty_vbfa,
         ls_key   LIKE LINE OF lt_key.

  lt_mseg[] = gt_msegtrn[].
  SORT lt_mseg[] BY mblnr zeile.
  LOOP AT lt_mseg INTO ls_mseg.
    ls_key-vbeln    = ls_mseg-mblnr.
    ls_key-posnn    = ls_mseg-zeile.
    COLLECT ls_key INTO lt_key.
    CLEAR ls_key.
  ENDLOOP.

  IF lt_key[] IS NOT INITIAL.
    SELECT *
      FROM vbfa
      INTO CORRESPONDING FIELDS OF TABLE gt_vbfa
      FOR ALL ENTRIES IN lt_key
      WHERE vbeln   = lt_key-vbeln
        AND posnn   = lt_key-posnn
        AND vbtyp_n = 'R'.

    IF gt_vbfa[] IS NOT INITIAL.
      SELECT *
        FROM vbap
        INTO CORRESPONDING FIELDS OF TABLE gt_vbap
        FOR ALL ENTRIES IN gt_vbfa
        WHERE vbeln = gt_vbfa-vbelv
          AND posnr = gt_vbfa-posnv.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NILAI_EKSPOR

*&---------------------------------------------------------------------*
*&      Form  F_NILAI_RUPIAH
*&---------------------------------------------------------------------*
FORM f_nilai_rupiah .
  DATA : lv_lifnr       TYPE lfa1-lifnr,
         lr_lifnr       TYPE RANGE OF lifnr,
         ls_lifnr       LIKE LINE OF lr_lifnr.

  IF gt_mara[] IS NOT INITIAL.
    SELECT *
      FROM a005
      INTO CORRESPONDING FIELDS OF TABLE gt_price
      FOR ALL ENTRIES IN gt_mara
      WHERE kappl = 'V'
        AND kschl = 'ZHJP'
        AND vkorg = pa_bukrs
        AND vtweg = '10'
        AND kunnr IN ('TSB8020', 'TSB8180')
        AND matnr = gt_mara-matnr
        AND datbi GE so_budat-low
        AND datab LE so_budat-high.
    IF sy-subrc = 0.
      IF gt_price[] IS NOT INITIAL.
        SELECT *
          FROM konp
          INTO CORRESPONDING FIELDS OF TABLE gt_konp
          FOR ALL ENTRIES IN gt_price
          WHERE knumh EQ gt_price-knumh.
      ENDIF.
    ENDIF.

    CONCATENATE 'TSB' pa_werks INTO lv_lifnr.
    ls_lifnr-low    = lv_lifnr.
    ls_lifnr-sign   = 'I'.
    ls_lifnr-option = 'EQ'.
    APPEND ls_lifnr TO lr_lifnr.
    CLEAR ls_lifnr.
    CONCATENATE 'TSB' pa_bukrs INTO lv_lifnr.
    ls_lifnr-low    = lv_lifnr.
    ls_lifnr-sign   = 'I'.
    ls_lifnr-option = 'EQ'.
    APPEND ls_lifnr TO lr_lifnr.
    CLEAR ls_lifnr.

    SELECT *
      FROM a017
      APPENDING CORRESPONDING FIELDS OF TABLE gt_price
      FOR ALL ENTRIES IN gt_mara
      WHERE kappl = 'M'
        AND kschl IN ('ZHIF', 'ZTRP', 'ZHJP')
        AND lifnr IN lr_lifnr
        AND matnr = gt_mara-matnr
        AND ekorg IN ('FAC', 'RXF', 'BCL')
        AND esokz = '0'
        AND datbi GE so_budat-low
        AND datab LE so_budat-high.
    IF sy-subrc = 0.
      IF gt_price[] IS NOT INITIAL.
        SELECT *
          FROM konp
          APPENDING CORRESPONDING FIELDS OF TABLE gt_konp
          FOR ALL ENTRIES IN gt_price
          WHERE knumh EQ gt_price-knumh.
      ENDIF.
    ENDIF.
    SORT gt_konp[] BY knumh kopos.
    DELETE ADJACENT DUPLICATES FROM gt_konp COMPARING ALL FIELDS.
  ENDIF.
ENDFORM.                    " F_NILAI_RUPIAH

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_DATA
*&---------------------------------------------------------------------*
FORM f_split_data .
  DATA : ls_mseg  LIKE LINE OF gt_msegtrn.

  LOOP AT gt_msegtrn INTO ls_mseg.
    IF ls_mseg-bwart IN gr_bwart01.
      APPEND ls_mseg TO gt_m01.
    ENDIF.
    IF ls_mseg-bwart IN gr_bwart02.
      APPEND ls_mseg TO gt_m02.
    ENDIF.
    IF ls_mseg-bwart IN gr_bwart03.
      APPEND ls_mseg TO gt_m03.
    ENDIF.
    CLEAR ls_mseg.
  ENDLOOP.
ENDFORM.                    " F_SPLIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GABUNGAN_MCHB_MCH1
*&---------------------------------------------------------------------*
FORM f_gabungan_mchb_mch1 .
  DATA : lt_mchbmch1    TYPE TABLE OF ty_mchbmch1,
         lt_mchbmch2    TYPE TABLE OF ty_mchbmch1,
         ls_mch1        LIKE LINE OF gt_mch1,
         ls_mchbmch1    LIKE LINE OF gt_mchbmch1,
         lt_lfa1        TYPE STANDARD TABLE OF ty_lfa1,
         ls_lfa1        LIKE LINE OF gt_lfa1,
         lt_lfa11       TYPE STANDARD TABLE OF lfa1,
         ls_lfa11       LIKE LINE OF lt_lfa11.

  DATA : lr_werks       TYPE RANGE OF werks_d,
         ls_werks       LIKE LINE OF lr_werks.

  DATA : lv_datum       TYPE sy-datum.

  LOOP AT gt_mch1 INTO ls_mch1.
    ls_mchbmch1-matnr = ls_mch1-matnr.
    ls_mchbmch1-charg = ls_mch1-charg.
    APPEND ls_mchbmch1 TO gt_mchbmch1.
    CLEAR ls_mchbmch1.
  ENDLOOP.

  SORT gt_mchbmch1 BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM gt_mchbmch1 COMPARING matnr charg.
  LOOP AT gt_mchbmch1 INTO ls_mchbmch1.
    CONCATENATE sy-datum(6) '01' INTO lv_datum.
    DO 36 TIMES.
      ls_mchbmch1-spmon = lv_datum(6).
      APPEND ls_mchbmch1 TO lt_mchbmch1.
      lv_datum  = lv_datum - 1.
      CONCATENATE lv_datum(6) '01' INTO lv_datum.
    ENDDO.
    CLEAR ls_mchbmch1.
  ENDLOOP.

  SORT lt_mchbmch1 BY spmon matnr charg.

  IF lt_mchbmch1[] IS NOT INITIAL.
*    SELECT bwart matnr werks charg lgort lifnr ebeln budat
    SELECT spmon werks matnr bwart charg mblnr budat lgort vrsio
      sptag spwoc spbup ssour ebeln lifnr
    FROM s933
    INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
    FOR ALL ENTRIES IN lt_mchbmch1
    WHERE spmon = lt_mchbmch1-spmon
      AND werks = pa_werks
      AND matnr = lt_mchbmch1-matnr
      AND bwart = '101'
*        AND lgort BETWEEN '1000' AND '9999'
      AND charg = lt_mchbmch1-charg.
*        AND lifnr <> space.

    SORT lt_lfa1 BY werks spmon matnr charg lgort budat DESCENDING.

    LOOP AT lt_lfa1 INTO ls_lfa1.
      IF ls_lfa1-lgort IN gr_lgort00.
        IF ls_lfa1-lifnr <> space.
          APPEND ls_lfa1 TO gt_lfa1.
        ENDIF.
      ENDIF.
      CLEAR ls_lfa1.
    ENDLOOP.

*    SELECT bwart matnr werks charg lifnr ebeln budat
*      FROM s933
*      INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
*      FOR ALL ENTRIES IN gt_mchbmch1
*      WHERE matnr = gt_mchbmch1-matnr
*        AND werks = pa_werks
*        AND lgort BETWEEN '1000' AND '9999'
*        AND bwart = '101'
*        AND charg = gt_mchbmch1-charg
*        AND lifnr <> space.

    CLEAR lt_lfa1[].
    lt_lfa1[] = gt_lfa1[].
    SORT lt_lfa1 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.
    IF lt_lfa1[] IS NOT INITIAL.
      SELECT lifnr name1 werks
        FROM lfa1
        INTO CORRESPONDING FIELDS OF TABLE lt_lfa11
        FOR ALL ENTRIES IN lt_lfa1
        WHERE lifnr = lt_lfa1-lifnr.
    ENDIF.

    LOOP AT gt_lfa1 INTO ls_lfa1.
      CLEAR ls_lfa11.
      READ TABLE lt_lfa11 INTO ls_lfa11
                          WITH KEY lifnr = ls_lfa1-lifnr.
      IF sy-subrc = 0.
        ls_lfa1-name1     = ls_lfa11-name1.
        ls_lfa1-werkslfa1 = ls_lfa11-werks.
        MODIFY gt_lfa1 FROM ls_lfa1 TRANSPORTING name1 werkslfa1.

        IF ls_lfa11-werks IS NOT INITIAL .
          IF ls_lfa11-werks <> pa_werks.
            ls_werks-low    = ls_lfa11-werks.
            ls_werks-sign   = 'I'.
            ls_werks-option = 'EQ'.
            APPEND ls_werks TO lr_werks.
            CLEAR ls_werks.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR ls_lfa1.
    ENDLOOP.

    SORT lr_werks BY low.
    DELETE ADJACENT DUPLICATES FROM lr_werks COMPARING low.
    LOOP AT lr_werks INTO ls_werks.
      LOOP AT lt_mchbmch1 INTO ls_mchbmch1.
        ls_mchbmch1-werks = ls_werks-low.
        APPEND ls_mchbmch1 TO lt_mchbmch2.
        CLEAR ls_mchbmch1.
      ENDLOOP.
    ENDLOOP.

    CLEAR lt_lfa1[].
    IF lt_mchbmch2[] IS NOT INITIAL.
*      SELECT bwart matnr s933~werks charg s933~lifnr ebeln budat name1
      SELECT s933~spmon s933~werks s933~matnr s933~bwart s933~charg s933~mblnr
        s933~budat s933~lgort s933~vrsio s933~sptag s933~spwoc s933~spbup s933~ssour
        s933~ebeln s933~lifnr lfa1~name1
        FROM s933 JOIN lfa1 ON s933~lifnr = lfa1~lifnr
        INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
        FOR ALL ENTRIES IN lt_mchbmch2
        WHERE s933~spmon = lt_mchbmch2-spmon
          AND s933~werks = lt_mchbmch2-werks
          AND s933~matnr = lt_mchbmch2-matnr
          AND s933~bwart = '101'
*          AND lgort BETWEEN '1000' AND '9999'
          AND s933~charg = lt_mchbmch2-charg.
*          AND s933~lifnr <> space.

      SORT lt_lfa1 BY werks spmon matnr charg lgort budat DESCENDING.

      LOOP AT lt_lfa1 INTO ls_lfa1.
        IF ls_lfa1-lgort IN gr_lgort00.
          IF ls_lfa1-lifnr <> space.
            APPEND ls_lfa1 TO gt_lfa1.
          ENDIF.
        ENDIF.
        CLEAR ls_lfa1.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GABUNGAN_MCHB_MCH1

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_MEASUREMENT
*&---------------------------------------------------------------------*
FORM f_conversion_measurement  USING    fu_meins
                               CHANGING fc_satuan.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_satuan
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_MEASUREMENT

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_MSEG
*&---------------------------------------------------------------------*
FORM f_summary_mseg .
  DATA : lt_mseg     TYPE TABLE OF mseg,
         ls_mseg     LIKE LINE OF lt_mseg,
         ls_msegtrn  LIKE LINE OF lt_mseg.

  gt_msegsum[]  = gt_msegtrn[].
  SORT gt_msegsum BY matnr charg mblnr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM gt_msegsum COMPARING matnr charg.
  IF gt_msegsum[] IS NOT INITIAL.
    SELECT matnr charg lwedt vfdat cuobj_bm lifnr licha hsdat
      FROM mch1
      APPENDING CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN gt_msegsum
      WHERE matnr = gt_msegsum-matnr
        AND charg = gt_msegsum-charg.
  ENDIF.

  lt_mseg[] = gt_msegtrn[].
  SORT lt_mseg BY bwart grund.
  DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING bwart grund.
  IF lt_mseg[] IS NOT INITIAL.
    SELECT bwart grund grtxt
      FROM t157e
      INTO CORRESPONDING FIELDS OF TABLE gt_t157e
      FOR ALL ENTRIES IN lt_mseg
      WHERE spras = sy-langu
        AND bwart = lt_mseg-bwart
        AND grund = lt_mseg-grund.
  ENDIF.
ENDFORM.                    " F_SUMMARY_MSEG

*&---------------------------------------------------------------------*
*&      Form  F_PRICE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_price_calculate  USING    fu_matnr fu_datum fu_labst
                        CHANGING fc_nilai.

  DATA : ls_price   LIKE LINE OF gt_price,
         ls_konp    LIKE LINE OF gt_konp,
         lv_kbetr   TYPE wertv9,
         lv_kbetr1  TYPE wertv9.

  CLEAR : ls_price, ls_konp, lv_kbetr.
  LOOP AT gt_price INTO ls_price WHERE matnr = fu_matnr
                                   AND datbi GE fu_datum
                                   AND datab LE fu_datum.
    LOOP AT gt_konp INTO ls_konp WHERE knumh = ls_price-knumh.
      lv_kbetr1  = ls_konp-kbetr / ls_konp-kpein.
      ADD lv_kbetr1 TO lv_kbetr.
    ENDLOOP.
    EXIT.
  ENDLOOP.

  lv_kbetr = lv_kbetr * fu_labst.
  WRITE lv_kbetr TO fc_nilai CURRENCY 'IDR'.
ENDFORM.                    " F_PRICE_CALCULATE
