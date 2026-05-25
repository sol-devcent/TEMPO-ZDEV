*----------------------------------------------------------------------*
*& Title      : Process Cash Basis/Akhir Masa -                        *
*&              Faktur Pajak Satuan / Sederhana                        *
*& Functional : IBM                                                    *
*& Transaction: ZGDTXE0002 (for FP Satuan - Cash Basis)                *
*&              ZGDTXE0002_01 (for PPN Sederhana)                      *
*&              ZGDTXE0002_02 (for FP Satuan - Akhir Masa)             *
*&              ZGDTXE0002_03 (for Proses Billing tanpa NPWP)          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE       AUTHOR         DESCRIPTION                      *
*& ----     ----       ------         -----------                      *
*& N/A      DD.MM.YY   ABAPer         What is changed ?                *
*&                                    Transport Request : D99K999999   *
*&---------------------------------------------------------------------*
PROGRAM zgdtx_e0002 NO STANDARD PAGE HEADING.

*&---------------------------------------------------------------------*
*& Include.
*&---------------------------------------------------------------------*
INCLUDE zgdtxformsf01.
INCLUDE zgdtxne0002top.
INCLUDE zgdtxne0002i01.
INCLUDE zgdtxne0002o01.
INCLUDE zgdtxne0002f01.

INCLUDE zstdxin_udf.

*---------------------------------------------------------------------*
*Initialization
*---------------------------------------------------------------------*
INITIALIZATION.
***added for Tempo --- to get Default printer device for the user
  PERFORM f_get_printer_def USING sy-uname
                         CHANGING p_dest.
***end of Tempo addition
  PERFORM f_set_title.
  PERFORM f_get_billing_type.
* Added by Rama
*  PERFORM f_get_tax_config_details.
*****moved to Selection screen using Function module by Rahmadi
* end of add by rama

  macro_udf_selopt_rest s_fkdat 'X'.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_change_screen USING d_tcode.

*---------------------------------------------------------------------*
*At selection-screen on
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
  macro_atz_single_bukrs p_bukrs c_atz_display.

AT SELECTION-SCREEN ON p_fakdat.
  IF d_dynnr <> '2000'.
    CASE d_tcode.
      WHEN c_tcode_satuan.
***removed for Tempo
*        PERFORM f_faktur_date TABLES s_fkdat
*                              USING  p_fakdat
*                                     p_vkorg
*                                     p_gsber
*                                     p_brnch
*                                     p_rpc.
***end of Tempo removal
    ENDCASE.
  ENDIF.

AT SELECTION-SCREEN ON s_fkdat.
  IF d_dynnr <> '2000'.
    CASE d_tcode.
      WHEN c_tcode_satuan.
        PERFORM f_valid_date TABLES s_fkdat.
    ENDCASE.
  ENDIF.

AT SELECTION-SCREEN ON p_masatx.
  IF d_dynnr <> '2000'.
    CASE d_tcode.
      WHEN c_tcode_sederhana.
****added by Rahmadi
*---Additional validation for Sederhana process
        PERFORM f_valid_date_sederhana TABLES s_fkdat
                                       USING  p_masatx.
****end of addition
        PERFORM f_check_closing_period USING p_masatx
                                             p_vkorg
                                             p_gsber
                                             p_brnch
                                             'X'.
    ENDCASE.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  d_rpc = p_rpc. " ------------>   If 'X' means executed by RPC program
  macro_init_ranges r_pstyv.

***added by Rahmadi
*-Check whether Tax period program is still running
  CLEAR d_tx04_lock_subrc.
  PERFORM f_check_tax_period CHANGING d_tx04_lock_subrc.
  IF d_tx04_lock_subrc <> 0.
    STOP.
  ENDIF.
***end of addition

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

**removed by Rahmadi
*  PERFORM f_authority_check USING p_vkorg
*                                  p_gsber.
**end of removal

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
  d_pkpfl = t_tx00103-pkpfl.

***End of addition

****added by Rahmadi
***Lock Tax Period
*  CLEAR d_lock_subrc.
*  PERFORM f_lock_tax_period USING    p_brnch
*                            CHANGING d_lock_subrc.
*  CHECK d_lock_subrc = 0.
****end of addition

  CASE d_dynnr.
    WHEN '2000'.
      IF sy-ucomm = 'CRET'.
        PERFORM f_selection_with_item_cat.
      ENDIF.
    WHEN OTHERS.
      PERFORM f_billing_selection TABLES s_pstyv
           USING p_rpc.
  ENDCASE.

*&-------------------------------------------------------------------*
*& AT USER-COMMAND.
*&-------------------------------------------------------------------*
AT USER-COMMAND.
  CASE d_dynnr.
    WHEN '1500'.
      PERFORM f_preview_user_command.
  ENDCASE.

*&-------------------------------------------------------------------*
*& START-OF-SELECTION.
*&-------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_data_processing.



*Text elements
*-------------
* I002     Billing Selection
* I999     TOP



*Selection texts
*---------------
*SP_BRNCH         Branch of Tax
*SP_BUSLN         Business Line
*SP_CONTRA        Service Contract
*SP_DEST          Output Device
*SP_FAKDATD       Document date
*SP_FLAG          Display option
*SP_MPAGE         Multiple pages
*SP_SPAGE         Single page
*SS_FKDAT D       Billing date
*SS_STCEG D       VAT registration no.


*Messages
*-------------
* Message class: ZAB
* 000 & & & &
