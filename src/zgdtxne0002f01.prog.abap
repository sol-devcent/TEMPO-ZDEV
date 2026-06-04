*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE00002F01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_ITEM_CATEGORY
*&---------------------------------------------------------------------*
*&  This routine calls a selection screen to select item category
*&  to be processed. This condition is only applicable for Service
*&  billing since it could be separated into to 2 types of item
*&  category, Service & Spare parts
*&---------------------------------------------------------------------*
FORM f_select_item_category.
  IF sy-ucomm = 'ONLI'.
    d_dynnr = '2000'.
    CALL SELECTION-SCREEN 2000 STARTING AT 10 10 ENDING AT 80 12.
    CLEAR d_dynnr.
  ENDIF.
ENDFORM.                    " F_SELECT_ITEM_CATEGORY

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_PRINT_PREV
*&---------------------------------------------------------------------*
*&  This routine is performed to preview, save & print faktur pajak
*&---------------------------------------------------------------------*
*&  ->FU_SAVE   - Set to 'X' for Saving process
*&  ->FU_PRINT  - Set to 'X' for Printing process
*&  ->FU_PREV   - Set to 'X' for Preview process
*&---------------------------------------------------------------------*
FORM f_save_print_prev USING fu_save
                             fu_print
                             fu_prev.

  DATA ld_subrc LIKE sy-subrc.
  DATA ld_fakturno LIKE zgdtxdt0003-fakturno.
  DATA ld_flagerr.

****added by Rahmadi
*---Invoice consolidation option
  d_flag = p_flag.
****end of addition

**If executed from RPC program, all records are considered selected
  IF d_rpc IS INITIAL.
    PERFORM f_selected_data CHANGING ld_subrc.
  ELSE.
    t_vbrkscr1[] = t_vbrkscr[].
    ld_subrc = 0.
  ENDIF.
  CHECK ld_subrc = 0.
  CLEAR ld_flagerr.

  SELECT *
    FROM zfvatnr_dtl
    INTO CORRESPONDING FIELDS OF TABLE gt_zfvatnr_dtl
    WHERE vkorg EQ p_brnch.

  LOOP AT t_vbrkscr1.
    PERFORM f_check_vat_date USING t_vbrkscr1-masatx(4) t_vbrkscr1-fakdat
                                   t_vbrkscr1-vbeln.
  ENDLOOP.

  IF d_tcode = c_tcode_satuan OR         "SATUAN
     d_tcode = c_tcode_sederhana OR
     d_tcode = c_tcode_sederhana_single.

    IF d_tcode = c_tcode_sederhana.
      PERFORM f_check_processing_date USING p_masatx.
    ENDIF.

****Prepare data to save

    CLEAR: t_zgdtxdt0002, t_zgdtxdt0002[],
           t_zgdtxdt0003, t_zgdtxdt0003[].
    PERFORM f_prepare_satuan_table TABLES t_vbrkscr1
                                          t_zgdtxdt0002
                                          t_zgdtxdt0003
                                   USING  d_prev_first
                                          p_rpc
****added by Rahmadi
*---Invoice consolidation option
                                          d_flag.
****end of addition
  ENDIF.


**Save to tables
  IF fu_save = 'X'.

**Determine Printing sequence
    IF fu_print = 'X'.
      d_printx = 'X'.
    ELSE.
      CLEAR d_printx.
    ENDIF.

    PERFORM f_commit_save.
  ENDIF.

**Prepare data to display
  PERFORM f_prepare_satuan_form TABLES  t_zgdtxdt0002
                                        t_zgdtxdt0003
                                USING   p_flag
                                        p_cust. "added for Tempo

**Printing faktur
  IF fu_print = 'X'.
    PERFORM f_call_function USING ' '
                                  ' '
                                  ' '
                                  p_mpage
                                  p_dest
                                  space
                                  p_cust
                         CHANGING d_subrcp.
  ELSEIF fu_prev = 'X'.
****Print preview
    PERFORM f_satuan_screen_preview USING ''.
    CLEAR d_dynnr.
    LEAVE SCREEN.
  ENDIF.

  IF fu_save = 'X'.
    PERFORM f_clear_data USING '01'.
    PERFORM f_unlock_all_billing.
  ENDIF.

  IF ld_flagerr IS INITIAL.
    IF fu_save = 'X' AND
       fu_print = ''.
      MESSAGE s000(ztx) WITH 'Data has been saved'.
      LEAVE TO SCREEN 0.
    ELSEIF fu_save = 'X' AND
           fu_print = 'X'.
      MESSAGE s000(ztx) WITH 'Data has been printed & saved'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ELSE.
    MESSAGE e000(ztx) WITH 'Error in getting Faktur Pajak no'.
  ENDIF.

ENDFORM.                    " F_SAVE_PRINT_PREV

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*&  This routine is specifically called by USER COMMAND module defined
*&  for any screen in the program
*&---------------------------------------------------------------------*
FORM f_user_command.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      PERFORM f_save_print_prev USING 'X' ''  ''.
    WHEN 'SAVP'.
      PERFORM f_save_print_prev USING 'X' 'X' ''.
    WHEN 'PREV'.
      PERFORM f_save_print_prev USING ''  ''  'X'.
    WHEN 'LOG'.
      CALL SCREEN 1400 STARTING AT 10 10 ENDING AT 130 22.
      LEAVE SCREEN.
    WHEN 'SALL'.
      PERFORM f_select_deselect USING  'X'.
    WHEN 'DALL'.
      PERFORM f_select_deselect USING ' '.
    WHEN 'ATAX'.
      PERFORM f_include_exclude_tax USING  'X'.
    WHEN 'DTAX'.
      PERFORM f_include_exclude_tax USING  ' '.
    WHEN 'P--'.
      PERFORM f_paging USING 'P--'.
    WHEN 'P-'.
      PERFORM f_paging USING 'P-'.
    WHEN 'P+'.
      PERFORM f_paging USING 'P+'.
    WHEN 'P++'.
      PERFORM f_paging USING 'P++'.
  ENDCASE.

ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SATUAN_TABLE
*&---------------------------------------------------------------------*
*&  This routine converts selected data in the screen to the main table
*&  formats (ZGDTXdt0002 & ZGDTXdt0003) for saving, printing and
*&  preview purposes. Particularly in satuan process, a tax form (fak-
*&  tur pajak) can only contain maximum 10 line items or 4 tariff
*&  variants, otherwise it has to be automatically splitted into more
*&  than one tax forms.
*&  New tax form number will only be generated later during saving
*&  process, therefore a dummy number must be generated in this routine
*&  to distinguish between tax forms for previewing purpose.
*&  If this routine is performed by RPC program, FU_RPC must be set to
*&  'X' causing the program to use existing tax form numbers.
*&---------------------------------------------------------------------*
*&  ->FT_VBRKSCR   - Selected billings in the screen
*&  ->FU_ACTION    - For numbering purpose, Preview or Save
*&  ->FU_RPC       - Set to 'X' if executed by RPC program
*&  <-FT_TX00002   - Billing data in ZGDTXdt0002 format
*&  <-FT_TX00003   - Faktur pajak data in ZGDTXdt0003 format
*&---------------------------------------------------------------------*
* Requires cleanup Rama
FORM f_prepare_satuan_table TABLES ft_vbrkscr STRUCTURE t_vbrkscr
                                   ft_tx00002 STRUCTURE t_zgdtxdt0002
                                   ft_tx00003 STRUCTURE t_zgdtxdt0003
                            USING  fu_action
                                   fu_rpc
                                   fu_flag.

  DATA ld_fakturno   LIKE zgdtxdt0002-fakturno.
  DATA ld_count      TYPE i.
  DATA lw_vbrk       LIKE t_vbrk.
  DATA lw_vbrkf      LIKE t_vbrk.
  DATA lw_vbrkc      LIKE t_vbrk.
  DATA ld_split.
  DATA ld_split_item.
  DATA ld_subrc      LIKE sy-subrc.
  DATA ld_tabix      LIKE sy-tabix.
  DATA ld_tabixc     LIKE sy-tabix.
  DATA ld_fakppn     LIKE zgdtxdt0003-fakppn.
  DATA ld_fakxppnbm  LIKE zgdtxdt0003-fakxppnbm.
  DATA ld_fakppnbm   LIKE zgdtxdt0003-fakppnbm.
  DATA ld_fakdpp LIKE zgdtxdt0003-fakdpp.
  DATA ld_fakpph22 LIKE zgdtxdt0003-fakpph22.
  DATA ld_fakpph23 LIKE zgdtxdt0003-fakpph23.

  DATA ld_fakppn_f     LIKE zgdtxdt0003-fakppn_f.
  DATA ld_fakxppnbm_f  LIKE zgdtxdt0003-fakxppnbm_f.
  DATA ld_fakppnbm_f   LIKE zgdtxdt0003-fakppnbm_f.
  DATA ld_fakdpp2      LIKE zgdtxdt0003-fakdpp.
  DATA ld_fakppn2      LIKE zgdtxdt0003-fakdpp.

* Command for TKM
*  DATA ld_fakdp        LIKE zgdtxdt0003-fakdp.

  DATA ld_tariff        LIKE zgdtxdt0002-tarifxpbm.
  DATA ld_tarifcount    TYPE i.
  DATA lv_nocoretax     TYPE zgdtxdt0003-nocoretax.

  DATA ld_vbeln      LIKE t_vbrk-vbeln.
  CLEAR: ld_vbeln.

  CLEAR: ld_fakturno, ld_count, ld_tariff, ld_tarifcount, ld_split_item.
  LOOP AT t_vbrk.
    IF p_top = 'X'.
      t_vbrk-fakdat = t_vbrk-top.
    ENDIF.

    MOVE-CORRESPONDING t_vbrk TO lw_vbrk.
    CLEAR ld_split.
    READ TABLE ft_vbrkscr WITH KEY vbeln = lw_vbrk-vbeln
                          BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR lw_vbrk.
      CONTINUE.
    ELSE.
****added for Tempo -- update FAKDAT from screen
      IF fu_rpc IS INITIAL.
        IF ft_vbrkscr-fakdat <> '00000000'.
          lw_vbrk-fakdat = ft_vbrkscr-fakdat.
          lw_vbrk-masatx = ft_vbrkscr-masatx.
        ENDIF.
      ENDIF.
****end of Tempo addition
      AT NEW vbeln.
        IF NOT ( d_tcode = c_tcode_sederhana OR
                d_tcode = c_tcode_sederhana_single ).

          IF fu_rpc IS INITIAL.
*****added for Tempo -- update FAKDAT from screen
*            IF ft_vbrkscr-fakdat <> '00000000'.
*              lw_vbrk-fakdat = ft_vbrkscr-fakdat.
*            ENDIF.
*****end of Tempo addition
            PERFORM f_numbering USING fu_action
                                      ld_fakturno
*                                      d_nr_gsber
                                      ft_vbrkscr-gsber
                                      d_nr_brnch
                                      d_nr_brnch
                                      ft_vbrkscr-masatx
                                      space
                                      ft_vbrkscr-fkdat
                                      ft_vbrkscr-vbeln
                                CHANGING ld_fakturno lv_nocoretax
                                         ld_subrc.
          ELSE.   "RPC
            PERFORM f_get_rpc_faktur_no USING    lw_vbrk-vbeln
                                                 lw_vbrk-posnr
                                                 lw_vbrk-spart
                                                 fu_flag
                                                 c_faktur_type_satuan
                                                 ' '
                                        CHANGING ld_fakturno
                                                 ld_subrc.
          ENDIF.
        ENDIF.
      ENDAT.

      IF lw_vbrk-itamtlast <> 0.     "not included if fully returned
        ld_count = ld_count + 1.
      ENDIF.


*** Commented out by Rahmadi -- generalization
*******Line count is only applicable for KTB FINISHED UNIT
*      IF NOT ( lw_vbrk-vkorg = c_vkorg_ktb AND
*               lw_vbrk-spart = d_fin_unit ).
*      IF p_mpage IS INITIAL.
*        CLEAR ld_count.
*      ENDIF.
*** End of comment

******If displayed item > 10 lines or
******tariff variation > 4, get new faktur no.
      IF ( ld_count > 10 OR ld_tarifcount > 4 )
****added by Rahmadi -- only for single page
         AND p_mpage IS INITIAL.
****end of addition
*         not p_mpage is initial.
********Prepare data for ZGDTXdt0003
        IF NOT ( d_tcode = c_tcode_sederhana OR
                d_tcode = c_tcode_sederhana_single ).

          MOVE-CORRESPONDING lw_vbrk TO ft_tx00003.
          ft_tx00003-fakturno   = ld_fakturno.
          ft_tx00003-batal      = ''.
          ft_tx00003-returcount = '000'.
          ft_tx00003-fakppn     = ld_fakppn.
          ft_tx00003-fakxppnbm  = ld_fakxppnbm.
          ft_tx00003-fakppnbm   = ld_fakppnbm.

****added by Rahmadi
*---Store DPP total, PPH 22, PPH 23
          ft_tx00003-fakpph22 = ld_fakpph22.
          ft_tx00003-fakpph23 = ld_fakpph23.
          ft_tx00003-fakdpp = ld_fakdpp.
****end of addition
**** Comment: Rahmadi -- may need to add logic for forex

*' Foreign Currency
          ft_tx00003-fakppn_f     = ld_fakppn_f.
          ft_tx00003-fakxppnbm_f  = ld_fakxppnbm_f.
          ft_tx00003-fakppnbm_f   = ld_fakppnbm_f.
*'
**** End of comment

          ft_tx00003-npwp       = lw_vbrk-stceg.
          ft_tx00003-userid     = sy-uname.
          ft_tx00003-faktur_type = c_faktur_type_split_item.
          APPEND ft_tx00003.
          CLEAR: ld_count, ld_fakppn, ld_fakxppnbm, ld_fakppnbm,
                 ld_fakdpp, ld_fakpph22, ld_fakpph23.

          IF fu_rpc IS INITIAL.
            PERFORM f_numbering USING fu_action
                                      ld_fakturno
*                                      d_nr_gsber
                                      ft_vbrkscr-gsber
                                      d_nr_brnch
                                      d_nr_brnch
                                      ft_vbrkscr-masatx
                                      space
                                      ft_vbrkscr-fkdat
                                      ft_vbrkscr-vbeln
                                CHANGING ld_fakturno lv_nocoretax
                                         ld_subrc.
          ELSE.   "RPC
            PERFORM f_get_rpc_faktur_no USING    lw_vbrk-vbeln
                                                 lw_vbrk-posnr
                                                 lw_vbrk-spart
                                                 fu_flag
                                                 c_faktur_type_satuan
                                                 ' '
                                        CHANGING ld_fakturno
                                                 ld_subrc.
          ENDIF.
        ENDIF.

        ld_split = 'X'.
        ld_split_item = 'X'.
      ENDIF.

******Prepare saving NORMAL BILLING
      MOVE-CORRESPONDING lw_vbrk TO ft_tx00002.
      ft_tx00002-rangka   = lw_vbrk-ean11.
      ft_tx00002-fakturno = ld_fakturno.
      ft_tx00002-item     = lw_vbrk-arktx.
      IF ft_vbrkscr-tax = 'X'.
        ft_tx00002-itamtlast  = lw_vbrk-inamtlast.
        ft_tx00002-itdisclast = lw_vbrk-itdiscinlast.
        CLEAR ft_tx00002-exclude.
      ELSE.
        ft_tx00002-itamtlast  = lw_vbrk-examtlast.
        ft_tx00002-itdisclast = lw_vbrk-itdiscexlast.
        ft_tx00002-exclude    = 'X'.
      ENDIF.
      ft_tx00002-itcurr = ft_tx00002-waers = lw_vbrk-waerk.
      ft_tx00002-userid = sy-uname.
      CLEAR ft_tx00002-bilref.

****added by Rahmadi
*---Store Invoice consolidation option
      ft_tx00002-fakgr = fu_flag.
****end of addition

******Get tariff
****modified by Rahmadi
*---karoseri is not relevant for XPBM tariff determination
*---Use PPNBM taxable item instead
*      IF ft_tx00002-karoseri = d_karu.
      IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
        READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                            BINARY SEARCH.
        IF sy-subrc = 0.
          ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
        ELSE.
          CLEAR: ft_tx00002-tarifxpbm.
        ENDIF.
      ELSE.
        CLEAR ft_tx00002-tarifxpbm.
      ENDIF.

      APPEND ft_tx00002.

******Prepare saving FOLLOW-UP BILLING
*' - Retur billing/ follow up billing will be saved
*Specific only for KTB that have more than one items
      ld_tabix = 1.


      DATA: ld_lines_vbrkf  LIKE sy-tabix.
      DESCRIBE TABLE t_vbrkf LINES ld_lines_vbrkf.
      IF ld_tabix < ld_lines_vbrkf OR p_rpc = 'X'.
        ld_tabix = 1.
        LOOP AT t_vbrkf INTO lw_vbrkf FROM ld_tabix.
          ld_tabix = sy-tabix.
*This condition is specific for KTB
          IF lw_vbrkf-vbelv <> lw_vbrk-vbeln.
            ld_tabix = sy-tabix.
            CONTINUE.
          ELSEIF lw_vbrkf-vbelv = lw_vbrk-vbeln AND
                 lw_vbrkf-posnv <> lw_vbrk-posnr.
            ld_tabix = sy-tabix.
            CONTINUE.
          ENDIF.

          MOVE-CORRESPONDING lw_vbrkf TO ft_tx00002.
          ft_tx00002-fakturno = ld_fakturno.
          ft_tx00002-item     = lw_vbrkf-arktx.
          IF ft_vbrkscr-tax = 'X'.
            ft_tx00002-itamtlast  = lw_vbrk-inamtlast.
            ft_tx00002-itdisclast = lw_vbrk-itdiscinlast.
            CLEAR ft_tx00002-exclude.
          ELSE.
            ft_tx00002-itamtlast  = lw_vbrk-examtlast.
            ft_tx00002-itdisclast = lw_vbrk-itdiscexlast.
            ft_tx00002-exclude    = 'X'.
          ENDIF.
          ft_tx00002-bilref = lw_vbrkf-vbelv.
          ft_tx00002-itcurr = ft_tx00002-waers = lw_vbrk-waerk.
          ft_tx00002-userid = sy-uname.

****added by Rahmadi
*---Store Invoice consolidation option
          ft_tx00002-fakgr = fu_flag.
****end of addition

***added for Tempo to accomodate external Nota Retur number
          IF NOT fu_rpc IS INITIAL.
            ft_tx00002-noretur = p_noret.
            ft_tx00002-dtretur = lw_vbrkf-fkdat.
          ENDIF.
***end of Tempo addition

*---------Get tariff
****modified by Rahmadi
*---Karoseri is no more relevant for XPBM Tariff Determination
*---Use PPNBM taxable item instead
*          IF ft_tx00002-karoseri = d_karu.
          IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
            READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                                BINARY SEARCH.
            IF sy-subrc = 0.
              ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
            ELSE.
              CLEAR: ft_tx00002-tarifxpbm.
            ENDIF.
          ELSE.
            CLEAR ft_tx00002-tarifxpbm.
          ENDIF.

          APPEND ft_tx00002.
        ENDLOOP.
*' - Retur billing/ follow up billing will be saved
*Specific only for KTB that have more than one items
        ld_tabix = sy-tabix.
      ENDIF.

******Prepare saving CANCEL billing (only for RPC program)
      IF NOT fu_rpc IS INITIAL.
        LOOP AT t_vbrkc INTO lw_vbrkc FROM ld_tabixc.
          IF lw_vbrkc-vbelv <> lw_vbrk-vbeln OR
             lw_vbrkc-posnv <> lw_vbrk-posnr.
            ld_tabixc = sy-tabix.
            EXIT.
          ENDIF.
          MOVE-CORRESPONDING lw_vbrkc TO ft_tx00002.
          ft_tx00002-fakturno = ld_fakturno.
          ft_tx00002-item = lw_vbrk-arktx.
          IF ft_vbrkscr-tax = 'X'.
            ft_tx00002-itamtlast  = lw_vbrk-inamtlast.
            ft_tx00002-itdisclast = lw_vbrk-itdiscinlast.
            CLEAR ft_tx00002-exclude.
          ELSE.
            ft_tx00002-itamtlast  = lw_vbrk-examtlast.
            ft_tx00002-itdisclast = lw_vbrk-itdiscexlast.
            ft_tx00002-exclude    = 'X'.
          ENDIF.
          ft_tx00002-bilref = lw_vbrkc-vbelv.
          ft_tx00002-itcurr = ft_tx00002-waers = lw_vbrk-waerk.
          ft_tx00002-userid = sy-uname.

****added by Rahmadi
*---Invoice consolidation option
          ft_tx00002-fakgr = fu_flag.
          ft_tx00002-brnch = lw_vbrk-brnch.
          ft_tx00002-busln = lw_vbrk-busln.
****end of addition

**********Get tariff
****modified by Rahmadi
*---Karoseri is not relevant to determine XPBM Tariff
*---PPNBM taxable item is used instead
*          IF ft_tx00002-karoseri = d_karu.
          IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
            READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                                BINARY SEARCH.
            IF sy-subrc = 0.
              ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
            ELSE.
              CLEAR: ft_tx00002-tarifxpbm.
            ENDIF.
          ELSE.
            CLEAR ft_tx00002-tarifxpbm.
          ENDIF.

          APPEND ft_tx00002.
        ENDLOOP.
      ENDIF.

******Collecting amounts
      ld_fakppn    = ld_fakppn + lw_vbrk-ppnlast.
      ld_fakxppnbm = ld_fakxppnbm + lw_vbrk-xppnbmlast.
      ld_fakppnbm  = ld_fakppnbm + lw_vbrk-ppnbmlast.

****added by Rahmadi
*---Store PPh 22, PPh23, DPP total
      ld_fakpph22 = ld_fakpph22 + lw_vbrk-pph22.
      ld_fakpph23 = ld_fakpph23 + lw_vbrk-pph23.
      ld_fakdpp = ld_fakdpp + lw_vbrk-dpp.
****end of addition
****May need to add foreign currency -- Rahmadi

*' Foreign currency
      ld_fakppn_f    = ld_fakppn_f + lw_vbrk-ppn_f.
      ld_fakxppnbm_f = ld_fakxppnbm_f + lw_vbrk-xppnbm_f.
      ld_fakppnbm_f  = ld_fakppnbm_f + lw_vbrk-ppnbm_f.

      ld_fakdpp2 = ft_vbrkscr-dpplast.
      ld_fakppn2 = ft_vbrkscr-ppnlast.
* Command for TKM
*      ld_fakdp = ft_vbrkscr-dplast.
    ENDIF.

    AT END OF vbeln.
******Prepare data for ZGDTXdt0003
      IF NOT ( d_tcode = c_tcode_sederhana OR
               d_tcode = c_tcode_sederhana_single ).
        MOVE-CORRESPONDING lw_vbrk TO ft_tx00003.
        ft_tx00003-fakturno   = ld_fakturno.
        ft_tx00003-batal      = ''.
        ft_tx00003-returcount = '000'.
        ft_tx00003-fakppn     = ld_fakppn.
        ft_tx00003-fakxppnbm  = ld_fakxppnbm.
        ft_tx00003-fakppnbm   = ld_fakppnbm.

****added by Rahmadi
*---Store PPh 22, PPh23, DPP total
        ft_tx00003-fakpph22 = ld_fakpph22.
        ft_tx00003-fakpph23 = ld_fakpph23.
        ft_tx00003-fakdpp = ld_fakdpp.
****end of addition

        ft_tx00003-fakppn_f     = ld_fakppn_f.
        ft_tx00003-fakxppnbm_f  = ld_fakxppnbm_f.
        ft_tx00003-fakppnbm_f   = ld_fakppnbm_f.

        ft_tx00003-npwp       = lw_vbrk-stceg.
        ft_tx00003-userid     = sy-uname.

        IF NOT ld_split_item IS INITIAL.
          ft_tx00003-faktur_type = c_faktur_type_split_item.
        ELSE.
          ft_tx00003-faktur_type = c_faktur_type_satuan.
        ENDIF.

****added by Rahmadi
*---Invoice Consolidation option
        ft_tx00003-fakgr = fu_flag.
****end of addition

        IF p_bukrs EQ '8160'.
          ft_tx00003-fakdpp = ld_fakdpp2.
          ft_tx00003-fakppn = ld_fakppn2.
* Command for TKM
*          ft_tx00003-fakdp = ld_fakdp.
        ENDIF.

        APPEND ft_tx00003.
      ENDIF.
      CLEAR: ld_count, ld_fakppn, ld_fakxppnbm, ld_fakppnbm,
             ld_split_item, ld_fakdpp, ld_fakpph22, ld_fakpph23,
             ld_fakdpp2,ld_fakppn2.  " TKM ld_fakdp

    ENDAT.
  ENDLOOP.

*** Commented out by Rahmadi due to generalization - Report option
**--- Only one line for Spare parts billing (SPART = '02')
*  IF p_spart = d_sparts.
*    PERFORM f_collect_spart TABLES ft_tx00002
*                             USING c_gab_unit2.
*  ENDIF.
*** End of comment

*** Added by Rahmadi
  IF fu_flag = '1' OR
     fu_flag = '4'.
*---Reporting option '1': Consolidated by Invoice
    PERFORM f_collect_spart TABLES ft_tx00002
                             USING d_smtxt
                                   fu_flag.
  ENDIF.
*** End of addition

**Check Petugas based on selected radiobutton on the screen
  CASE 'X'.
    WHEN r_act1.
      d_aktif = d_aktif1.
    WHEN r_act2.
      d_aktif = d_aktif2.
    WHEN r_act3.
      d_aktif = d_aktif3.
    WHEN r_act4.
      d_aktif = d_aktif4.
***added by Rahmadi
*---Additional option for freefill text fields
    WHEN r_act5.
      d_aktif = d_aktif5.
***end of addition
  ENDCASE.

ENDFORM.                    " F_PREPARE_SATUAN_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SATUAN_SCREEN_PREVIEW
*&---------------------------------------------------------------------*
*&  This routine sets GUI status for all screen defined for the program
*&---------------------------------------------------------------------*
*&  ->FU_ADD       - Set to 'X' Add text functionality is enabled
*&---------------------------------------------------------------------*
FORM f_satuan_screen_preview USING fu_add.

  IF fu_add = 'X'.
    SET PF-STATUS 'STAT_PREV'.
  ELSE.
    CLEAR t_status. REFRESH t_status.
    t_status-tcode = 'ADD'.
    APPEND t_status. CLEAR t_status.
    SET PF-STATUS 'STAT_PREV' EXCLUDING t_status.
  ENDIF.
  d_dynnr = '1500'.
  CALL SCREEN 1500.

ENDFORM.                    " F_SATUAN_SCREEN_PREVIEW

*&---------------------------------------------------------------------*
*&      Form  F_PREVIEW_USER_COMMAND
*&---------------------------------------------------------------------*
*&  This routine is performed specifically by previewing screen in the
*&  program whenever any screen's user command is executed
*&---------------------------------------------------------------------*
FORM f_preview_user_command.

  CASE sy-ucomm.
    WHEN 'ZBACK' OR 'ZCANC' OR 'ZEXIT'.
      PERFORM f_clear_data USING '02'.
      LEAVE LIST-PROCESSING.
    WHEN 'PRINT'.
      PERFORM f_call_function USING '' 'X' ''
                              p_mpage
                              p_dest
                              space
                              p_cust
                              CHANGING d_subrcp.
  ENDCASE.

ENDFORM.                    " F_PREVIEW_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_EXIT_SCREEN
*&---------------------------------------------------------------------*
*&  This routine is used by EXIT COMMAND modules defined for the
*&  program, depending on the screen executing the exit command.
*&---------------------------------------------------------------------*
*&  ->FU_DYNNR    - Screen number
*&---------------------------------------------------------------------*
FORM f_exit_screen USING fu_dynnr.

  DATA ld_answer.
  DATA ld_subrc LIKE sy-subrc.

  CASE fu_dynnr.
    WHEN '1300'.
      CASE sy-ucomm.
        WHEN 'EBACK' OR 'ECANC' OR 'EEXIT'.
          PERFORM f_popup_to_confirm_step
                  USING 'Exit transaction'
                        'Data will be lost without saving'
                        'Do you want to save your work?'
                        ld_answer.
          CASE ld_answer.
            WHEN 'J'.
              CLEAR ld_answer.
              PERFORM f_save_print_prev USING 'X'
                                              ''
                                              ''.
            WHEN 'N'.
              CLEAR ld_answer.
              PERFORM f_clear_data USING '01'.
              PERFORM f_unlock_all_billing.
*             LEAVE TO SCREEN 0.
              LEAVE PROGRAM.
            WHEN 'A'.
              CLEAR ld_answer.
          ENDCASE.
      ENDCASE.
  ENDCASE.

ENDFORM.                    " F_EXIT_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_WITH_ITEM_CAT
*&---------------------------------------------------------------------*
*&  This routine is only applicable for Service billing since it has
*&  to separate between Service and Spare parts item categories
*&---------------------------------------------------------------------*
FORM f_selection_with_item_cat.

**Check Item division (only applicable for SERVICE)
  PERFORM f_get_item_category_range TABLES r_pstyv
                                    USING  p_serv
                                           p_sparts
                                           ''
                                           p_contra.

**Get Billing data
  PERFORM f_get_billing_data TABLES        t_vbrk0
                                           s_vbeln
                                           r_fkartn
                                           s_fkdat
                                           s_stceg
                                           r_pstyv
                             USING         p_vkorg
                                           p_gsber
                                           p_spart
                                           p_brnch
                                           p_busln
                                           p_bukrs
                                           ''
                                           p_curr.
ENDFORM.                    " F_SELECTION_WITH_ITEM_CAT

*&---------------------------------------------------------------------*
*&      Form  F_DATA_PROCESSING
*&---------------------------------------------------------------------*
*&  This routine consists of the whole process from retrieving billings
*&  to converting billings to tax form
*&---------------------------------------------------------------------*
FORM f_data_processing.
  SELECT SINGLE *
    FROM zproject
    INTO CORRESPONDING FIELDS OF gs_dpp
    WHERE name = 'DPP12'.

  PERFORM f_coretax_validate.

  IF d_rpc IS INITIAL AND
     NOT ( d_tcode = c_tcode_sederhana OR
           d_tcode = c_tcode_sederhana_single ) AND    "CR009 16/04/2002
           p_spart = d_service AND
           r_pstyv[] IS INITIAL.
    MESSAGE s000(ztx) WITH 'No data was selected'.
  ELSE.
    PERFORM f_get_header_data TABLES r_pstyv
                              USING  p_vkorg
                                     p_gsber
                                     p_spart
                                     p_brnch
                                     p_busln
                                     p_bukrs
                                     p_fakdat.

    IF NOT t_vbrk0[] IS INITIAL.
******moved in from selection screen -- Tempo
      PERFORM f_billing_lock TABLES t_vbrk0.
******end of Tempo addition
      PERFORM f_collect_billing_info TABLES s_fkdat
                                            s_stceg
                                     USING  p_vkorg
                                            p_gsber
                                            p_spart
                                            p_brnch
                                            p_busln
                                            p_bukrs
                                            p_rpc
                                            p_top.

      PERFORM f_get_supporting_data USING   p_vkorg
                                            p_gsber
                                            p_spart
                                            p_brnch
                                            p_busln.

      PERFORM f_process_data USING          p_vkorg
                                            p_gsber
                                            p_spart
                                            p_brnch
                                            p_busln
                                            p_bukrs
                                            p_fakdat
                                            p_rpc.

      IF NOT ( d_tcode = c_tcode_sederhana OR
               d_tcode = c_tcode_sederhana_single ).  "CR009 16/04/2002
        PERFORM f_prepare_screen USING d_aktif
                                 CHANGING r_act1
                                          r_act2
                                          r_act5.
      ENDIF.
    ENDIF.

    "Hitung uang muka
    IF p_brnch EQ '8160' AND t_vbrkscr[] IS NOT INITIAL.
      PERFORM f_get_uang_muka TABLES t_vbrkscr t_vbrk1.
    ENDIF.

**added for Tempo -- sort by GSBER, since GSBER is displayed
    SORT t_vbrkscr BY gsber vbeln.
**end of Tempo addition
    CALL SCREEN 1300.
  ENDIF.

ENDFORM.                    " F_DATA_PROCESSING

*&---------------------------------------------------------------------*
*&      Form  F_BILLING_SELECTION
*&---------------------------------------------------------------------*
*&  This routine retrieves selected billing data based on the selection
*&  screen parameters. If this routine is executed by RPC program,
*&  RPC and Item category (PSTYV) parameters must be set not to be
*&  initial.
*&---------------------------------------------------------------------*
*&  ->FU_RPC       - Set to 'X' if executed by RPC program
*&  ->FU_PSTYV     - Item category selected from the screen.
*&                   It will only be filled for Service billings
*&---------------------------------------------------------------------*
FORM f_billing_selection TABLES ft_pstyv STRUCTURE s_pstyv
                         USING  fu_rpc.

  CASE d_tcode.
*--- SATUAN
    WHEN c_tcode_satuan.
      IF p_spart = d_service.
        IF fu_rpc IS INITIAL.
          PERFORM f_select_item_category.
        ELSE.        " ------------------------- >  RPC
          r_pstyv[] = s_pstyv[].

*--------- Get Billing data
          PERFORM f_get_billing_data TABLES   t_vbrk0
                                              s_vbeln
                                              r_fkartn
                                              s_fkdat
                                              s_stceg
                                              r_pstyv
                                     USING    p_vkorg
                                              p_gsber
                                              p_spart
                                              p_brnch
                                              p_busln
                                              p_bukrs
                                              p_rpc
                                              p_curr.
        ENDIF.
      ELSE.
*-------- Get Billing data
        PERFORM f_get_billing_data TABLES     t_vbrk0
                                              s_vbeln
                                              r_fkartn
                                              s_fkdat
                                              s_stceg
                                              r_pstyv
                                   USING      p_vkorg
                                              p_gsber
                                              p_spart
                                              p_brnch
                                              p_busln
                                              p_bukrs
                                              p_rpc
                                              p_curr.
      ENDIF.

*--- SEDERHANA
    WHEN c_tcode_sederhana.
      PERFORM f_get_billing_sederhana TABLES  t_vbrk0
                                              s_vbeln
                                              r_fkartn
                                              s_fkdat
                                      USING   p_vkorg
                                              p_gsber
                                              p_spart
                                              p_brnch
                                              p_busln
                                              p_bukrs
                                              p_masatx
                                    CHANGING  p_fakdat.
*--- PROSES BILLING TANPA NPWP
    WHEN c_tcode_sederhana_single.
      IF s_fkdat-high IS INITIAL.
        PERFORM f_faktur_date TABLES          s_fkdat
                              USING           s_fkdat-low
                                              p_vkorg
                                              p_gsber
                                              p_brnch
                                              p_rpc.
      ELSE.
        PERFORM f_faktur_date TABLES          s_fkdat
                              USING           s_fkdat-high
                                              p_vkorg
                                              p_gsber
                                              p_brnch
                                              p_rpc.
      ENDIF.
      PERFORM f_get_billing_sederhana TABLES t_vbrk0
                                             s_vbeln
                                             r_fkartn
                                             s_fkdat
                                      USING  p_vkorg
                                             p_gsber
                                             p_spart
                                             p_brnch
                                             p_busln
                                             p_bukrs
                                             s_fkdat-low+0(6)
                                   CHANGING  p_fakdat.
  ENDCASE.

ENDFORM.                    " F_BILLING_SELECTION

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_SCREEN
*&---------------------------------------------------------------------*
*&  This routine modifies screen output depending on from what
*&  transaction codes the program is executed.
*&---------------------------------------------------------------------*
*&  ->FU_TCODE     - Transaction codes
*&---------------------------------------------------------------------*
FORM f_change_screen USING    fu_tcode.

  LOOP AT SCREEN.
    IF screen-name CS 'P_RPC' OR screen-name CS 'S_PSTYV'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  CASE fu_tcode.
    WHEN c_tcode_sederhana.
*----- SEDERHANA
      LOOP AT SCREEN.
****modified by Rahmadi
*---Put Billing date as mandatory parameter for Sederhana
*        IF screen-name = '%_S_FKDAT_%_APP_%-TEXT'      OR
*           screen-name = '%_S_FKDAT_%_APP_%-OPTI_PUSH' OR
*           screen-name = 'S_FKDAT-LOW'                 OR
*           screen-name = '%_S_FKDAT_%_APP_%-TO_TEXT'   OR
*           screen-name = 'S_FKDAT-HIGH'                OR
****end of modification
        IF screen-name = '%_S_STCEG_%_APP_%-TEXT'      OR
           screen-name = '%_S_STCEG_%_APP_%-OPTI_PUSH' OR
           screen-name = 'S_STCEG-LOW'                 OR
           screen-name = '%_S_STCEG_%_APP_%-VALU_PUSH' OR
           screen-name = '%_P_FAKDAT_%_APP_%-TEXT'     OR
           screen-name = 'P_FAKDAT'                    OR
           screen-name CS 'P_TOP'                      OR
           screen-name = '%C999012_1000'.
          screen-active = 0.
          screen-input = 0.
          screen-output = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN c_tcode_satuan.
*----- SATUAN
      LOOP AT SCREEN.
        IF screen-name = '%_P_MASATX_%_APP_%-TEXT' OR
           screen-name = 'P_MASATX'.
          screen-active = 0.
          screen-input = 0.
          screen-output = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN c_tcode_sederhana_single.  "CR009 16/04/2002
*----- SEDERHANA
      LOOP AT SCREEN.
        IF screen-name = '%_S_STCEG_%_APP_%-TEXT' OR
           screen-name = '%_S_STCEG_%_APP_%-OPTI_PUSH' OR
           screen-name = 'S_STCEG-LOW' OR
           screen-name = '%_S_STCEG_%_APP_%-VALU_PUSH' OR
           screen-name = '%_P_FAKDAT_%_APP_%-TEXT' OR
           screen-name = 'P_FAKDAT' OR
           screen-name = '%_P_MASATX_%_APP_%-TEXT' OR
           screen-name = 'P_MASATX' OR
           screen-name = '%_S_VBELN_%_APP_%-TO_TEXT' OR
           screen-name = 'S_VBELN-HIGH'.
          screen-active = 0.
          screen-input = 0.
          screen-output = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
      LOOP AT SCREEN.
        IF screen-name = 'S_VBELN-LOW'.
          screen-required = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDFORM.                    " F_CHANGE_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SET_STATUS
*&---------------------------------------------------------------------*
*&  This routine sets GUI status to be used by the program depending on
*&  the transaction codes executing the program
*&---------------------------------------------------------------------*
FORM f_set_status.

  CASE d_tcode.
    WHEN c_tcode_satuan.
      IF NOT d_period_end IS INITIAL.   "Period End (Akhir Masa)
        SET TITLEBAR 'TITLE_AKHIR_MASA'.
      ELSE.
        SET TITLEBAR 'TITLE_1300'.
      ENDIF.
      REFRESH t_status.
      IF NOT d_rpc IS INITIAL.
        REFRESH t_status.
        t_status-tcode = 'SALL'.
        APPEND t_status.
        t_status-tcode = 'DALL'.
        APPEND t_status.
        t_status-tcode = 'ATAX'.
        APPEND t_status.
        t_status-tcode = 'DTAX'.
        APPEND t_status.
      ENDIF.
    WHEN c_tcode_sederhana.
      SET TITLEBAR 'TITLE_SDH'.
      REFRESH t_status.
      t_status-tcode = 'SAVP'.
      APPEND t_status.
      t_status-tcode = 'PREV'.
      APPEND t_status.
      t_status-tcode = 'ATAX'.
      APPEND t_status.
      t_status-tcode = 'DTAX'.
      APPEND t_status.
    WHEN c_tcode_sederhana_single.
      SET TITLEBAR 'TITLE_SDH_SINGLE'.
      REFRESH t_status.
      t_status-tcode = 'SAVP'.
      APPEND t_status.
      t_status-tcode = 'PREV'.
      APPEND t_status.
      t_status-tcode = 'ATAX'.
      APPEND t_status.
      t_status-tcode = 'DTAX'.
      APPEND t_status.
  ENDCASE.

  SET PF-STATUS 'STATUS_1300' EXCLUDING t_status.

ENDFORM.                    " F_SET_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_PREP_SEDERHANA_TABLE
*&---------------------------------------------------------------------*
*&  This routine is only applicable for Sederhana process to select
*&  billings needs to be processed as Faktur pajak
*&---------------------------------------------------------------------*
*&  ->FT_VBRKSCR  - Billing data
*&  <-FT_TX00002  - Selected billing numbers
*&---------------------------------------------------------------------*
FORM f_prep_sederhana_table TABLES ft_vbrkscr STRUCTURE t_vbrkscr
                                   ft_tx00002 STRUCTURE zgdtxdt0002.

  DATA ld_tabix LIKE sy-tabix.
  DATA lw_vbrk LIKE t_vbrk.
  DATA lw_vbrkf LIKE t_vbrkf.

  ld_tabix = 1.
  LOOP AT t_vbrk.
    MOVE-CORRESPONDING t_vbrk TO lw_vbrk.
    READ TABLE ft_vbrkscr WITH KEY vbeln = lw_vbrk-vbeln
                          BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR lw_vbrk.
      CONTINUE.
    ELSE.

******Prepare saving NORMAL BILLING
      MOVE-CORRESPONDING lw_vbrk TO ft_tx00002.
      ft_tx00002-item = lw_vbrk-arktx.
      ft_tx00002-itcurr = ft_tx00002-waers = lw_vbrk-waerk.
      ft_tx00002-userid = sy-uname.

******Get tariff
****modified by Rahmadi
*---Karoseri is not relevant for XPBM tariff determination
*---Use PPNBM taxable item instead
*      IF ft_tx00002-karoseri = d_karu.
      IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
        READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                            BINARY SEARCH.
        IF sy-subrc = 0.
          ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
        ELSE.
          CLEAR: ft_tx00002-tarifxpbm.
        ENDIF.
      ELSE.
        CLEAR ft_tx00002-tarifxpbm.
      ENDIF.

******Only one line for Spare parts billing
      IF ft_tx00002-spart = d_sparts.
        ft_tx00002-posnr = '000001'.
        CLEAR ft_tx00002-matnr.
        ft_tx00002-item = c_gab_unit2.
        COLLECT ft_tx00002.
      ELSE.
        APPEND ft_tx00002.
      ENDIF.

******Prepare saving FOLLOW-UP BILLING
      LOOP AT t_vbrkf INTO lw_vbrkf FROM ld_tabix.
        IF lw_vbrkf-vbelv <> lw_vbrk-vbeln OR
           lw_vbrkf-posnv <> lw_vbrk-posnr.
          ld_tabix = sy-tabix.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING lw_vbrkf TO ft_tx00002.
        ft_tx00002-item = lw_vbrk-arktx.
        ft_tx00002-bilref = lw_vbrkf-vbelv.
        ft_tx00002-itcurr = ft_tx00002-waers = lw_vbrk-waerk.
        ft_tx00002-userid = sy-uname.

********Get tariff
****modified by Rahmadi
*---Karoseri is not relevant for XPBM tariff determination
*---Use PPNBM taxable item instead
*        IF ft_tx00002-karoseri = d_karu.
        IF NOT ft_tx00002-ppnbm IS INITIAL.
****end of modification
          READ TABLE t_tariff WITH KEY vbeln = ft_tx00002-vbeln
                              BINARY SEARCH.
          IF sy-subrc = 0.
            ft_tx00002-tarifxpbm = t_tariff-tarifxpbm.
          ELSE.
            CLEAR: ft_tx00002-tarifxpbm.
          ENDIF.
        ELSE.
          CLEAR ft_tx00002-tarifxpbm.
        ENDIF.

        APPEND ft_tx00002.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_PREP_SEDERHANA_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SET_TITLE
*&---------------------------------------------------------------------*
*&  This routine sets title to be displayed by the program depending on
*&  the transaction code executing the program.
*&---------------------------------------------------------------------*
FORM f_set_title.

  CASE sy-tcode.
    WHEN c_tcode_satuan.
      d_tcode = sy-tcode.
      SET TITLEBAR 'TITLE_1300'.
    WHEN c_tcode_sederhana.
      d_tcode = sy-tcode.
      SET TITLEBAR 'TITLE_SDH'.
    WHEN c_tcode_rpc.
      d_tcode = c_tcode_satuan.
      SET TITLEBAR 'TITLE_1300'.
    WHEN c_tcode_period_end_satuan.
      d_tcode = c_tcode_satuan.
      d_period_end = 'X'.
      SET TITLEBAR 'TITLE_AKHIR_MASA'.
    WHEN c_tcode_sederhana_single.   "CR009 16/04/2002
      d_tcode = sy-tcode.
      SET TITLEBAR 'TITLE_SDH_SINGLE'.
    WHEN OTHERS.
      MESSAGE i509(ztx).
      LEAVE PROGRAM.
  ENDCASE.

ENDFORM.                    " F_SET_TITLE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_PROCESSING_DATE
*&---------------------------------------------------------------------*
*&  SEDERHANA process can ONLY be processed at the end of the period.
*&  This routine is only applicable for Sederhana process to prevent
*&  it to be processed on the earlier date than the period end date.
*&---------------------------------------------------------------------*
*&  ->FU_MASATX  - Tax period
*&---------------------------------------------------------------------*
FORM f_check_processing_date USING  fu_masatx.

  RANGES: lr_fodat FOR sy-datum.
  DATA:   ld_datum LIKE sy-datum.

  CONCATENATE fu_masatx
              '01'
              INTO ld_datum.
  PERFORM f_get_daterange_of_the_month TABLES  lr_fodat
                                       USING   ld_datum.
  CHECK sy-datum <= lr_fodat-high.
  MESSAGE e000(ztx) WITH 'Faktur pajak sederhana'
                        'can only be processed'
                        'at the end of the period'.

ENDFORM.                    " F_CHECK_PROCESSING_DATE

*&---------------------------------------------------------------------*
*&      Form  F_PAGING
*&---------------------------------------------------------------------*
*&  This routine performs PAGE UP/DOWN functionalities on the screen
*&---------------------------------------------------------------------*
*&  ->FU_CODE  - User command
*&---------------------------------------------------------------------*
FORM f_paging USING fu_code.

  DATA: ld_i TYPE i,
        ld_j TYPE i.

  CASE fu_code.
    WHEN 'P--'.
      ctrl_1300-top_line = 1.
    WHEN 'P-'.
      ctrl_1300-top_line = ctrl_1300-top_line - d_line_count.
      IF ctrl_1300-top_line LE 0.
        ctrl_1300-top_line = 1.
      ENDIF.
    WHEN 'P+'.
      ld_i = ctrl_1300-top_line + d_line_count.
      ld_j = ctrl_1300-lines - d_line_count + 1.
      IF ld_j LE 0.
        ld_j = 1.
      ENDIF.
      IF ld_i LE ld_j.
        ctrl_1300-top_line = ld_i.
      ELSE.
        ctrl_1300-top_line = ld_j.
      ENDIF.
    WHEN 'P++'.
      ctrl_1300-top_line = ctrl_1300-lines - d_line_count + 1.
      IF ctrl_1300-top_line LE 0.
        ctrl_1300-top_line = 1.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_PAGING

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VAT_DATE
*&---------------------------------------------------------------------*
FORM f_check_vat_date USING  fu_gjahr fu_fakdat fu_vbeln.
  DATA : lr_datum   TYPE RANGE OF datum,
         wa_datum   LIKE LINE OF lr_datum,
         lv_posnr   TYPE posnr,
         lt_zfvatnr LIKE zfvatnr.

  SELECT SINGLE *
    FROM zfvatnr
    INTO lt_zfvatnr
    WHERE vkorg EQ p_brnch AND
          gjahr EQ fu_gjahr.

  IF sy-subrc = 0.
    lv_posnr  = lt_zfvatnr-posnr.
    IF lt_zfvatnr-vatno >= lt_zfvatnr-vatto.
      lv_posnr = lv_posnr + 10.
    ENDIF.
  ENDIF.

  LOOP AT gt_zfvatnr_dtl INTO wa_vat
                         WHERE vkorg EQ p_brnch
                           AND gjahr EQ fu_gjahr
                           AND posnr EQ lv_posnr.
    IF wa_vat-validfr IS NOT INITIAL AND
      wa_vat-validto IS NOT INITIAL.
      wa_datum-low      = wa_vat-validfr.
      wa_datum-high     = wa_vat-validto.
      wa_datum-sign     = 'I'.
      wa_datum-option   = 'BT'.
      APPEND wa_datum TO lr_datum.
    ENDIF.

    IF lr_datum[] IS INITIAL.
      DELETE t_vbrkscr1 WHERE vbeln EQ fu_vbeln.
      t_error-vbeln = fu_vbeln.
      t_error-msg   = 'Tanggal faktur tidak ada di ranges tanggal'.
      APPEND t_error.
      CLEAR t_error.
    ELSE.
      IF fu_fakdat IN lr_datum.
        CONTINUE.
      ELSE.
        DELETE t_vbrkscr1 WHERE vbeln EQ fu_vbeln.
        t_error-vbeln = fu_vbeln.
        t_error-msg   = 'Tanggal faktur tidak ada di ranges tanggal'.
        APPEND t_error.
        CLEAR t_error.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_VAT_DATE

*&---------------------------------------------------------------------*
*&      Form  F_CORETAX_VALIDATE
*&---------------------------------------------------------------------*
FORM f_coretax_validate .
  DATA : ls_project TYPE zproject,
         ls_coretax LIKE LINE OF gr_coretax.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'CORETAX'.
  ls_coretax-low = ls_project-datab.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'ZGDCORETAX'.
  ls_coretax-high   = ls_project-datab.
  ls_coretax-sign   = 'I'.
  ls_coretax-option = 'BT'.
  APPEND ls_coretax TO gr_coretax.
ENDFORM.
