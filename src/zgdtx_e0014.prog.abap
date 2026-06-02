*----------------------------------------------------------------------*
*& Spec id    : TX-51                                                  *
*& Title      : Process Return, Price Adjustment & Cancel              *
*& Transaction: ZGDTXE0014                                           *
*&---------------------------------------------------------------------*

REPORT zgdtx_e0014
       MESSAGE-ID zab.

INCLUDE zgdtxformsf01.
INCLUDE zgdtxne0014top.
INCLUDE zgdtxne0014f01.
INCLUDE zgdtxne0014i01.
INCLUDE zgdtxne0014o01.
INCLUDE zstdxin_udf.


*----------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------*
INITIALIZATION.
***added for Tempo --- to get Default printer device for the user
  PERFORM f_get_printer_def USING sy-uname
                         CHANGING p_dest.
***end of Tempo addition
  PERFORM f_get_billing_type.

* Added by Rama
*  PERFORM f_get_tax_config_details.
*****moved to Selection screen using Function module by Rahmadi
* end of add by rama

  PERFORM f_join_fkart.
  macro_udf_selopt_rest s_fkdat 'X'.
*--- Indicator for other program thar run from this program.
  d_rpc = 'X'.

*----------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

AT SELECTION-SCREEN.

***added by Rahmadi
*-Check whether Tax period program is still running
  CLEAR d_tx04_lock_subrc.
  PERFORM f_check_tax_period CHANGING d_tx04_lock_subrc.
  IF d_tx04_lock_subrc <> 0.
    STOP.
  ENDIF.
***end of addition

***Added for Tempo
*--Check if Nota Retur # has been used by the same customer before
  IF NOT p_noret IS INITIAL.
    PERFORM f_check_noret.
  ENDIF.
***end of Tempo addition

* Added by rama
* Get the company code from the branch config table
*  PERFORM f_get_sap_org_values USING p_brnch p_busln
*                            CHANGING p_bukrs.
*-Changed to Function module by Rahmadi
*-Get Organization structure config
  CALL FUNCTION 'Z_GDTXFC_TAX_CFG_ORG_DETMN'
    EXPORTING
      fi_brnch                      = p_brnch
      fi_busln                      = p_busln
    IMPORTING
      fe_bukrs                      = p_bukrs
      fe_busds                      = d_busds
      fe_bdesc                      = d_bdesc
      fe_ho_ind                     = d_hoind
    TABLES
      ft_tx00101                    = t_tx00101
      ft_tx00102                    = t_tx00102
      ft_tx00103                    = t_tx00103
    EXCEPTIONS
      company_code_not_assigned     = 1
      business_line_not_maintained  = 2
      branch_config_not_maintained  = 3
      busline_config_not_maintained = 4
      taxconsol_config_not_maintain = 5
      OTHERS                        = 6.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE e000(zab) WITH 'No company code assigned to branch'.
      WHEN 2 OR 4.
        MESSAGE e000(zab) WITH 'No business line maintained'.
      WHEN 3.
        MESSAGE e000(zab) WITH 'No branch maintained'.
      WHEN 5.
        MESSAGE e000(zab) WITH 'Tax Consolidation config table'
                               'is not maintained'.
      WHEN OTHERS.
        MESSAGE e000(zab) WITH 'Fatal Error!'.
    ENDCASE.
  ENDIF.
* end of addition.

***Added by Rahmadi
*-Check Consolidation option
  CLEAR t_tx00103.
  READ TABLE t_tx00103 WITH KEY brnch = p_brnch
                                busln = p_busln
                                satgr = p_flag.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) WITH 'Cons.Opt.'
                           p_flag
                           'is not maintained for the branch'
                           'and/or the business line'.
  ENDIF.
  d_smtxt  = t_tx00103-smtxt.
  d_smtxt1 = t_tx00103-smtxt1.
  d_smtxt2 = t_tx00103-smtxt2.
  d_pkpfl  = t_tx00103-pkpfl.
***End of addition

***added for Tempo: check nota retur printing status on branch
  READ TABLE t_tx00101 WITH KEY brnch = p_brnch.
  IF t_tx00101-prtnrvo IS INITIAL AND            "Customer print NR
     p_noret IS INITIAL.
    MESSAGE e000(zab) WITH 'Nota retur must be entered'.
  ELSEIF NOT t_tx00101-prtnrvo IS INITIAL AND    "Company print NR
         NOT p_noret IS INITIAL.
    MESSAGE e000(zab) WITH 'Nota retur must be blank'.
  ENDIF.

***end of addition

  macro_init_ranges r_pstyv.
  CASE d_dynnr.
    WHEN '2000'.
      IF sy-ucomm = 'CRET'.

**Check Item division (only applicable for SERVICE)
        PERFORM f_get_item_category_range TABLES r_pstyv
                                          USING  p_serv
                                                 p_sparts
                                                 p_both
                                                 space.

        PERFORM f_get_billing_data TABLES   t_vbrk0
                                            s_vbeln
                                            r_fkart
                                            s_fkdat
                                            s_stceg
                                            r_pstyv
                                   USING    p_vkorg
                                            p_gsber
                                            p_spart
                                            p_brnch
                                            p_busln
                                            p_bukrs
                                            ''
                                            p_curr.
      ENDIF.
    WHEN OTHERS.
      PERFORM f_get_billing_data TABLES   t_vbrk0
                                          s_vbeln
                                          r_fkart
                                          s_fkdat
                                          s_stceg
                                          r_pstyv
                                 USING    p_vkorg
                                          p_gsber
                                          p_spart
                                          p_brnch
                                          p_busln
                                          p_bukrs
                                          ''
                                          p_curr.

  ENDCASE.

*----------------------------------------------------------*
* AT USER-COMMAND
*----------------------------------------------------------*
AT USER-COMMAND.
  CASE d_dynnr.
    WHEN '1600' OR '5000'.
      PERFORM f_preview_user_commands.
  ENDCASE.


*----------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_get_header_data TABLES r_pstyv
                            USING  p_vkorg
                                   p_gsber
                                   p_spart
                                   p_brnch
                                   p_busln
                                   p_bukrs
                                   sy-datum.

  IF NOT t_vbrk0[] IS INITIAL.

    PERFORM f_collect_bill_normal TABLES t_vbrk0.

    PERFORM f_get_bill TABLES t_vbrk0.

*****added for Tempo to accomodate billing created with no ref
*    IF t_vbrk0[] IS INITIAL.
*      IF t_noref[] IS INITIAL.
*        MESSAGE i000(zab) WITH 'Invalid billing number'.
*        CALL FUNCTION 'DEQUEUE_ALL'
**         EXPORTING
**           _SYNCHRON       = ' '
*                  .
*        STOP.
*      ENDIF.
*    ENDIF.
*****end of Tempo addition

****modified for Tempo to accomodate billing created with no ref
      IF NOT t_vbrk0[] IS INITIAL.
        PERFORM f_collect_bill TABLES t_vbrk0.
      ENDIF.

      IF NOT t_noref[] IS INITIAL.
        PERFORM f_collect_bill TABLES t_noref.
      ENDIF.
****end of Tempo modification

    PERFORM f_satuan.

  ENDIF.

  CALL SCREEN 2100.



*Text elements
*-------------
* I002     Billing Data
* INOT     Note
* INT2     Billing di bulan beda ->otomatis Retur atau FP baru utk
* koreksi h



*Selection texts
*---------------
*SP_BOTH          Nota Jasa & Nota Barang
*SP_BRNCH         Branch
*SP_BUSLN         Business Line
*SP_DEST          Output Device
*SP_FLAG          Display option
*SP_MPAGE         Multiple pages
*SP_SERV          Nota Jasa
*SP_SPAGE         Single page
*SS_FKDAT         Billing date
*SS_VBELN         Billing No.


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
